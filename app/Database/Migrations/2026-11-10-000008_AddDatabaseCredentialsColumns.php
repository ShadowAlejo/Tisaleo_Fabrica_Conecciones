<?php

namespace App\Database\Migrations;

use CodeIgniter\Database\Migration;

class AddDatabaseCredentialsColumns extends Migration
{
    public function up(): void
    {
        // 1. Agregar credenciales de la base de datos operativa exclusivamente en la tabla emprendimientos
        $emprendimientoColumns = [];

        if (! $this->db->fieldExists('usuario_bd', 'emprendimientos')) {
            $emprendimientoColumns['usuario_bd'] = [
                'type' => 'VARCHAR',
                'constraint' => 80,
                'null' => true,
                'after' => 'database_key',
            ];
        }

        if (! $this->db->fieldExists('contrasenia_bd', 'emprendimientos')) {
            $emprendimientoColumns['contrasenia_bd'] = [
                'type' => 'VARCHAR',
                'constraint' => 255,
                'null' => true,
                'after' => 'usuario_bd',
            ];
        }

        if ($emprendimientoColumns !== []) {
            $this->forge->addColumn('emprendimientos', $emprendimientoColumns);
        }

        // 2. Índice optimizado para la resolución dinámica de conexiones por emprendimiento
        try {
            $this->db->query('ALTER TABLE emprendimientos ADD INDEX idx_emprendimientos_conexion (database_key, activo, fec_eliminacion)');
        } catch (\Throwable $e) {
            // Ignorar si el índice ya existe
        }
    }

    public function down(): void
    {
        try {
            $this->db->query('ALTER TABLE emprendimientos DROP INDEX idx_emprendimientos_conexion');
        } catch (\Throwable $e) {
            // Ignorar si el índice no existe
        }

        foreach (['contrasenia_bd', 'usuario_bd'] as $column) {
            if ($this->db->fieldExists($column, 'emprendimientos')) {
                $this->forge->dropColumn('emprendimientos', $column);
            }
        }
    }
}
