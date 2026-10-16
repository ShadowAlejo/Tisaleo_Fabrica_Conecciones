<?php

namespace App\Controllers\Emprendedor;

use App\Controllers\BaseController;

class ConfiguracionController extends BaseController
{
    public function index(): string
    {
        return $this->renderPage('emprendedor/configuracion/index', 'Configuración', 'configuracion', 'Perfil comercial y modelo de catálogo del emprendimiento.');
    }

    public function edit(): string
    {
        return $this->renderPage('emprendedor/configuracion/edit', 'Editar perfil comercial', 'configuracion', 'Actualiza los datos generales y el tipo de catálogo.');
    }
}
