<?php

namespace App\Controllers\Admin;

use App\Controllers\BaseController;

class DashboardController extends BaseController
{
    protected string $role = 'admin';

    public function index(): string
    {
        return $this->renderPage('admin/resumen/index', 'Resumen general', 'resumen', 'Lectura global de la operación. Los indicadores se conectarán cuando exista persistencia.');
    }
}
