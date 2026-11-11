<?php

use App\Libraries\TenantDatabase;
use CodeIgniter\Database\BaseConnection;
if (! function_exists('tenant_db')) {
    function tenant_db(): BaseConnection
    {
        $databaseKey = session()->get('tenant_database_key');

        if (! is_string($databaseKey) || $databaseKey === '') {
            throw new \RuntimeException('La sesión no tiene un emprendimiento asignado.');
        }

        return (new TenantDatabase())->connectionForKey($databaseKey);
    }
}
