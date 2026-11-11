<?php

namespace App\Database\Seeds;

use CodeIgniter\CLI\CLI;
use CodeIgniter\Database\Seeder;
use RuntimeException;

class AdminSeeder extends Seeder
{
    private const USERNAME = 'admin';
    private const EMAIL = 'admin@tisaleo.local';

    public function run(): void
    {
        if (ENVIRONMENT !== 'development') {
            throw new RuntimeException('Los seeders de desarrollo solo se permiten en el entorno development.');
        }

        foreach (['roles', 'usuarios'] as $table) {
            if (! $this->db->tableExists($table)) {
                throw new RuntimeException('No existe la tabla central "' . $table . '". Importa primero el esquema de usuarios_tisaleo.');
            }
        }

        $role = $this->db->table('roles')
            ->select('id')
            ->where('nombre', 'admin')
            ->where('fec_eliminacion', null)
            ->get()
            ->getRowArray();

        if ($role === null) {
            throw new RuntimeException('No existe el rol admin. Ejecuta primero RolesSeeder.');
        }

        $byUsername = $this->db->table('usuarios')
            ->where('usuario', self::USERNAME)
            ->get()
            ->getRowArray();
        $byEmail = $this->db->table('usuarios')
            ->where('correo', self::EMAIL)
            ->get()
            ->getRowArray();

        if (
            $byUsername !== null
            && $byEmail !== null
            && (int) $byUsername['id'] !== (int) $byEmail['id']
        ) {
            throw new RuntimeException('El usuario admin o su correo ya están asignados a cuentas diferentes.');
        }

        $existing = $byUsername ?? $byEmail;

        $resetPassword = filter_var(env('TISALEO_ADMIN_RESET_PASSWORD', false), FILTER_VALIDATE_BOOLEAN);

        if ($existing !== null) {
            if ((int) $existing['rol_id'] !== (int) $role['id']) {
                throw new RuntimeException('La cuenta admin ya existe, pero no tiene el rol administrador; no se modificó.');
            }

            if (! $resetPassword) {
                CLI::write('La cuenta admin ya existe. No se modificó la contraseña.', 'yellow');

                return;
            }
        }

        $password = rtrim(strtr(base64_encode(random_bytes(24)), '+/', '-_'), '=');
        $passwordHash = password_hash($password, PASSWORD_DEFAULT);

        if ($passwordHash === false) {
            throw new RuntimeException('No se pudo generar el hash de la contraseña del administrador.');
        }

        $userData = [
            'rol_id' => $role['id'],
            'emprendimiento_id' => null,
            'nombre' => 'Administrador',
            'apellido' => 'Tisaleo',
            'usuario' => self::USERNAME,
            'correo' => self::EMAIL,
            'telefono' => null,
            'password_hash' => $passwordHash,
            'debe_cambiar_clave' => 0,
            'activo' => 1,
            'fec_eliminacion' => null,
        ];

        if ($existing === null) {
            $this->db->table('usuarios')->insert($userData);
            $userId = (int) $this->db->insertID();
        } else {
            $userId = (int) $existing['id'];
            $this->db->table('usuarios')->where('id', $userId)->update($userData);
        }

        $storedUser = $this->db->table('usuarios')
            ->select('password_hash, rol_id, activo')
            ->where('id', $userId)
            ->get()
            ->getRowArray();

        if (
            $storedUser === null
            || (int) $storedUser['rol_id'] !== (int) $role['id']
            || (int) $storedUser['activo'] !== 1
            || ! password_verify($password, $storedUser['password_hash'])
        ) {
            throw new RuntimeException('No se pudo verificar la cuenta y el hash del administrador.');
        }

        CLI::write(
            $existing === null
                ? 'Administrador creado. Guarda estas credenciales; la contraseña no volverá a mostrarse:'
                : 'Contraseña del administrador restablecida. Guarda la nueva clave; no volverá a mostrarse:',
            'green',
        );
        CLI::write('Usuario: ' . self::USERNAME);
        CLI::write('Correo: ' . self::EMAIL);
        CLI::write('Contraseña: ' . $password);
    }
}
