<?php

namespace App\Commands;

use App\Libraries\TenantDatabase;
use CodeIgniter\CLI\BaseCommand;
use CodeIgniter\CLI\CLI;
use CodeIgniter\Database\BaseConnection;
use CodeIgniter\Database\Exceptions\DatabaseException;
use RuntimeException;

class ProvisionTenantUsers extends BaseCommand
{
    protected $group = 'Database';
    protected $name = 'tenants:provision-users';
    protected $description = 'Creates missing MySQL users and grants access only to their assigned business database.';

    public function run(array $params)
    {
        $tenantDatabase = new TenantDatabase();
        $tenantKeys = $tenantDatabase->tenantKeys();
        $credentials = [];

        foreach ($tenantKeys as $tenantKey) {
            $credentials[$tenantKey] = $tenantDatabase->credentialsForKey($tenantKey);
        }

        $accountHost = trim((string) env('TISALEO_DB_ACCOUNT_HOST', 'localhost'));
        if (! preg_match('/\A[a-zA-Z0-9_.:-]{1,255}\z/', $accountHost)) {
            throw new RuntimeException('TISALEO_DB_ACCOUNT_HOST debe ser localhost o un host/IP válido, sin comodines.');
        }

        $centralDatabase = db_connect();
        $centralDatabase->initialize();

        if ($centralDatabase->connID === false) {
            throw new RuntimeException('No se pudo conectar a la base central para aprovisionar usuarios MySQL.');
        }

        $failedTenants = [];

        foreach ($tenantKeys as $tenantKey) {
            try {
                $this->provisionTenant($centralDatabase, $tenantKey, $accountHost, $credentials[$tenantKey]);
                CLI::write('Usuario y permisos verificados para ' . $tenantKey . '.', 'green');
            } catch (DatabaseException|RuntimeException $exception) {
                log_message('error', 'No se pudo aprovisionar el usuario MySQL para {tenant}.', [
                    'tenant' => $tenantKey,
                ]);
                $failedTenants[] = $tenantKey;
                CLI::write('No se pudo aprovisionar ' . $tenantKey . '. Verifica que la cuenta central tenga permisos CREATE USER y GRANT.', 'red');
            }
        }

        if ($failedTenants !== []) {
            throw new RuntimeException('No se pudieron aprovisionar estas bases operativas: ' . implode(', ', $failedTenants) . '.');
        }
    }

    /**
     * @param array{username: string, password: string} $credentials
     */
    private function provisionTenant(BaseConnection $database, string $tenantKey, string $accountHost, array $credentials): void
    {
        $schema = $database->query(
            'SELECT SCHEMA_NAME FROM INFORMATION_SCHEMA.SCHEMATA WHERE SCHEMA_NAME = ?',
            [$tenantKey],
        )->getRowArray();

        if ($schema === null) {
            throw new RuntimeException('La base operativa no existe.');
        }

        $account = $database->escape($credentials['username']) . '@' . $database->escape($accountHost);
        $password = $database->escape($credentials['password']);
        $databaseName = $database->escapeIdentifiers($tenantKey);

        $database->query('CREATE USER IF NOT EXISTS ' . $account . ' IDENTIFIED BY ' . $password);
        $database->query(
            'GRANT SELECT, INSERT, UPDATE, DELETE, CREATE, ALTER, INDEX, REFERENCES ON '
            . $databaseName . '.* TO ' . $account,
        );
    }
}
