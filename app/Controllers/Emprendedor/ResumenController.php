<?php

namespace App\Controllers\Emprendedor;

use App\Controllers\BaseController;

class ResumenController extends BaseController
{
    public function index(): string
    {
        return $this->renderPage('emprendedor/resumen/index', 'Resumen del negocio', 'resumen', 'Un vistazo a ventas, catálogo y alertas del emprendimiento.');
    }
}
