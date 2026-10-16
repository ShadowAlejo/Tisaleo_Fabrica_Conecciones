<?php

namespace App\Controllers\Emprendedor;

use App\Controllers\BaseController;

class ProductosController extends BaseController
{
    public function index(): string
    {
        return $this->renderPage('emprendedor/productos/index', 'Productos', 'productos', 'Catálogo de productos físicos y estructura para control de existencias.');
    }

    public function create(): string
    {
        return $this->renderPage('emprendedor/productos/create', 'Registrar producto', 'productos', 'Define los datos comerciales y el control inicial de inventario.');
    }

    public function edit(int $id): string
    {
        return $this->renderPage('emprendedor/productos/edit', 'Editar producto', 'productos', 'Plantilla de edición del producto seleccionado.', ['id' => $id]);
    }
}
