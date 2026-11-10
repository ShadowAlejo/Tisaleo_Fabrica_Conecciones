<?php

namespace App\Libraries;

use CodeIgniter\Database\BaseConnection;
use RuntimeException;

class TenantDatabase
{
    /**
     * Bases de datos operativas y sus respectivos sufijos
     * para obtener las credenciales desde el archivo .env.
     */
    private const TENANT_ENVIRONMENT_SUFFIXES = [
        'db_emp_calzado_john' => 'CALZADO_JOHN',
        'db_emp_alju' => 'ALJU',
        'db_emp_lufeli' => 'LUFELI',
        'db_emp_helados_golositos' => 'HELADOS_GOLOSITOS',
        'db_emp_heladeria_karito' => 'HELADERIA_KARITO',
        'db_emp_conos_kelvin' => 'CONOS_KELVIN',
        'db_emp_turrones_don_goyo' => 'TURRONES_DON_GOYO',
        'db_emp_razu_corp' => 'RAZU_CORP',
        'db_emp_bodega_ga' => 'BODEGA_GA_DULCE_MORA',
        'db_emp_sirackagro' => 'SIRACKAGRO_INDUSTRIA',
        'db_emp_vinos_san_juan' => 'VINOS_SAN_JUAN',
        'db_emp_granja_ainhoa' => 'GRANJA_AINHOA',
        'db_emp_vinos_mm' => 'VINOS_MM',
        'db_emp_barros_nicole' => 'BARROS_NICOLE',
        'db_emp_vinos_mopocita' => 'VINOS_MOPOCITA',
        'db_emp_vinos_don_bolo' => 'VINOS_MIEL_DON_BOLO',
        'db_emp_granja_san_jose' => 'GRANJA_ECOLOGICA_SAN_JOSE',
        'db_emp_museo_santa_lucia' => 'MUSEO_SANTA_LUCIA',
        'db_emp_granja_san_martin' => 'GRANJA_SAN_MARTIN',
        'db_emp_san_miguel' => 'SAN_MIGUEL',
        'db_emp_union_hermandad' => 'ASOC_UNION_Y_HERMANDAD',
        'db_emp_asoc_quinchicoto' => 'ASOC_AGROPECUARIA_QUINCHICOTO',
        'db_emp_union_tisalena' => 'ASOC_UNION_TISALENA',
    ];

    /**
     * Obtiene todas las bases de datos autorizadas.
     *
     * @return list<string>
     */
    public function allowedKeys(): array
    {
        return array_keys(self::TENANT_ENVIRONMENT_SUFFIXES);
    }

    /**
     * Obtiene las claves de los emprendimientos.
     *
     * @return list<string>
     */
    public function tenantKeys(): array
    {
        return array_keys(self::TENANT_ENVIRONMENT_SUFFIXES);
    }

    /**
     * Obtiene las credenciales individuales de cada emprendimiento.
     *
     * @return array{username: string, password: string}
     */
    public function credentialsForKey(string $tenantKey): array
    {
        if (! isset(self::TENANT_ENVIRONMENT_SUFFIXES[$tenantKey])) {
            throw new RuntimeException(
                'El emprendimiento no tiene credenciales MySQL autorizadas.'
            );
        }

        $suffix = self::TENANT_ENVIRONMENT_SUFFIXES[$tenantKey];

        $username = trim(
            (string) env('TISALEO_DB_USER_' . $suffix, '')
        );

        $password = (string) env(
            'TISALEO_DB_PASSWORD_' . $suffix,
            ''
        );

        if (
            ! preg_match('/\A[a-zA-Z0-9_]{1,32}\z/', $username)
            || $password === ''
        ) {
            throw new RuntimeException(
                'Faltan credenciales MySQL válidas para el emprendimiento: '
                . $tenantKey
            );
        }

        return [
            'username' => $username,
            'password' => $password,
        ];
    }

    /**
     * Establece una conexión individual con la base de datos
     * correspondiente al emprendimiento.
     */
    public function connectionForKey(string $tenantKey): BaseConnection
    {
        // Verificar que la base esté autorizada.
        if (! isset(self::TENANT_ENVIRONMENT_SUFFIXES[$tenantKey])) {
            throw new RuntimeException(
                'El emprendimiento no tiene una conexión de base de datos autorizada.'
            );
        }

        // Obtener configuración predeterminada del servidor MySQL.
        $database = config('Database')->default;

        // Obtener el nombre de la base central.
        $centralDatabaseName = trim(
            (string) ($database['database'] ?? '')
        );

        // Obtener las credenciales individuales.
        $credentials = $this->credentialsForKey($tenantKey);

        // Cada emprendimiento tiene su propia base de datos.
        $databaseName = $tenantKey;

        // Validar nombre de la base de datos.
        if (! preg_match('/\A[a-zA-Z0-9_]{1,64}\z/', $databaseName)) {
            throw new RuntimeException(
                'El nombre de la base de datos del emprendimiento no es válido.'
            );
        }

        // Impedir utilizar la base central de usuarios.
        if (
            $centralDatabaseName === ''
            || strcasecmp($databaseName, $centralDatabaseName) === 0
        ) {
            throw new RuntimeException(
                'La base operativa debe ser distinta de la base central de usuarios.'
            );
        }

        // Verificar que ningún otro emprendimiento utilice
        // el mismo nombre de base de datos.
        foreach (self::TENANT_ENVIRONMENT_SUFFIXES as $key => $suffix) {
            if (
                $key !== $tenantKey
                && strcasecmp($databaseName, $key) === 0
            ) {
                throw new RuntimeException(
                    'Cada emprendimiento debe tener una base operativa distinta.'
                );
            }
        }

        // Configurar las credenciales individuales.
        $database['username'] = $credentials['username'];
        $database['password'] = $credentials['password'];
        $database['database'] = $databaseName;

        // Crear conexión independiente.
        return db_connect($database, false);
    }

    /**
     * Obtiene la conexión del emprendimiento seleccionado
     * actualmente por el usuario autenticado.
     */
    public function connectionForCurrentBusiness(): BaseConnection
    {
        $user = session('auth_user');

        $businessId = (int) session('current_business_id');

        $businesses = session('auth_businesses');

        if (
            ! is_array($user)
            || ! is_array($businesses)
            || $businessId < 1
        ) {
            throw new RuntimeException(
                'No hay un emprendimiento activo en la sesión.'
            );
        }

        foreach ($businesses as $business) {
            if (
                (int) ($business['id'] ?? 0) === $businessId
                && is_string($business['tenant_key'] ?? null)
            ) {
                return $this->connectionForKey(
                    $business['tenant_key']
                );
            }
        }

        throw new RuntimeException(
            'El emprendimiento activo no pertenece a esta cuenta.'
        );
    }

    /**
     * Comprueba que la conexión con la base operativa funcione.
     */
    public function verifyConnection(string $tenantKey): void
    {
        $connection = $this->connectionForKey($tenantKey);

        $connection->initialize();

        if ($connection->connID === false) {
            throw new RuntimeException(
                'No se pudo abrir la conexión a la base operativa.'
            );
        }
    }
}