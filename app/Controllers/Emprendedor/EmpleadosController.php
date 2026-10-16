<?php

namespace App\Controllers\Emprendedor;

use App\Controllers\BaseController;

class EmpleadosController extends BaseController
{
    public function index(): string
    {
        return $this->renderPage('emprendedor/empleados/index', 'Equipo de trabajo', 'empleados', 'Espacio para administrar las cuentas asociadas al emprendimiento.');
    }

    public function create(): string
    {
        return $this->renderPage('emprendedor/empleados/create', 'Invitar empleado', 'empleados', 'Estructura del formulario de empleado. La creación de cuentas aún no está conectada.');
    }

    public function edit(int $id): string
    {
        return $this->renderPage('emprendedor/empleados/edit', 'Editar empleado', 'empleados', 'Plantilla de edición de la cuenta seleccionada.', ['id' => $id]);
    }
}
