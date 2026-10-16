<?php

use CodeIgniter\Router\RouteCollection;

/** @var RouteCollection $routes */
$routes->get('/', 'Emprendedor\ResumenController::index');

// Administracion general
$routes->get('admin', 'Admin\DashboardController::index');
$routes->get('admin/emprendimientos', 'Admin\EmprendimientosController::index');
$routes->get('admin/emprendimientos/create', 'Admin\EmprendimientosController::create');
$routes->get('admin/emprendimientos/edit/(:num)', 'Admin\EmprendimientosController::edit/$1');

// Panel del propietario
$routes->get('emprendedor', 'Emprendedor\ResumenController::index');
$routes->get('emprendedor/productos', 'Emprendedor\ProductosController::index');
$routes->get('emprendedor/productos/create', 'Emprendedor\ProductosController::create');
$routes->get('emprendedor/productos/edit/(:num)', 'Emprendedor\ProductosController::edit/$1');
$routes->get('emprendedor/servicios', 'Emprendedor\ServiciosController::index');
$routes->get('emprendedor/servicios/create', 'Emprendedor\ServiciosController::create');
$routes->get('emprendedor/servicios/edit/(:num)', 'Emprendedor\ServiciosController::edit/$1');
$routes->get('emprendedor/ventas', 'Emprendedor\VentasController::index');
$routes->get('emprendedor/ventas/create', 'Emprendedor\VentasController::create');
$routes->get('emprendedor/configuracion', 'Emprendedor\ConfiguracionController::index');
$routes->get('emprendedor/configuracion/edit', 'Emprendedor\ConfiguracionController::edit');
$routes->get('emprendedor/empleados', 'Emprendedor\EmpleadosController::index');
$routes->get('emprendedor/empleados/create', 'Emprendedor\EmpleadosController::create');
$routes->get('emprendedor/empleados/edit/(:num)', 'Emprendedor\EmpleadosController::edit/$1');

// Espacio de trabajo del empleado
$routes->get('empleado', 'Empleado\VentasController::index');
$routes->get('empleado/ventas', 'Empleado\VentasController::index');
$routes->get('empleado/ventas/create', 'Empleado\VentasController::create');
