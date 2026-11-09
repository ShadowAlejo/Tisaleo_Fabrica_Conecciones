<?php

namespace App\Database\Seeds;

use CodeIgniter\CLI\CLI;
use CodeIgniter\Database\Seeder;
use RuntimeException;

class PropietariosSeeder extends Seeder
{
    /**
     * @var list<array{key: string, email_key: string, password_key: string, email: string, name: string, surname: string, business_name: string, category: string}>
     */
    private array $accounts = [
        [
            'key' => 'don_goyo',
            'email_key' => 'TISALEO_OWNER_DON_GOYO_EMAIL',
            'password_key' => 'TISALEO_OWNER_DON_GOYO_PASSWORD',
            'email' => 'propietario.dongoyo@tisaleo.local',
            'name' => 'Propietario',
            'surname' => 'Don Goyo',
            'business_name' => 'Turrones- Don Goyo',
            'category' => 'Artesanal',
        ],
        [
            'key' => 'razu',
            'email_key' => 'TISALEO_OWNER_RAZU_EMAIL',
            'password_key' => 'TISALEO_OWNER_RAZU_PASSWORD',
            'email' => 'propietario.razu@tisaleo.local',
            'name' => 'Propietario',
            'surname' => 'RaZu',
            'business_name' => 'Razu - Corp',
            'category' => 'Agropecuario',
        ],
        [
            'key' => 'dulce_mora',
            'email_key' => 'TISALEO_OWNER_DULCE_MORA_EMAIL',
            'password_key' => 'TISALEO_OWNER_DULCE_MORA_PASSWORD',
            'email' => 'propietario.dulcemora@tisaleo.local',
            'name' => 'Propietario',
            'surname' => 'Dulce Mora',
            'business_name' => 'Bodega G&A "Dulce Mora"',
            'category' => 'Agropecuario',
        ],
    ];

    public function run(): void
    {
        $validatedAccounts = [];
        foreach ($this->accounts as $account) {
            $email = mb_strtolower(trim((string) env($account['email_key'], $account['email'])));
            $password = (string) env($account['password_key'], '');

            if (! filter_var($email, FILTER_VALIDATE_EMAIL) || mb_strlen($password) < 8 || mb_strlen($password) > 10) {
                throw new RuntimeException('Configura un correo válido y una contraseña de 8 a 10 caracteres para cada cuenta de propietario en .env.');
            }

            $validatedAccounts[] = [$account, $email, $password];
        }

        $this->db->transBegin();

        try {
            $roleId = $this->findOrCreateOwnerRole();

            foreach ($validatedAccounts as [$account, $email, $password]) {
                $businessId = $this->findOrCreateBusiness($account);
                $userId = $this->findOrCreateOwner($account, $email, $password, $roleId, $businessId);
                $this->linkOwnerToBusiness($userId, $businessId);
            }

            if (! $this->db->transStatus()) {
                throw new RuntimeException('No se pudieron guardar las cuentas de propietario.');
            }

            $this->db->transCommit();
            CLI::write('Se procesaron las tres cuentas de propietario. Las cuentas existentes conservaron su contraseña.', 'green');
        } catch (\Throwable $exception) {
            $this->db->transRollback();
            throw $exception;
        }
    }

    private function findOrCreateOwnerRole(): int
    {
        $role = $this->db->table('roles')->where('nombre', 'propietario')->get()->getRowArray();
        if ($role !== null) {
            return (int) $role['id'];
        }

        $this->db->table('roles')->insert([
            'nombre' => 'propietario',
            'descripcion' => 'Propietario de un emprendimiento',
        ]);

        return (int) $this->db->insertID();
    }

    /**
     * @param array{key: string, email_key: string, password_key: string, email: string, name: string, surname: string, business_name: string, category: string} $account
     */
    private function findOrCreateBusiness(array $account): int
    {
        $business = $this->db->table('emprendimientos')
            ->where('database_key', $account['key'])
            ->get()
            ->getRowArray();

        if ($business === null) {
            $business = $this->db->table('emprendimientos')
                ->where('nombre', $account['business_name'])
                ->get()
                ->getRowArray();
        }

        if ($business !== null) {
            if ((int) $business['activo'] !== 1 || $business['fec_eliminacion'] !== null) {
                throw new RuntimeException('El emprendimiento existente "' . $account['business_name'] . '" está inactivo o eliminado.');
            }

            if ($business['database_key'] !== null && $business['database_key'] !== $account['key']) {
                throw new RuntimeException('El emprendimiento "' . $account['business_name'] . '" ya está asignado a otra base operativa.');
            }

            $this->db->table('emprendimientos')
                ->where('id', $business['id'])
                ->update(['database_key' => $account['key']]);

            return (int) $business['id'];
        }

        $this->db->table('emprendimientos')->insert([
            'nombre' => $account['business_name'],
            'categoria' => $account['category'],
            'database_key' => $account['key'],
        ]);

        return (int) $this->db->insertID();
    }

    /**
     * @param array{key: string, email_key: string, password_key: string, email: string, name: string, surname: string, business_name: string, category: string} $account
     */
    private function findOrCreateOwner(array $account, string $email, string $password, int $roleId, int $businessId): int
    {
        $existing = $this->db->table('usuarios')->where('correo', $email)->get()->getRowArray();

        if ($existing !== null) {
            if ((int) $existing['rol_id'] !== $roleId || (int) $existing['activo'] !== 1 || $existing['fec_eliminacion'] !== null) {
                throw new RuntimeException('El correo configurado para ' . $account['key'] . ' ya pertenece a otra cuenta o está inactivo.');
            }

            if ($existing['emprendimiento_id'] !== null && (int) $existing['emprendimiento_id'] !== $businessId) {
                throw new RuntimeException('La cuenta de propietario para ' . $account['key'] . ' ya está asociada a otro emprendimiento.');
            }

            $otherBusiness = $this->db->table('usuario_emprendimientos')
                ->where('usuario_id', $existing['id'])
                ->where('emprendimiento_id !=', $businessId)
                ->countAllResults();
            if ($otherBusiness > 0) {
                throw new RuntimeException('La cuenta de propietario para ' . $account['key'] . ' ya tiene acceso a otro emprendimiento.');
            }

            $updates = [];
            if ($existing['emprendimiento_id'] === null) {
                $updates['emprendimiento_id'] = $businessId;
            }
            if (password_verify($password, $existing['password_hash'])) {
                $updates['debe_cambiar_clave'] = 1;
            }
            if ($updates !== []) {
                $this->db->table('usuarios')->where('id', $existing['id'])->update($updates);
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

    private function linkOwnerToBusiness(int $userId, int $businessId): void
    {
        $exists = $this->db->table('usuario_emprendimientos')
            ->where('usuario_id', $userId)
            ->where('emprendimiento_id', $businessId)
            ->countAllResults();

        if ($exists === 0) {
            $this->db->table('usuario_emprendimientos')->insert([
                'usuario_id' => $userId,
                'emprendimiento_id' => $businessId,
            ]);
        }
    }
}
