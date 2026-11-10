<?php

namespace App\Commands;

use App\Libraries\TenantDatabase;
use CodeIgniter\CLI\BaseCommand;
use CodeIgniter\CLI\CLI;
use CodeIgniter\Database\Exceptions\DatabaseException;
use RuntimeException;

class MigrateTenants extends BaseCommand
{
    protected $group = 'Database';
    protected $name = 'tenants:migrate';
    protected $description = 'Updates the operational schema of all active, assigned businesses.';

    public function run(array $params)
    {
        $tenantDatabase = new TenantDatabase();

        $tenantKeys = db_connect()->table('emprendimientos')
            ->select('database_key')
            ->where('activo', 1)
            ->where('fec_eliminacion', null)
            ->where('database_key IS NOT NULL')
            ->get()
            ->getResultArray();
        $failedTenants = [];

        foreach (array_unique(array_column($tenantKeys, 'database_key')) as $tenantKey) {
            if (! is_string($tenantKey) || ! in_array($tenantKey, $tenantDatabase->allowedKeys(), true)) {
                throw new RuntimeException('Hay un emprendimiento con una base operativa no autorizada.');
            }

            try {
                $database = $tenantDatabase->connectionForKey($tenantKey);
                $database->initialize();

                if ($database->connID === false) {
                    throw new RuntimeException('No se pudo abrir la conexión a la base operativa.');
                }
                $forge = \Config\Database::forge($database);

                if (! $database->tableExists('productos') || ! $database->tableExists('servicios')) {
                    throw new RuntimeException('Faltan las tablas productos o servicios.');
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

                if (! in_array('categoria_unidad', $database->getFieldNames('productos'), true)) {
                    $forge->addColumn('productos', [
                        'categoria_unidad' => [
                            'type' => 'VARCHAR',
                            'constraint' => 100,
                            'null' => true,
                            'after' => 'unidad_medida',
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
            } catch (DatabaseException|RuntimeException $exception) {
                log_message('error', 'No se pudo actualizar la base operativa {tenant}: {message}', [
                    'tenant' => $tenantKey,
                    'message' => $exception->getMessage(),
                ]);
                $failedTenants[] = $tenantKey;
                CLI::write('No se pudo actualizar ' . $tenantKey . '. Verifica sus credenciales, permisos y esquema MySQL.', 'red');
            }
        }

        if ($failedTenants !== []) {
            throw new RuntimeException('No se actualizaron estas bases operativas: ' . implode(', ', $failedTenants) . '.');
        }
    }
}
