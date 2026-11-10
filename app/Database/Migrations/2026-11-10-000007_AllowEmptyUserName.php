<?php

namespace App\Database\Migrations;

use CodeIgniter\Database\Migration;

class AllowEmptyUserName extends Migration
{
    public function up(): void
    {
        $this->forge->modifyColumn('usuarios', [
            'nombre' => [
                'type' => 'VARCHAR',
                'constraint' => 100,
                'null' => true,
            ],
        ]);
    }

    public function down(): void
    {
        if ($this->db->table('usuarios')->where('nombre IS NULL')->countAllResults() > 0) {
            throw new \RuntimeException('No se puede exigir nombre mientras existan cuentas sin ese dato.');
        }

        $this->forge->modifyColumn('usuarios', [
            'nombre' => [
                'type' => 'VARCHAR',
                'constraint' => 100,
                'null' => false,
            ],
        ]);
    }
}
