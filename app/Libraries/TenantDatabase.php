<?php

namespace App\Libraries;

use CodeIgniter\Database\BaseConnection;
use CodeIgniter\Database\Config as DatabaseFactory;
use Config\Database;
use RuntimeException;

class TenantDatabase
{
    private const IDLE_TIMEOUT_SECONDS = 600;

    /**
     * @var array<string, array{connection: BaseConnection, last_used: int}>
     */
    private static array $connections = [];

    public function __construct(private ?BaseConnection $centralDatabase = null)
    {
    }

    public function connectionForKey(string $databaseKey): BaseConnection
    {
        $prefix = (string) env('TISALEO_DB_PREFIX', 'db_emp_');

        if (
            preg_match('/\A[a-z][a-z0-9_]*_\z/', $prefix) !== 1
            || preg_match('/\A[a-z0-9_]+\z/', $databaseKey) !== 1
        ) {
            throw new RuntimeException('El nombre de la base de datos del emprendimiento no es válido.');
        }

        if (! str_starts_with($databaseKey, $prefix)) {
            throw new RuntimeException('La base de datos del emprendimiento no está registrada ni autorizada.');
        }

        $central = $this->centralDatabase ?? Database::connect();
        $registered = $central->table('emprendimientos')
            ->where('database_key', $databaseKey)
            ->where('activo', 1)
            ->where('fec_eliminacion', null)
            ->countAllResults() > 0;

        if (! $registered) {
            throw new RuntimeException('La base de datos del emprendimiento no está registrada ni autorizada.');
        }

        $now = time();
        $this->closeIdleConnections($now);

        if (isset(self::$connections[$databaseKey])) {
            self::$connections[$databaseKey]['last_used'] = $now;

            return self::$connections[$databaseKey]['connection'];
        }

        $databaseConfig = config(Database::class);
        $connectionConfig = $databaseConfig->{$databaseConfig->defaultGroup};
        $connectionConfig['database'] = $databaseKey;
        $isMySQLi = strcasecmp($connectionConfig['DBDriver'], 'MySQLi') === 0;
        $connectionConfig['pConnect'] = $isMySQLi;

        $connection = DatabaseFactory::connect($connectionConfig, false);

        if ($isMySQLi) {
            $connection->initialize();

            if ($connection->query('SET SESSION wait_timeout = ' . self::IDLE_TIMEOUT_SECONDS) === false) {
                $connection->close();

                throw new RuntimeException('No se pudo configurar la expiración de la conexión del emprendimiento.');
            }
        }

        self::$connections[$databaseKey] = [
            'connection' => $connection,
            'last_used' => $now,
        ];

        return $connection;
    }

    public function closeIdleConnections(?int $now = null): void
    {
        $now ??= time();

        foreach (self::$connections as $databaseKey => $entry) {
            if ($now - $entry['last_used'] < self::IDLE_TIMEOUT_SECONDS) {
                continue;
            }

            $entry['connection']->close();
            unset(self::$connections[$databaseKey]);
        }
    }
}
