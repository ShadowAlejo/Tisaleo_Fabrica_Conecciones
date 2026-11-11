<?php

use CodeIgniter\Router\RouteCollection;

/** @var RouteCollection $routes */
$routes->get('/', 'WelcomeController::index');
$routes->get('login', 'LoginController::index');
