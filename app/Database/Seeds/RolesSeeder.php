<?php

namespace App\Database\Seeds;

use CodeIgniter\Database\Seeder;
use RuntimeException;

class RolesSeeder extends Seeder
{
    public function run(): void
    {
        $this->assertDevelopment();

        foreach ([
            ['nombre' => 'admin', 'descripcion' => 'Administrador del sistema'],
            ['nombre' => 'propietario', 'descripcion' => 'Propietario de un emprendimiento'],
            ['nombre' => 'empleado', 'descripcion' => 'Empleado de un emprendimiento'],
        ] as $role) {
            $existing = $this->db->table('roles')
                ->select('id')
                ->where('nombre', $role['nombre'])
                ->get()
                ->getRowArray();

            $role['fec_eliminacion'] = null;

            if ($existing === null) {
                $this->db->table('roles')->insert($role);

                continue;
            }

            $this->db->table('roles')->where('id', $existing['id'])->update($role);
        }
    }

    private function assertDevelopment(): void
    {
        if (ENVIRONMENT !== 'development') {
            throw new RuntimeException('Los seeders de desarrollo solo se permiten en el entorno development.');
        }
    }
}
