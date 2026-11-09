<?php

namespace App\Database\Seeds;

use CodeIgniter\CLI\CLI;
use CodeIgniter\Database\Seeder;
use RuntimeException;

class CuentasEmpleadosSeeder extends Seeder
{
    /**
     * @var list<array{key: string, email_key: string, password_key: string, email: string, name: string, surname: string}>
     */
    private array $accounts = [
        [
            'key' => 'don_goyo',
            'email_key' => 'TISALEO_STAFF_DON_GOYO_EMAIL',
            'password_key' => 'TISALEO_STAFF_DON_GOYO_PASSWORD',
            'email' => 'empleado.dongoyo@tisaleo.local',
            'name' => 'Empleado',
            'surname' => 'Don Goyo',
        ],
        [
            'key' => 'razu',
            'email_key' => 'TISALEO_STAFF_RAZU_EMAIL',
            'password_key' => 'TISALEO_STAFF_RAZU_PASSWORD',
            'email' => 'empleado.razu@tisaleo.local',
            'name' => 'Empleado',
            'surname' => 'RaZu',
        ],
        [
            'key' => 'dulce_mora',
            'email_key' => 'TISALEO_STAFF_DULCE_MORA_EMAIL',
            'password_key' => 'TISALEO_STAFF_DULCE_MORA_PASSWORD',
            'email' => 'empleado.dulcemora@tisaleo.local',
            'name' => 'Empleado',
            'surname' => 'Dulce Mora',
        ],
    ];

    public function run(): void
    {
        $validatedAccounts = [];
        foreach ($this->accounts as $account) {
            $email = mb_strtolower(trim((string) env($account['email_key'], $account['email'])));
            $password = (string) env($account['password_key'], '');

            if (! filter_var($email, FILTER_VALIDATE_EMAIL) || mb_strlen($password) < 8 || mb_strlen($password) > 10) {
                throw new RuntimeException('Configura un correo válido y una contraseña de 8 a 10 caracteres para cada cuenta de empleado en .env.');
            }

            $validatedAccounts[] = [$account, $email, $password];
        }

        $this->db->transBegin();

        try {
            $roleId = $this->findOrCreateEmployeeRole();
            foreach ($validatedAccounts as [$account, $email, $password]) {
                $business = $this->db->table('emprendimientos')
                    ->select('id, nombre')
                    ->where('database_key', $account['key'])
                    ->where('activo', 1)
                    ->where('fec_eliminacion', null)
                    ->get()
                    ->getRowArray();

                if ($business === null) {
                    throw new RuntimeException('No se encontró el emprendimiento activo para la cuenta ' . $account['key'] . '. Ejecuta primero PropietariosSeeder.');
                }

                $userId = $this->findOrCreateEmployee($account, $email, $password, $roleId, (int) $business['id']);
                $this->linkEmployeeToBusiness($userId, (int) $business['id']);
            }

            if (! $this->db->transStatus()) {
                throw new RuntimeException('No se pudieron guardar las cuentas de empleado.');
            }

            $this->db->transCommit();
            CLI::write('Se procesaron las tres cuentas de empleado. Las cuentas existentes conservaron su contraseña.', 'green');
        } catch (\Throwable $exception) {
            $this->db->transRollback();
            throw $exception;
        }
    }

    private function findOrCreateEmployeeRole(): int
    {
        $role = $this->db->table('roles')->where('nombre', 'empleado')->get()->getRowArray();
        if ($role !== null) {
            return (int) $role['id'];
        }

        $this->db->table('roles')->insert([
            'nombre' => 'empleado',
            'descripcion' => 'Empleado con acceso al punto de venta de su emprendimiento',
        ]);

        return (int) $this->db->insertID();
    }

    /**
     * @param array{key: string, email_key: string, password_key: string, email: string, name: string, surname: string} $account
     */
    private function findOrCreateEmployee(array $account, string $email, string $password, int $roleId, int $businessId): int
    {
        $existing = $this->db->table('usuarios')->where('correo', $email)->get()->getRowArray();

        if ($existing !== null) {
            if ((int) $existing['rol_id'] !== $roleId || (int) $existing['activo'] !== 1 || $existing['fec_eliminacion'] !== null) {
                throw new RuntimeException('El correo configurado para ' . $account['key'] . ' ya pertenece a otra cuenta o está inactivo.');
            }

            if ($existing['emprendimiento_id'] !== null && (int) $existing['emprendimiento_id'] !== $businessId) {
                throw new RuntimeException('La cuenta de ' . $account['key'] . ' ya está asociada a otro emprendimiento.');
            }

            $otherBusiness = $this->db->table('usuario_emprendimientos')
                ->where('usuario_id', $existing['id'])
                ->where('emprendimiento_id !=', $businessId)
                ->countAllResults();
            if ($otherBusiness > 0) {
                throw new RuntimeException('La cuenta de ' . $account['key'] . ' ya tiene acceso a otro emprendimiento.');
            }

            if (password_verify($password, $existing['password_hash'])) {
                $this->db->table('usuarios')
                    ->where('id', $existing['id'])
                    ->update(['debe_cambiar_clave' => 1]);
            }

            return (int) $existing['id'];
        }

        $this->db->table('usuarios')->insert([
            'rol_id' => $roleId,
            'emprendimiento_id' => $businessId,
            'nombre' => $account['name'],
            'apellido' => $account['surname'],
            'correo' => $email,
            'password_hash' => password_hash($password, PASSWORD_DEFAULT),
            'debe_cambiar_clave' => 1,
            'activo' => 1,
        ]);

        return (int) $this->db->insertID();
    }

    private function linkEmployeeToBusiness(int $userId, int $businessId): void
    {
        $existing = $this->db->table('usuario_emprendimientos')
            ->where('usuario_id', $userId)
            ->where('emprendimiento_id', $businessId)
            ->countAllResults();

        if ($existing === 0) {
            $this->db->table('usuario_emprendimientos')->insert([
                'usuario_id' => $userId,
                'emprendimiento_id' => $businessId,
            ]);
        }
    }
}
