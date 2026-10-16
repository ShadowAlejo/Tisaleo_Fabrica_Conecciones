<?php

namespace App\Controllers\Emprendedor;

use App\Controllers\BaseController;

class ServiciosController extends BaseController
{
    public function index(): string
    {
        return $this->renderPage('emprendedor/servicios/index', 'Servicios', 'servicios', 'Catálogo de servicios sin control de existencias.');
    }

    public function create(): string
    {
        return $this->renderPage('emprendedor/servicios/create', 'Registrar servicio', 'servicios', 'Define el nombre, la categoría y el precio del servicio.');
    }

    public function edit(int $id): string
    {
        return $this->renderPage('emprendedor/servicios/edit', 'Editar servicio', 'servicios', 'Plantilla de edición del servicio seleccionado.', ['id' => $id]);
    }
}
