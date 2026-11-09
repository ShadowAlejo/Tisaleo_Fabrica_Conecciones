<?php

use CodeIgniter\Router\RouteCollection;

/** @var RouteCollection $routes */
$routes->get('/', 'AuthController::index');
$routes->get('login', 'AuthController::index');
$routes->post('login', 'AuthController::attempt', ['filter' => 'csrf']);
$routes->post('logout', 'AuthController::logout', ['filter' => 'csrf']);
$routes->post('emprendedor/negocio', 'AuthController::switchBusiness', ['filter' => ['auth', 'csrf']]);
$routes->get('cuenta/cambiar-clave', 'CuentaController::edit');
$routes->post('cuenta/cambiar-clave', 'CuentaController::update', ['filter' => ['auth', 'csrf']]);

// Administracion general
$routes->get('admin', 'Admin\DashboardController::index');
$routes->get('admin/emprendimientos', 'Admin\EmprendimientosController::index');
$routes->get('admin/emprendimientos/create', 'Admin\EmprendimientosController::create');
$routes->get('admin/emprendimientos/edit/(:num)', 'Admin\EmprendimientosController::edit/$1');
$routes->post('admin/emprendimientos', 'Admin\EmprendimientosController::store', ['filter' => ['auth', 'csrf']]);
$routes->post('admin/emprendimientos/(:num)', 'Admin\EmprendimientosController::update/$1', ['filter' => ['auth', 'csrf']]);

// Panel del propietario
$routes->get('emprendedor', 'Emprendedor\ResumenController::index');
$routes->get('emprendedor/productos', 'Emprendedor\ProductosController::index');
$routes->get('emprendedor/productos/create', 'Emprendedor\ProductosController::create');
$routes->get('emprendedor/productos/edit/(:num)', 'Emprendedor\ProductosController::edit/$1');
$routes->post('emprendedor/productos', 'Emprendedor\ProductosController::store', ['filter' => ['auth', 'csrf']]);
$routes->post('emprendedor/productos/(:num)', 'Emprendedor\ProductosController::update/$1', ['filter' => ['auth', 'csrf']]);
$routes->post('emprendedor/productos/(:num)/eliminar', 'Emprendedor\ProductosController::delete/$1', ['filter' => ['auth', 'csrf']]);
$routes->get('emprendedor/servicios', 'Emprendedor\ServiciosController::index');
$routes->get('emprendedor/servicios/create', 'Emprendedor\ServiciosController::create');
$routes->get('emprendedor/servicios/edit/(:num)', 'Emprendedor\ServiciosController::edit/$1');
$routes->post('emprendedor/servicios', 'Emprendedor\ServiciosController::store', ['filter' => ['auth', 'csrf']]);
$routes->post('emprendedor/servicios/(:num)', 'Emprendedor\ServiciosController::update/$1', ['filter' => ['auth', 'csrf']]);
$routes->post('emprendedor/servicios/(:num)/eliminar', 'Emprendedor\ServiciosController::delete/$1', ['filter' => ['auth', 'csrf']]);
$routes->get('emprendedor/ventas', 'Emprendedor\VentasController::index');
$routes->get('emprendedor/ventas/create', 'Emprendedor\VentasController::create');
$routes->post('emprendedor/ventas', 'Emprendedor\VentasController::store', ['filter' => ['auth', 'csrf']]);
$routes->get('emprendedor/configuracion', 'Emprendedor\ConfiguracionController::index');
$routes->get('emprendedor/configuracion/edit', 'Emprendedor\ConfiguracionController::edit');
$routes->post('emprendedor/configuracion', 'Emprendedor\ConfiguracionController::update', ['filter' => ['auth', 'csrf']]);
$routes->get('emprendedor/empleados', 'Emprendedor\EmpleadosController::index');
$routes->get('emprendedor/empleados/create', 'Emprendedor\EmpleadosController::create');
$routes->get('emprendedor/empleados/edit/(:num)', 'Emprendedor\EmpleadosController::edit/$1');
$routes->post('emprendedor/empleados', 'Emprendedor\EmpleadosController::store', ['filter' => ['auth', 'csrf']]);
$routes->post('emprendedor/empleados/(:num)', 'Emprendedor\EmpleadosController::update/$1', ['filter' => ['auth', 'csrf']]);

// Espacio de trabajo del empleado
$routes->get('empleado', 'Empleado\VentasController::index');
$routes->get('empleado/ventas', 'Empleado\VentasController::index');
$routes->get('empleado/ventas/create', 'Empleado\VentasController::create');
$routes->post('empleado/ventas', 'Empleado\VentasController::store', ['filter' => ['auth', 'csrf']]);
