<?php

namespace App\Controllers\Admin;

use App\Controllers\BaseController;

class EmprendimientosController extends BaseController
{
    protected string $role = 'admin';

    public function index(): string
    {
        return $this->renderPage('admin/emprendimientos/index', 'Emprendimientos', 'emprendimientos', 'Directorio global de espacios comerciales.');
    }

    public function create(): string
    {
        return $this->renderPage('admin/emprendimientos/create', 'Nuevo emprendimiento', 'emprendimientos', 'Estructura inicial para registrar un espacio comercial y su propietario.');
    }

    public function edit(int $id): string
    {
        return $this->renderPage('admin/emprendimientos/edit', 'Editar emprendimiento', 'emprendimientos', 'Estructura inicial para actualizar los datos del espacio comercial.', ['id' => $id]);
    }
}
