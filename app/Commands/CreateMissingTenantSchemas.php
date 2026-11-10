<?php

namespace App\Commands;

use App\Libraries\TenantDatabase;
use CodeIgniter\CLI\BaseCommand;
use CodeIgniter\CLI\CLI;
use CodeIgniter\Database\BaseConnection;
use CodeIgniter\Database\Exceptions\DatabaseException;
use RuntimeException;

class CreateMissingTenantSchemas extends BaseCommand
{
    protected $group = 'Database';
    protected $name = 'tenants:create-missing-schemas';
    protected $description = 'Creates missing tenant databases and tables without dropping existing data.';

    private const TABLES = [
        'auditoria',
        'servicios',
        'productos',
        'ventas',
        'detalle_venta',
        'movimientos_inventario',
    ];

    public function run(array $params)
    {
        $tenantDatabase = new TenantDatabase();
        $source = ROOTPATH . 'database' . DIRECTORY_SEPARATOR . 'emprendimientos_tisal.sql';
        $sql = file_get_contents($source);

        if ($sql === false) {
            throw new RuntimeException('No se pudo leer el esquema operativo de los emprendimientos.');
        }

        $statements = [];
        foreach ($tenantDatabase->tenantKeys() as $tenantKey) {
            $statements[$tenantKey] = $this->tableStatementsFor($sql, $tenantKey);
        }

        $centralDatabase = db_connect();
        $centralDatabase->initialize();

        if ($centralDatabase->connID === false) {
            throw new RuntimeException('No se pudo conectar a la base central para crear los esquemas operativos.');
        }

        $failedTenants = [];

        foreach ($tenantDatabase->tenantKeys() as $tenantKey) {
            try {
                $this->createSchema($centralDatabase, $tenantKey, $statements[$tenantKey]);
                CLI::write('Esquema creado o verificado sin borrar datos: ' . $tenantKey . '.', 'green');
            } catch (DatabaseException|RuntimeException $exception) {
                log_message('error', 'No se pudo crear o verificar el esquema operativo {tenant}.', [
                    'tenant' => $tenantKey,
                ]);
                $failedTenants[] = $tenantKey;
                CLI::write('No se pudo crear o verificar ' . $tenantKey . '. Verifica que la cuenta central tenga permisos para crear bases y tablas.', 'red');
            }
        }

        if ($failedTenants !== []) {
            throw new RuntimeException('No se pudieron crear o verificar estos esquemas: ' . implode(', ', $failedTenants) . '.');
        }
    }

    /**
     * @return list<string>
     */
    private function tableStatementsFor(string $sql, string $tenantKey): array
    {
        $sectionPattern = '/--\s*=+\s*BASE\s+\d+\/26:\s*' . preg_quote($tenantKey, '/') . '\s*=+\R(.*?)(?=--\s*=+\s*BASE\s+\d+\/26:|\z)/s';
        if (! preg_match($sectionPattern, $sql, $section)) {
            throw new RuntimeException('No se encontró el esquema SQL para ' . $tenantKey . '.');
        }

        preg_match_all(
            '/CREATE TABLE\s+\w+\s*\(.*?\)\s*ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci\s*;/is',
            $section[1],
            $matches,
        );

        $statements = [];
        foreach ($matches[0] as $statement) {
            $statements[] = preg_replace('/\ACREATE TABLE\s+/i', 'CREATE TABLE IF NOT EXISTS ', trim($statement), 1);
        }

        if (count($statements) !== count(self::TABLES)) {
            throw new RuntimeException('El esquema SQL no contiene las seis tablas esperadas para ' . $tenantKey . '.');
        }

        return $statements;
    }

    /**
     * @param list<string> $statements
     */
    private function createSchema(BaseConnection $centralDatabase, string $tenantKey, array $statements): void
    {
        $databaseName = $centralDatabase->escapeIdentifiers($tenantKey);
        $centralDatabase->query(
            'CREATE DATABASE IF NOT EXISTS ' . $databaseName
            . ' CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci',
        );

        $databaseConfig = config('Database')->default;
        $databaseConfig['database'] = $tenantKey;
        $tenantAdminConnection = db_connect($databaseConfig, false);
        $tenantAdminConnection->initialize();

        if ($tenantAdminConnection->connID === false) {
            throw new RuntimeException('No se pudo abrir la conexión administrativa al esquema operativo.');
        }

        foreach ($statements as $statement) {
            $tenantAdminConnection->query($statement);
        }
    }
}
