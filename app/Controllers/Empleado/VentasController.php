<?php

namespace App\Controllers\Empleado;

use App\Controllers\BaseController;

class VentasController extends BaseController
{
    protected string $role = 'empleado';

    public function index(): string
    {
        return $this->renderPage('empleado/ventas/index', 'Historial de ventas', 'historial', 'Consulta de ventas prevista para el personal del emprendimiento.');
    }

    public function create(): string
    {
        return $this->renderPage('empleado/ventas/create', 'Nueva venta', 'ventas', 'Plantilla de cobro. El catálogo, el cálculo y el registro aún no están conectados.');
    }
}
