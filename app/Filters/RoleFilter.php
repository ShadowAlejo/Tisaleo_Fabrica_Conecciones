<?php

namespace App\Filters;

use CodeIgniter\Filters\FilterInterface;
use CodeIgniter\HTTP\RequestInterface;
use CodeIgniter\HTTP\ResponseInterface;

class RoleFilter implements FilterInterface
{
    public function before(RequestInterface $request, $arguments = null)
    {
        $role = session()->get('user_role');

        if (is_string($role) && in_array($role, $arguments ?? [], true)) {
            return null;
        }

        $home = match ($role) {
            'admin' => 'admin',
            'empleado' => 'empleado',
            'propietario' => 'emprendedor',
            default => 'login',
        };

        return redirect()->to(site_url($home))->with(
            'auth_error',
            'No tienes permiso para acceder a esta sección.',
        );
    }

    public function after(RequestInterface $request, ResponseInterface $response, $arguments = null)
    {
    }
}
