<?php

namespace App\Database\Migrations;

use CodeIgniter\Database\Migration;
use RuntimeException;

class StoreBusinessCategoryAsText extends Migration
{
    public function up(): void
    {
        if (! $this->db->fieldExists('categoria_id', 'emprendimientos')) {
            if (! $this->db->fieldExists('categoria', 'emprendimientos')) {
                throw new RuntimeException('No se encontró la categoría de emprendimientos para migrar.');
            }

            if ($this->db->tableExists('categorias')) {
                $this->forge->dropTable('categorias', true);
            }

            return;
        }

        if (! $this->db->tableExists('categorias')) {
            throw new RuntimeException('No se encontró la tabla categorias para migrar sus datos.');
        }

        $this->db->query('ALTER TABLE emprendimientos ADD COLUMN categoria VARCHAR(100) NULL');
        $this->db->query(
            'UPDATE emprendimientos AS e
             INNER JOIN categorias AS c ON c.id = e.categoria_id
             SET e.categoria = c.nombre',
        );
        $this->db->query("UPDATE emprendimientos SET categoria = 'Sin categoría' WHERE categoria IS NULL");
        $this->db->query('ALTER TABLE emprendimientos MODIFY categoria VARCHAR(100) NOT NULL');
        $this->db->query('ALTER TABLE emprendimientos DROP FOREIGN KEY fk_emprendimientos_categoria');
        $this->db->query('ALTER TABLE emprendimientos DROP INDEX idx_emprendimientos_categoria');
        $this->db->query('ALTER TABLE emprendimientos DROP COLUMN categoria_id');
        $this->forge->dropTable('categorias', true);
    }

    public function down(): void
    {
        if ($this->db->fieldExists('categoria_id', 'emprendimientos')) {
            return;
        }

        if (! $this->db->fieldExists('categoria', 'emprendimientos')) {
            throw new RuntimeException('No se encontró la categoría de emprendimientos para revertir.');
        }

        $this->db->query(
            'CREATE TABLE categorias (
                id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
                nombre VARCHAR(100) NOT NULL,
                fec_creacion TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
                fec_actualizacion TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
                fec_eliminacion TIMESTAMP NULL DEFAULT NULL,
                UNIQUE KEY uq_categorias_nombre (nombre)
            ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci',
        );
        $this->db->query(
            'INSERT INTO categorias (nombre)
             SELECT DISTINCT categoria FROM emprendimientos',
        );
        $this->db->query('ALTER TABLE emprendimientos ADD COLUMN categoria_id BIGINT UNSIGNED NULL');
        $this->db->query(
            'UPDATE emprendimientos AS e
             INNER JOIN categorias AS c ON c.nombre = e.categoria
             SET e.categoria_id = c.id',
        );
        $this->db->query('ALTER TABLE emprendimientos MODIFY categoria_id BIGINT UNSIGNED NOT NULL');
        $this->db->query('ALTER TABLE emprendimientos ADD INDEX idx_emprendimientos_categoria (categoria_id)');
        $this->db->query(
            'ALTER TABLE emprendimientos
             ADD CONSTRAINT fk_emprendimientos_categoria
             FOREIGN KEY (categoria_id) REFERENCES categorias (id)
             ON UPDATE CASCADE ON DELETE RESTRICT',
        );
        $this->db->query('ALTER TABLE emprendimientos DROP COLUMN categoria');
    }
}
