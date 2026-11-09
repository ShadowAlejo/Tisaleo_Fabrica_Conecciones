<?php

namespace App\Controllers;

use CodeIgniter\Database\Exceptions\DatabaseException;
use CodeIgniter\HTTP\RedirectResponse;

class CuentaController extends BaseController
{
    public function edit(): string|RedirectResponse
    {
        if (! session()->has('auth_user')) {
            return redirect()->to(site_url('login'));
        }

        return view('cuenta/cambiar_clave', [
            'errors' => session()->getFlashdata('errors') ?? [],
        ]);
    }

    public function update(): RedirectResponse
    {
        $user = session('auth_user');
        if (! is_array($user) || ! isset($user['id'])) {
            return redirect()->to(site_url('login'));
        }

        $password = $this->request->getPost('password');
        $confirmation = $this->request->getPost('password_confirm');
        $errors = [];

        if (! is_string($password) || mb_strlen($password) < 8 || mb_strlen($password) > 10) {
            $errors['password'] = 'La contraseña debe tener entre 8 y 10 caracteres.';
        }
        if (! is_string($confirmation) || $password !== $confirmation) {
            $errors['password_confirm'] = 'Las contraseñas no coinciden.';
        }

        if ($errors !== []) {
            return redirect()->back()->with('errors', $errors);
        }

        try {
            $updated = db_connect()->table('usuarios')
                ->where('id', (int) $user['id'])
                ->where('activo', 1)
                ->where('fec_eliminacion', null)
                ->update([
                    'password_hash' => password_hash($password, PASSWORD_DEFAULT),
                    'debe_cambiar_clave' => 0,
                ]);
        } catch (DatabaseException $exception) {
            log_message('error', 'No se pudo actualizar la contraseña del usuario: {message}', ['message' => $exception->getMessage()]);

            return redirect()->back()->with('auth_error', 'No se pudo guardar la contraseña. Inténtalo nuevamente.');
        }

        if (! $updated) {
            return redirect()->back()->with('auth_error', 'No se pudo guardar la contraseña.');
        }

        $user['must_change_password'] = false;
        session()->set('auth_user', $user);

        $destination = match ($user['role']) {
            'admin' => site_url('admin'),
            'empleado' => site_url('empleado'),
            default => site_url('emprendedor'),
        };

        return redirect()->to($destination)
            ->with('success', 'Tu contraseña fue actualizada.');
    }
}
