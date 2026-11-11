<?php

namespace App\Controllers;

use App\Libraries\TenantDatabase;
use CodeIgniter\Controller;
use CodeIgniter\HTTP\RedirectResponse;
use Config\Database;

class LoginController extends Controller
{
    public function index(): string
    {
        return view('auth/login', ['error' => session()->getFlashdata('error')]);
    }

    public function authenticate(): RedirectResponse
    {
        $identifier = $this->request->getPost('identifier');
        $password = $this->request->getPost('password');

        if (
            ! is_string($identifier)
            || trim($identifier) === ''
            || ! is_string($password)
            || $password === ''
        ) {
            return redirect()->back()->withInput()->with('error', 'Ingresa tu usuario o correo y contraseña.');
        }

        $central = Database::connect();
        $user = $central->table('usuarios u')
            ->select('u.id, u.nombre, u.apellido, u.usuario, u.correo, u.password_hash, u.rol_id, r.nombre AS rol')
            ->join('roles r', 'r.id = u.rol_id')
            ->groupStart()
                ->where('u.usuario', trim($identifier))
                ->orWhere('u.correo', trim($identifier))
            ->groupEnd()
            ->where('u.activo', 1)
            ->where('u.fec_eliminacion', null)
            ->where('r.fec_eliminacion', null)
            ->get()
            ->getRowArray();

        if ($user === null || ! password_verify($password, $user['password_hash'])) {
            return redirect()->back()->withInput()->with('error', 'Usuario o contraseña incorrectos.');
        }

        $tenantKey = null;
        $assignedBusinesses = [];

        if (in_array($user['rol'], ['propietario', 'empleado'], true)) {
            $assignments = $central->table('usuario_emprendimientos ue')
                ->select('e.id, e.database_key, e.nombre, e.usa_productos, e.usa_servicios')
                ->join('emprendimientos e', 'e.id = ue.emprendimiento_id')
                ->where('ue.usuario_id', $user['id'])
                ->where('e.activo', 1)
                ->where('e.fec_eliminacion', null)
                ->get()
                ->getResultArray();

            if (count($assignments) !== 1) {
                log_message('warning', 'Login denied because user {userId} does not have exactly one active tenant.', [
                    'userId' => $user['id'],
                ]);

                return redirect()->back()->withInput()->with('error', 'La cuenta no tiene un emprendimiento activo asignado.');
            }

            $tenantKey = $assignments[0]['database_key'];
            $assignedBusinesses = $assignments;

            if (! is_string($tenantKey) || $tenantKey === '') {
                log_message('warning', 'Login denied because user {userId} has an invalid tenant assignment.', [
                    'userId' => $user['id'],
                ]);

                return redirect()->back()->withInput()->with('error', 'La cuenta no tiene un emprendimiento activo asignado.');
            }

            try {
                (new TenantDatabase())->connectionForKey($tenantKey)->initialize();
            } catch (\RuntimeException) {
                log_message('error', 'Tenant database connection failed during login for user {userId}.', [
                    'userId' => $user['id'],
                ]);

                return redirect()->back()->withInput()->with(
                    'error',
                    'No fue posible acceder a la base del emprendimiento. Verifica la configuración del servidor.',
                );
            }
        } elseif ($user['rol'] !== 'admin') {
            return redirect()->back()->withInput()->with('error', 'El rol de esta cuenta no puede iniciar sesión.');
        }

        session()->regenerate(true);
        $displayName = trim(($user['nombre'] ?? '') . ' ' . ($user['apellido'] ?? ''));
        if ($displayName === '') {
            $displayName = $user['usuario'] ?: $user['correo'];
        }
        session()->set([
            'user_id' => (int) $user['id'],
            'user_role' => $user['rol'],
            'tenant_database_key' => $tenantKey,
            'auth_user' => ['name' => $displayName],
            'auth_businesses' => $assignedBusinesses,
            'current_business_id' => (int) ($assignedBusinesses[0]['id'] ?? 0),
        ]);

        $home = match ($user['rol']) {
            'admin' => 'admin',
            'empleado' => 'empleado',
            default => 'emprendedor',
        };

        return redirect()->to(site_url($home));
    }

    public function logout(): RedirectResponse
    {
        session()->destroy();

        return redirect()->to(site_url('login'));
    }
}
