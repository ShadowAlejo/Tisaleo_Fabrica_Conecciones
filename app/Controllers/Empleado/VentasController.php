<?php

namespace App\Controllers\Empleado;

class VentasController extends \App\Controllers\Emprendedor\VentasController
{
    protected string $role = 'empleado';
}
