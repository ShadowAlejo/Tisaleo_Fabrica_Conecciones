<?php

namespace App\Commands;

use App\Libraries\TenantDatabase;
use CodeIgniter\CLI\BaseCommand;
use CodeIgniter\CLI\CLI;
use RuntimeException;

class MigrateTenants extends BaseCommand
{
    protected $group = 'Database';
    protected $name = 'tenants:migrate';
    protected $description = 'Adds the product and service fields used by the business modules.';

    public function run(array $params)
    {
        $tenantDatabase = new TenantDatabase();

        foreach (['don_goyo', 'razu', 'dulce_mora'] as $tenantKey) {
            $database = $tenantDatabase->connectionForKey($tenantKey);
            $database->initialize();

            if ($database->connID === false) {
                throw new RuntimeException('No se pudo conectar con la base del emprendimiento: ' . $tenantKey);
            }
            $forge = \Config\Database::forge($database);

            if (! $database->tableExists('productos') || ! $database->tableExists('servicios')) {
                throw new RuntimeException('Faltan las tablas productos o servicios en la base del emprendimiento: ' . $tenantKey);
            }

            if (! in_array('stock_minimo', $database->getFieldNames('productos'), true)) {
                $forge->addColumn('productos', [
                    'stock_minimo' => [
                        'type' => 'DECIMAL',
                        'constraint' => '12,2',
                        'unsigned' => true,
                        'null' => false,
                        'default' => 0,
                        'after' => 'cantidad',
                    ],
                ]);
            } else {
                $forge->modifyColumn('productos', [
                    'stock_minimo' => [
                        'type' => 'DECIMAL',
                        'constraint' => '12,2',
                        'unsigned' => true,
                        'null' => false,
                        'default' => 0,
                    ],
                ]);
            }

            if (! in_array('categoria', $database->getFieldNames('servicios'), true)) {
                $forge->addColumn('servicios', [
                    'categoria' => [
                        'type' => 'VARCHAR',
                        'constraint' => 100,
                        'null' => true,
                        'after' => 'nombre',
                    ],
                ]);
            }

            $forge->modifyColumn('detalle_venta', [
                'cantidad' => [
                    'type' => 'DECIMAL',
                    'constraint' => '12,2',
                    'null' => false,
                    'default' => 1,
                ],
            ]);
            $forge->modifyColumn('movimientos_inventario', [
                'cantidad' => [
                    'type' => 'DECIMAL',
                    'constraint' => '12,2',
                    'null' => false,
                ],
            ]);
            $forge->modifyColumn('productos', [
                'cantidad' => [
                    'type' => 'DECIMAL',
                    'constraint' => '12,2',
                    'unsigned' => true,
                    'null' => false,
                    'default' => 0,
                ],
            ]);

            CLI::write('Esquema operativo actualizado: ' . $tenantKey, 'green');
        }
    }
}
