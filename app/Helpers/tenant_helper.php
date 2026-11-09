<?php

use App\Libraries\TenantDatabase;
use CodeIgniter\Database\BaseConnection;

if (! function_exists('tenant_db')) {
    function tenant_db(): BaseConnection
    {
        return (new TenantDatabase())->connectionForCurrentBusiness();
    }
}
