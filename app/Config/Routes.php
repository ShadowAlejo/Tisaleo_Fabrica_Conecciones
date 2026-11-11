<?php

use CodeIgniter\Router\RouteCollection;

/** @var RouteCollection $routes */
$routes->get('/', 'WelcomeController::index');
$routes->get('login', 'LoginController::index');
$routes->post('login', 'LoginController::authenticate', ['filter' => 'csrf']);
$routes->post('logout', 'LoginController::logout', ['filter' => ['auth', 'csrf']]);

$routes->get('admin', 'PagesController::show/admin-summary', ['filter' => ['auth', 'role:admin']]);
$routes->get('admin/emprendimientos', 'PagesController::show/businesses', ['filter' => ['auth', 'role:admin']]);
$routes->get('admin/emprendimientos/create', 'PagesController::show/business-create', ['filter' => ['auth', 'role:admin']]);
$routes->get('admin/emprendimientos/edit/(:num)', 'PagesController::show/business-edit/$1', ['filter' => ['auth', 'role:admin']]);

$routes->get('emprendedor', 'PagesController::show/business-summary', ['filter' => ['auth', 'role:propietario']]);
$routes->get('empleado', 'PagesController::show/business-summary', ['filter' => ['auth', 'role:empleado']]);
$routes->get('emprendedor/productos', 'PagesController::show/products', ['filter' => ['auth', 'role:propietario,empleado']]);
$routes->get('emprendedor/productos/create', 'PagesController::show/product-create', ['filter' => ['auth', 'role:propietario,empleado']]);
$routes->get('emprendedor/productos/edit/(:num)', 'PagesController::show/product-edit/$1', ['filter' => ['auth', 'role:propietario,empleado']]);
$routes->get('emprendedor/servicios', 'PagesController::show/services', ['filter' => ['auth', 'role:propietario,empleado']]);
$routes->get('emprendedor/servicios/create', 'PagesController::show/service-create', ['filter' => ['auth', 'role:propietario,empleado']]);
$routes->get('emprendedor/servicios/edit/(:num)', 'PagesController::show/service-edit/$1', ['filter' => ['auth', 'role:propietario,empleado']]);
$routes->get('emprendedor/empleados', 'PagesController::show/employees', ['filter' => ['auth', 'role:propietario']]);
$routes->get('emprendedor/empleados/create', 'PagesController::show/employee-create', ['filter' => ['auth', 'role:propietario']]);
$routes->get('emprendedor/empleados/edit/(:num)', 'PagesController::show/employee-edit/$1', ['filter' => ['auth', 'role:propietario']]);
$routes->get('emprendedor/ventas', 'PagesController::show/sales', ['filter' => ['auth', 'role:propietario']]);
$routes->get('emprendedor/ventas/create', 'PagesController::show/sale-create', ['filter' => ['auth', 'role:propietario']]);
$routes->get('empleado/ventas', 'PagesController::show/sales', ['filter' => ['auth', 'role:empleado']]);
$routes->get('empleado/ventas/create', 'PagesController::show/sale-create', ['filter' => ['auth', 'role:empleado']]);
$routes->get('emprendedor/configuracion', 'PagesController::show/business-settings', ['filter' => ['auth', 'role:propietario,empleado']]);
$routes->get('emprendedor/configuracion/edit', 'PagesController::show/business-settings-edit', ['filter' => ['auth', 'role:propietario,empleado']]);
$routes->get('cuenta/cambiar-clave', 'PagesController::show/change-password', ['filter' => 'auth']);
