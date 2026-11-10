<?php

namespace App\Libraries;

use CodeIgniter\Database\BaseConnection;
use RuntimeException;

/**
 * Fábrica de Conexiones Dinámicas (Dynamic Connection Factory)
 * para los emprendimientos de Tisaleo.
 */
class TenantDatabase
{
    /**
     * Pool de conexiones dinámicas en memoria para reutilizar
     * instancias activas y optimizar recursos en cada petición.
     *
     * @var array<string, BaseConnection>
     */
    private static array $connectionPool = [];

    /**
     * Mapeo de bases de datos operativas y sus sufijos para .env (26 emprendimientos).
     */
    private const TENANT_ENVIRONMENT_SUFFIXES = [
        'db_emp_calzado_john'       => 'CALZADO_JOHN',
        'db_emp_alju'               => 'ALJU',
        'db_emp_lufeli'             => 'LUFELI',
        'db_emp_helados_golositos'  => 'HELADOS_GOLOSITOS',
        'db_emp_heladeria_karito'   => 'HELADERIA_KARITO',
        'db_emp_conos_kelvin'       => 'CONOS_KELVIN',
        'db_emp_turrones_don_goyo'  => 'TURRONES_DON_GOYO',
        'db_emp_razu_corp'          => 'RAZU_CORP',
        'db_emp_bodega_ga'          => 'BODEGA_GA_DULCE_MORA',
        'db_emp_sirackagro'         => 'SIRACKAGRO_INDUSTRIA',
        'db_emp_vinos_san_juan'     => 'VINOS_SAN_JUAN',
        'db_emp_sachaluna'          => 'SACHALUNA',
        'db_emp_granja_ainhoa'      => 'GRANJA_AINHOA',
        'db_emp_vinos_la_florida'   => 'VINOS_LA_FLORIDA',
        'db_emp_vinos_mm'           => 'VINOS_MM',
        'db_emp_barros_nicole'      => 'BARROS_NICOLE',
        'db_emp_vinos_mopocita'     => 'VINOS_MOPOCITA',
        'db_emp_vinos_don_bolo'     => 'VINOS_MIEL_DON_BOLO',
        'db_emp_granja_san_jose'    => 'GRANJA_ECOLOGICA_SAN_JOSE',
        'db_emp_museo_santa_lucia'  => 'MUSEO_SANTA_LUCIA',
        'db_emp_granja_san_martin'  => 'GRANJA_SAN_MARTIN',
        'db_emp_la_guadalupana'     => 'QUINTA_LA_GUADALUPANA',
        'db_emp_san_miguel'         => 'SAN_MIGUEL',
        'db_emp_union_hermandad'    => 'ASOC_UNION_Y_HERMANDAD',
        'db_emp_asoc_quinchicoto'   => 'ASOC_AGROPECUARIA_QUINCHICOTO',
        'db_emp_union_tisalena'     => 'ASOC_UNION_TISALENA',
    ];

    /**
     * Obtiene dinámicamente todas las claves de bases autorizadas,
     * consultando la base central y combinando con los sufijos conocidos.
     *
     * @return list<string>
     */
    public function allowedKeys(): array
    {
        $keys = array_keys(self::TENANT_ENVIRONMENT_SUFFIXES);

        try {
            $centralDb = db_connect();
            if ($centralDb->connID !== false && $centralDb->tableExists('emprendimientos')) {
                $dbKeys = $centralDb->table('emprendimientos')
                    ->select('database_key')
                    ->where('database_key IS NOT NULL')
                    ->where('activo', 1)
                    ->where('fec_eliminacion', null)
                    ->get()
                    ->getResultArray();

                foreach ($dbKeys as $row) {
                    $key = trim((string) ($row['database_key'] ?? ''));
                    if ($key !== '' && ! in_array($key, $keys, true)) {
                        $keys[] = $key;
                    }
                }
            }
        } catch (\Throwable $e) {
            // Utilizar claves de configuración estática si la base central no está disponible
        }

        return array_values(array_unique($keys));
    }

    /**
     * Alias de allowedKeys() para compatibilidad.
     *
     * @return list<string>
     */
    public function tenantKeys(): array
    {
        return $this->allowedKeys();
    }

    /**
     * Resuelve las credenciales de conexión para un tenant específico,
     * priorizando la base de datos central de usuarios y respaldándose en .env.
     *
     * @return array{username: string, password: string}
     */
    public function credentialsForKey(string $tenantKey): array
    {
        // 1. Intentar consultar credenciales desde la base central (tabla emprendimientos)
        try {
            $centralDb = db_connect();
            if ($centralDb->connID !== false && $centralDb->tableExists('emprendimientos')) {
                $tenant = $centralDb->table('emprendimientos')
                    ->select('usuario_bd, contrasenia_bd')
                    ->where('database_key', $tenantKey)
                    ->where('activo', 1)
                    ->where('fec_eliminacion', null)
                    ->get()
                    ->getRowArray();

                if (
                    $tenant !== null
                    && ! empty($tenant['usuario_bd'])
                    && ! empty($tenant['contrasenia_bd'])
                ) {
                    return [
                        'username' => trim((string) $tenant['usuario_bd']),
                        'password' => (string) $tenant['contrasenia_bd'],
                    ];
                }
            }
        } catch (\Throwable $e) {
            // Continuar con variables de entorno si la base central no está accesible
        }

        // 2. Si no están en la base central, obtener desde variables de entorno .env
        $suffix = self::TENANT_ENVIRONMENT_SUFFIXES[$tenantKey] ?? null;
        if ($suffix === null) {
            // Intentar deducir el sufijo si el tenantKey sigue el patrón db_emp_xxx
            $normalizedKey = preg_replace('/^db_emp_/', '', $tenantKey);
            $suffix = strtoupper(str_replace(['-', ' '], '_', $normalizedKey));
        }

        $username = trim((string) env('TISALEO_DB_USER_' . $suffix, ''));
        $password = (string) env('TISALEO_DB_PASSWORD_' . $suffix, '');

        if (! preg_match('/\A[a-zA-Z0-9_]{1,32}\z/', $username) || $password === '') {
            throw new RuntimeException(
                'Faltan credenciales MySQL válidas para el emprendimiento: ' . $tenantKey
            );
        }

        return [
            'username' => $username,
            'password' => $password,
        ];
    }

    /**
     * Fábrica dinámica: construye o reutiliza una conexión a la base de datos operativa.
     */
    public function connectionForKey(string $tenantKey): BaseConnection
    {
        // Verificar si ya existe una conexión activa y saludable en el pool
        if (isset(self::$connectionPool[$tenantKey])) {
            $existing = self::$connectionPool[$tenantKey];
            if ($existing->connID !== false) {
                return $existing;
            }
            unset(self::$connectionPool[$tenantKey]);
        }

        // Validar formato del nombre de la base de datos
        if (! preg_match('/\A[a-zA-Z0-9_]{1,64}\z/', $tenantKey)) {
            throw new RuntimeException(
                'El nombre de la base de datos del emprendimiento no es válido.'
            );
        }

        // Obtener configuración predeterminada del servidor MySQL
        $defaultConfig = config('Database')->default;
        $centralDatabaseName = trim((string) ($defaultConfig['database'] ?? ''));

        // Impedir conectarse a la base central de usuarios como si fuera tenant
        if ($centralDatabaseName === '' || strcasecmp($tenantKey, $centralDatabaseName) === 0) {
            throw new RuntimeException(
                'La base operativa debe ser distinta de la base central de usuarios.'
            );
        }

        // Obtener credenciales individuales (BD central o .env)
        $credentials = $this->credentialsForKey($tenantKey);

        // Configurar los parámetros dinámicos de conexión (hereda host y puerto generales)
        $tenantConfig = $defaultConfig;
        $tenantConfig['username'] = $credentials['username'];
        $tenantConfig['password'] = $credentials['password'];
        $tenantConfig['database'] = $tenantKey;

        // Crear conexión independiente y almacenarla en el pool dinámico
        $connection = db_connect($tenantConfig, false);
        self::$connectionPool[$tenantKey] = $connection;

        return $connection;
    }

    /**
     * Obtiene la conexión a partir del ID de un emprendimiento en la base central.
     */
    public function connectionForBusinessId(int $businessId): BaseConnection
    {
        $business = db_connect()->table('emprendimientos')
            ->select('database_key')
            ->where('id', $businessId)
            ->where('activo', 1)
            ->where('fec_eliminacion', null)
            ->get()
            ->getRowArray();

        $tenantKey = trim((string) ($business['database_key'] ?? ''));
        if ($tenantKey === '') {
            throw new RuntimeException('El emprendimiento especificado no tiene una base de datos asignada.');
        }

        return $this->connectionForKey($tenantKey);
    }

    /**
     * Obtiene la conexión del emprendimiento seleccionado
     * actualmente por el usuario autenticado en la sesión.
     */
    public function connectionForCurrentBusiness(): BaseConnection
    {
        $user = session('auth_user');
        $businessId = (int) session('current_business_id');
        $businesses = session('auth_businesses');

        if (! is_array($user) || ! is_array($businesses) || $businessId < 1) {
            throw new RuntimeException('No hay un emprendimiento activo en la sesión.');
        }

        foreach ($businesses as $business) {
            if (
                (int) ($business['id'] ?? 0) === $businessId
                && is_string($business['tenant_key'] ?? null)
            ) {
                return $this->connectionForKey($business['tenant_key']);
            }
        }

        throw new RuntimeException('El emprendimiento activo no pertenece a esta cuenta.');
    }

    /**
     * Comprueba que la conexión con la base operativa funcione correctamente.
     */
    public function verifyConnection(string $tenantKey): void
    {
        $connection = $this->connectionForKey($tenantKey);
        $connection->initialize();

        if ($connection->connID === false) {
            throw new RuntimeException('No se pudo abrir la conexión a la base operativa: ' . $tenantKey);
        }
    }

    /**
     * Limpia el pool de conexiones dinámicas.
     */
    public static function resetPool(): void
    {
        foreach (self::$connectionPool as $connection) {
            try {
                $connection->close();
            } catch (\Throwable $e) {
                // Ignorar error al cerrar
            }
        }
        self::$connectionPool = [];
    }
}
