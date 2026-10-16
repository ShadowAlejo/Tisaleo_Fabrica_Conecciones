<?php

namespace App\Controllers\Emprendedor;

use App\Controllers\BaseController;

class VentasController extends BaseController
{
    public function index(): string
    {
        return $this->renderPage('emprendedor/ventas/index', 'Historial de ventas', 'ventas', 'Consulta prevista de ventas y sus artículos.');
    }

    public function create(): string
    {
        return $this->renderPage('emprendedor/ventas/create', 'Venta rápida', 'ventas', 'Punto de venta preparado para productos, servicios y medios de cobro.');
    }
}
