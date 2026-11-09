<?php

namespace App\Database\Migrations;

use CodeIgniter\Database\Migration;

class AddBusinessDescription extends Migration
{
    public function up(): void
    {
        if (! $this->db->fieldExists('descripcion', 'emprendimientos')) {
            $this->forge->addColumn('emprendimientos', [
                'descripcion' => [
                    'type' => 'TEXT',
                    'null' => true,
                    'after' => 'direccion',
                ],
            ]);
        }
    }

    public function down(): void
    {
        if ($this->db->fieldExists('descripcion', 'emprendimientos')) {
            $this->forge->dropColumn('emprendimientos', 'descripcion');
        }
    }
}
