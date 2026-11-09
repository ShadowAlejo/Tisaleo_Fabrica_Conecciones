<?php

namespace App\Filters;

use CodeIgniter\Filters\FilterInterface;
use CodeIgniter\Database\Exceptions\DatabaseException;
use CodeIgniter\HTTP\RequestInterface;
use CodeIgniter\HTTP\ResponseInterface;

class AuthFilter implements FilterInterface
{
    public function before(RequestInterface $request, $arguments = null)
    {
        helper('url');
        $user = session('auth_user');
        if (! is_array($user) || ! isset($user['role'])) {
            return redirect()->to(site_url('login'));
        }

        $segments = $request->getUri()->getSegments();
        $requestedPath = implode('/', array_slice($segments, 0, 2));
        if (($user['must_change_password'] ?? false) && ! in_array($requestedPath, ['cuenta/cambiar-clave', 'logout'], true)) {
            return redirect()->to(site_url('cuenta/cambiar-clave'));
        }

        $requiredRole = match ($segments[0] ?? '') {
            'admin' => 'admin',
            'empleado' => 'empleado',
            'emprendedor' => 'emprendedor',
            default => null,
        };

        $allowed = match ($requiredRole) {
            'admin' => $user['role'] === 'admin',
            'emprendedor' => in_array($user['role'], ['admin', 'propietario', 'empleado'], true),
            'empleado' => $user['role'] === 'empleado',
            default => true,
        };

        if (
            $allowed
            && $user['role'] === 'empleado'
            && ($segments[0] ?? '') === 'emprendedor'
            && ($segments[1] ?? '') === 'empleados'
        ) {
            $allowed = false;
        }

        if (! $allowed) {
            return redirect()->to(match ($user['role']) {
                'admin' => site_url('admin'),
                'empleado' => site_url('empleado'),
                default => site_url('emprendedor'),
            });
        }

        if (in_array($segments[0] ?? '', ['emprendedor', 'empleado'], true)) {
            $businessId = (int) session('current_business_id');

            try {
                if ($user['role'] === 'admin') {
                    $business = db_connect()->table('emprendimientos')
                        ->select('id, nombre, database_key AS tenant_key, usa_productos, usa_servicios')
                        ->where('id', $businessId)
                        ->where('activo', 1)
                        ->where('fec_eliminacion', null)
                        ->get()
                        ->getRowArray();
                } else {
                    $business = db_connect()->table('usuarios AS u')
                        ->select('e.id, e.nombre, e.database_key AS tenant_key, e.usa_productos, e.usa_servicios')
                        ->join('emprendimientos AS e', 'e.id = u.emprendimiento_id')
                        ->where('u.id', (int) $user['id'])
                        ->where('u.activo', 1)
                        ->where('u.fec_eliminacion', null)
                        ->where('e.activo', 1)
                        ->where('e.fec_eliminacion', null)
                        ->get()
                        ->getRowArray();
                }
            } catch (DatabaseException $exception) {
                log_message('error', 'No se pudo verificar el emprendimiento activo de la sesión: {message}', ['message' => $exception->getMessage()]);

                return redirect()->to(site_url('login'))->with('auth_error', 'No se pudo verificar el emprendimiento activo.');
            }

            if ($business === null) {
                return redirect()->to($user['role'] === 'admin' ? site_url('admin') : site_url('login'))
                    ->with('auth_error', 'La cuenta no tiene acceso a ese emprendimiento.');
            }

            if ($user['role'] !== 'admin') {
                $business['id'] = (int) $business['id'];
                $business['usa_productos'] = (bool) $business['usa_productos'];
                $business['usa_servicios'] = (bool) $business['usa_servicios'];
                session()->set([
                    'auth_businesses' => [$business],
                    'current_business_id' => $business['id'],
                ]);
            }
        }

        return null;
    }

    public function after(RequestInterface $request, ResponseInterface $response, $arguments = null)
    {
    }
}
