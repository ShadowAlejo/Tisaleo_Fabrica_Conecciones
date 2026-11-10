<?php

namespace App\Database\Seeds;

use CodeIgniter\CLI\CLI;
use CodeIgniter\Database\Seeder;
use RuntimeException;

class AdminSeeder extends Seeder
{
    public function run(): void
    {
        $email = mb_strtolower(trim((string) env('TISALEO_OWNER_EMAIL', '')));
        $password = (string) env('TISALEO_OWNER_PASSWORD', '');

        if (! filter_var($email, FILTER_VALIDATE_EMAIL) || mb_strlen($password) < 8 || mb_strlen($password) > 10) {
            throw new RuntimeException('Configura TISALEO_OWNER_EMAIL y una TISALEO_OWNER_PASSWORD de 8 a 10 caracteres en .env.');
        }
        if (! $this->db->fieldExists('usuario', 'usuarios') || ! $this->db->fieldExists('nombre', 'usuarios')) {
            throw new RuntimeException('Ejecuta php spark migrate antes de crear o actualizar la cuenta administrativa.');
        }

        $this->db->transBegin();

        try {
            $roleId = $this->findOrCreateAdminRole();
            $this->findOrCreateAdmin($email, $password, $roleId);

            if (! $this->db->transStatus()) {
                throw new RuntimeException('No se pudo guardar la cuenta administrativa.');
            }

            $this->db->transCommit();
            CLI::write('Se procesó la cuenta Administrador. La contraseña existente se conservó.', 'green');
        } catch (\Throwable $exception) {
            $this->db->transRollback();
            throw $exception;
        }
    }

    private function findOrCreateAdminRole(): int
    {
        $role = $this->db->table('roles')->where('nombre', 'admin')->get()->getRowArray();
        if ($role !== null) {
            return (int) $role['id'];
        }

        $this->db->table('roles')->insert([
            'nombre' => 'admin',
            'descripcion' => 'Administrador del sistema',
        ]);

        return (int) $this->db->insertID();
    }

    private function findOrCreateAdmin(string $email, string $password, int $roleId): void
    {
        $existing = $this->db->table('usuarios')->where('correo', $email)->get()->getRowArray();

        if ($existing !== null) {
            if ((int) $existing['rol_id'] !== $roleId || (int) $existing['activo'] !== 1 || $existing['fec_eliminacion'] !== null) {
                throw new RuntimeException('El correo configurado ya existe y no corresponde a una cuenta administrativa activa.');
            }

            $usernameOwner = $this->db->table('usuarios')
                ->where('usuario', 'Administrador')
                ->where('id !=', $existing['id'])
                ->get()
                ->getRowArray();
            if ($usernameOwner !== null) {
                throw new RuntimeException('El usuario Administrador ya está asignado a otra cuenta.');
            }

            $this->db->table('usuarios')->where('id', $existing['id'])->update([
                'emprendimiento_id' => null,
                'nombre' => null,
                'apellido' => null,
                'usuario' => 'Administrador',
            ]);
            $this->db->table('usuario_emprendimientos')->where('usuario_id', $existing['id'])->delete();

            return;
        }

        if ($this->db->table('usuarios')->where('usuario', 'Administrador')->countAllResults() > 0) {
            throw new RuntimeException('El usuario Administrador ya está asignado a otra cuenta.');
        }

        $this->db->table('usuarios')->insert([
            'rol_id' => $roleId,
            'emprendimiento_id' => null,
            'nombre' => null,
            'apellido' => null,
            'usuario' => 'Administrador',
            'correo' => $email,
            'password_hash' => password_hash($password, PASSWORD_DEFAULT),
            'debe_cambiar_clave' => 1,
            'activo' => 1,
        ]);
    }
}
