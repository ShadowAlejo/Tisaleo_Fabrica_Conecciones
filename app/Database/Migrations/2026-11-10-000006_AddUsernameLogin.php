<?php

namespace App\Database\Migrations;

use CodeIgniter\Database\Migration;
use RuntimeException;

class AddUsernameLogin extends Migration
{
    public function up(): void
    {
        if (! $this->db->fieldExists('usuario', 'usuarios')) {
            $this->forge->addColumn('usuarios', [
                'usuario' => [
                    'type' => 'VARCHAR',
                    'constraint' => 80,
                    'null' => true,
                    'after' => 'apellido',
                ],
            ]);
            $this->forge->addKey('usuario', false, true, 'uq_usuarios_usuario');
            $this->forge->processIndexes('usuarios');
        }

        $this->forge->modifyColumn('usuarios', [
            'correo' => [
                'type' => 'VARCHAR',
                'constraint' => 254,
                'null' => true,
            ],
        ]);
    }

    public function down(): void
    {
        if (! $this->db->fieldExists('usuario', 'usuarios')) {
            return;
        }

        if ($this->db->table('usuarios')->where('usuario IS NOT NULL')->countAllResults() > 0) {
            throw new RuntimeException('No se puede revertir el inicio de sesión por usuario mientras existan cuentas importadas.');
        }

        $this->db->query('ALTER TABLE usuarios DROP INDEX uq_usuarios_usuario');
        $this->forge->dropColumn('usuarios', 'usuario');
    }
}
