<?php

namespace App\Database\Seeds;

use CodeIgniter\CLI\CLI;
use CodeIgniter\Database\Seeder;
use RuntimeException;

class ActualizarClaveAdminSeeder extends Seeder
{
    public function run(): void
    {
        $email = mb_strtolower(trim((string) env('TISALEO_OWNER_EMAIL', '')));
        $password = (string) env('TISALEO_OWNER_PASSWORD', '');

        if (! filter_var($email, FILTER_VALIDATE_EMAIL) || mb_strlen($password) < 8 || mb_strlen($password) > 10) {
            throw new RuntimeException('Configura TISALEO_OWNER_EMAIL y una contraseña de administrador de 8 a 10 caracteres en .env.');
        }

        $admin = $this->db->table('usuarios')
            ->select('usuarios.id, usuarios.activo, usuarios.fec_eliminacion, roles.nombre AS rol_nombre')
            ->join('roles', 'roles.id = usuarios.rol_id')
            ->where('usuarios.correo', $email)
            ->get()
            ->getRowArray();

        if (
            $admin === null
            || (int) $admin['activo'] !== 1
            || $admin['fec_eliminacion'] !== null
            || $admin['rol_nombre'] !== 'admin'
        ) {
            throw new RuntimeException('No se encontró una cuenta administrativa activa con el correo configurado.');
        }

        $this->db->transBegin();

        try {
            $this->db->table('usuarios')
                ->where('id', $admin['id'])
                ->update(['password_hash' => password_hash($password, PASSWORD_DEFAULT)]);

            if (! $this->db->transStatus()) {
                throw new RuntimeException('No se pudo actualizar la contraseña administrativa.');
            }

            $this->db->transCommit();
            CLI::write('La contraseña administrativa se actualizó correctamente.', 'green');
        } catch (\Throwable $exception) {
            $this->db->transRollback();
            throw $exception;
        }
    }
}
