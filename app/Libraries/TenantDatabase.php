<?php

namespace App\Libraries;

use CodeIgniter\Database\BaseConnection;
use RuntimeException;

class TenantDatabase
{
    private const DATABASE_ENVIRONMENT_KEYS = [
        'don_goyo' => 'TISALEO_DB_DON_GOYO',
        'razu' => 'TISALEO_DB_RAZU',
        'dulce_mora' => 'TISALEO_DB_DULCE_MORA',
    ];

    /**
     * @return list<string>
     */
    public function allowedKeys(): array
    {
        return array_keys(self::DATABASE_ENVIRONMENT_KEYS);
    }

    public function connectionForKey(string $tenantKey): BaseConnection
    {
        $environmentKey = self::DATABASE_ENVIRONMENT_KEYS[$tenantKey] ?? null;
        if ($environmentKey === null) {
            throw new RuntimeException('El emprendimiento no tiene una conexión de base de datos autorizada.');
        }

        $databaseName = trim((string) env($environmentKey, ''));
        if (! preg_match('/\A[a-zA-Z0-9_]{1,64}\z/', $databaseName)) {
            throw new RuntimeException('Falta configurar el nombre de la base de datos para el emprendimiento.');
        }

        $database = config('Database')->default;
        $centralDatabaseName = trim((string) ($database['database'] ?? ''));
        if ($centralDatabaseName === '' || strcasecmp($databaseName, $centralDatabaseName) === 0) {
            throw new RuntimeException('La base operativa debe ser distinta de la base central de usuarios.');
        }

        foreach (self::DATABASE_ENVIRONMENT_KEYS as $key => $environmentKey) {
            if ($key === $tenantKey) {
                continue;
            }

            $otherDatabaseName = trim((string) env($environmentKey, ''));
            if ($otherDatabaseName !== '' && strcasecmp($databaseName, $otherDatabaseName) === 0) {
                throw new RuntimeException('Cada emprendimiento debe tener una base operativa distinta.');
            }
        }

        $database['database'] = $databaseName;

        return db_connect($database, false);
    }

    public function connectionForCurrentBusiness(): BaseConnection
    {
        $user = session('auth_user');
        $businessId = (int) session('current_business_id');
        $businesses = session('auth_businesses');

        if (! is_array($user) || ! is_array($businesses) || $businessId < 1) {
            throw new RuntimeException('No hay un emprendimiento activo en la sesión.');
        }

        foreach ($businesses as $business) {
            if ((int) ($business['id'] ?? 0) === $businessId && is_string($business['tenant_key'] ?? null)) {
                return $this->connectionForKey($business['tenant_key']);
            }
        }

        throw new RuntimeException('El emprendimiento activo no pertenece a esta cuenta.');
    }

    public function verifyConnection(string $tenantKey): void
    {
        $connection = $this->connectionForKey($tenantKey);
        $connection->initialize();

        if ($connection->connID === false) {
            throw new RuntimeException('No se pudo abrir la conexión a la base operativa.');
        }
    }
}
