<?php

namespace App\Controllers;

use App\Libraries\TenantDatabase;
use App\Models\UsuarioModel;
use CodeIgniter\Database\Exceptions\DatabaseException;
use CodeIgniter\HTTP\RedirectResponse;
use RuntimeException;

class AuthController extends BaseController
{
    protected $helpers = ['form', 'url'];

    public function index(): string|RedirectResponse
    {
        if (session()->has('auth_user')) {
            if (session('auth_user')['must_change_password'] ?? false) {
                return redirect()->to(site_url('cuenta/cambiar-clave'));
            }

            return redirect()->to($this->homeForRole(session('auth_user')['role']));
        }

        return view('auth/login', ['error' => session()->getFlashdata('auth_error')]);
    }

    public function attempt(): RedirectResponse
    {
        $emailInput = $this->request->getPost('correo');
        $passwordInput = $this->request->getPost('password');
        if (! is_string($emailInput) || ! is_string($passwordInput)) {
            return redirect()->to(site_url('login'))->with('auth_error', 'Ingresa un correo y una contraseña válidos.');
        }

        $email = mb_strtolower(trim($emailInput));
        $password = $passwordInput;

        if (! filter_var($email, FILTER_VALIDATE_EMAIL) || strlen($email) > 190 || $password === '' || strlen($password) > 72) {
            return redirect()->to(site_url('login'))->with('auth_error', 'Ingresa un correo y una contraseña válidos.');
        }

        $users = new UsuarioModel();
        try {
            $user = $users->findActiveByEmail($email);
        } catch (DatabaseException $exception) {
            log_message('error', 'No se pudo consultar la base central durante el inicio de sesión: {message}', ['message' => $exception->getMessage()]);

            return redirect()->to(site_url('login'))->with('auth_error', 'No se pudo conectar con la base central. Verifica la configuración de MySQL.');
        }

        if ($user === null || ! password_verify($password, $user['password_hash'])) {
            return redirect()->to(site_url('login'))->with('auth_error', 'El correo o la contraseña no son correctos.');
        }

        $role = $this->normalizeRole($user['rol_nombre']);

        if ($role === null) {
            return redirect()->to(site_url('login'))->with('auth_error', 'El usuario no tiene un rol habilitado para acceder.');
        }

        try {
            $businesses = $role === 'admin'
                ? $users->findActiveBusinesses()
                : $users->findBusinesses((int) $user['id']);
        } catch (DatabaseException $exception) {
            log_message('error', 'No se pudieron consultar los emprendimientos autorizados: {message}', ['message' => $exception->getMessage()]);

            return redirect()->to(site_url('login'))->with('auth_error', 'No se pudo consultar la configuración de los emprendimientos. Ejecuta las migraciones y vuelve a intentarlo.');
        }
        if ($role !== 'admin' && $businesses === []) {
            return redirect()->to(site_url('login'))->with('auth_error', 'La cuenta no tiene un emprendimiento activo asociado.');
        }

        if ($businesses !== []) {
            $tenantDatabase = new TenantDatabase();
            try {
                foreach ($businesses as $business) {
                    if (! is_string($business['tenant_key'] ?? null)) {
                        throw new RuntimeException('El emprendimiento no tiene asignada una base operativa.');
                    }

                    $tenantDatabase->verifyConnection($business['tenant_key']);
                }
            } catch (RuntimeException $exception) {
                log_message('error', 'No se pudo verificar la base operativa al iniciar sesión: {message}', ['message' => $exception->getMessage()]);

                return redirect()->to(site_url('login'))->with('auth_error', 'No se pudo conectar con la base del emprendimiento. Verifica su configuración e inténtalo de nuevo.');
            }
        }

        try {
            $users->recordLogin((int) $user['id']);
        } catch (DatabaseException $exception) {
            log_message('error', 'No se pudo registrar el acceso en la base central: {message}', ['message' => $exception->getMessage()]);

            return redirect()->to(site_url('login'))->with('auth_error', 'No se pudo completar el acceso. Verifica la conexión con la base central.');
        }

        usort($businesses, static function (array $left, array $right): int {
            $priority = ['don_goyo' => 0, 'razu' => 1, 'dulce_mora' => 2];

            return ($priority[$left['tenant_key'] ?? ''] ?? 3) <=> ($priority[$right['tenant_key'] ?? ''] ?? 3);
        });

        session()->regenerate(true);
        session()->set([
            'auth_user' => [
                'id' => (int) $user['id'],
                'name' => trim($user['nombre'] . ' ' . ($user['apellido'] ?? '')),
                'email' => $user['correo'],
                'role' => $role,
                'must_change_password' => (bool) ($user['debe_cambiar_clave'] ?? false),
            ],
            'auth_businesses' => $businesses,
            'current_business_id' => $businesses === [] ? null : (int) $businesses[0]['id'],
        ]);

        return redirect()->to(
            session('auth_user')['must_change_password'] ? site_url('cuenta/cambiar-clave') : $this->homeForRole($role),
        );
    }

    public function logout(): RedirectResponse
    {
        session()->remove(['auth_user', 'auth_businesses', 'current_business_id']);
        session()->destroy();

        return redirect()->to(site_url('login'));
    }

    public function switchBusiness(): RedirectResponse
    {
        $authUser = session('auth_user');
        $businessInput = $this->request->getPost('emprendimiento_id');
        $businessId = is_string($businessInput) ? filter_var($businessInput, FILTER_VALIDATE_INT) : false;

        if ($authUser === null || $businessId === false || $businessId < 1) {
            return redirect()->back()->with('auth_error', 'Selecciona un emprendimiento válido.');
        }

        try {
            $users = new UsuarioModel();
            $business = $authUser['role'] === 'admin'
                ? $users->findActiveBusiness($businessId)
                : $users->findBusinessForUser((int) $authUser['id'], $businessId);
        } catch (DatabaseException $exception) {
            log_message('error', 'No se pudo verificar el emprendimiento seleccionado: {message}', ['message' => $exception->getMessage()]);

            return redirect()->back()->with('auth_error', 'No se pudo verificar el acceso al emprendimiento.');
        }
        if ($business === null) {
            return redirect()->to($this->homeForRole($authUser['role']));
        }
        if (! is_string($business['tenant_key'] ?? null)) {
            return redirect()->back()->with('auth_error', 'El emprendimiento seleccionado no tiene una base operativa asignada.');
        }

        try {
            (new TenantDatabase())->verifyConnection($business['tenant_key']);
        } catch (RuntimeException $exception) {
            log_message('error', 'No se pudo cambiar a la base operativa seleccionada: {message}', ['message' => $exception->getMessage()]);

            return redirect()->back()->with('auth_error', 'No se pudo conectar con la base de ese emprendimiento.');
        }

        session()->set('current_business_id', (int) $business['id']);

        return redirect()->to($this->homeForRole($authUser['role']));
    }

    private function normalizeRole(string $role): ?string
    {
        return match (mb_strtolower(trim($role))) {
            'admin' => 'admin',
            'propietario' => 'propietario',
            'empleado' => 'empleado',
            default => null,
        };
    }

    private function homeForRole(string $role): string
    {
        return match ($role) {
            'admin' => site_url('admin'),
            'empleado' => site_url('empleado'),
            default => site_url('emprendedor'),
        };
    }
}
