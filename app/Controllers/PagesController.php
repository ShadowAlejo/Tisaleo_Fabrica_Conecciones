<?php

namespace App\Controllers;

use CodeIgniter\Controller;
use CodeIgniter\Exceptions\PageNotFoundException;

class PagesController extends Controller
{
    public function show(string $page, ?int $id = null): string
    {
        $role = (string) session()->get('user_role');
        $routePrefix = $role === 'empleado' ? 'empleado' : 'emprendedor';
        $currentBusiness = $this->currentBusiness();
        $pages = $this->pages($routePrefix);

        if (! isset($pages[$page])) {
            throw PageNotFoundException::forPageNotFound();
        }

        $definition = $pages[$page];
        $data = [
            'role' => $role,
            'pageTitle' => $definition['title'],
            'pageDescription' => $definition['description'],
            'activeMenu' => $definition['menu'],
            ...$definition['data'],
        ];
        if ($page === 'business-summary' && $currentBusiness !== null) {
            $data['usaProductos'] = (bool) $currentBusiness['usa_productos'];
            $data['usaServicios'] = (bool) $currentBusiness['usa_servicios'];
        }

        if ($id !== null) {
            $data = array_replace($data, $this->editDefaults($page, $id));
        }

        return view($definition['view'], $data);
    }

    private function pages(string $routePrefix): array
    {
        return [
            'admin-summary' => [
                'view' => 'admin/resumen/index',
                'title' => 'Resumen general',
                'description' => 'Indicadores del sistema.',
                'menu' => 'resumen',
                'data' => [
                    'emprendimientosActivos' => 0,
                    'ventasHoy' => 0,
                    'productosActivos' => 0,
                    'usuariosActivos' => 0,
                    'errors' => [],
                ],
            ],
            'businesses' => [
                'view' => 'admin/emprendimientos/index',
                'title' => 'Emprendimientos',
                'description' => 'Directorio de emprendimientos registrados.',
                'menu' => 'emprendimientos',
                'data' => ['availableKeys' => [], 'emprendimientos' => []],
            ],
            'business-create' => [
                'view' => 'admin/emprendimientos/create',
                'title' => 'Nuevo emprendimiento',
                'description' => 'Registra un emprendimiento en el directorio.',
                'menu' => 'emprendimientos',
                'data' => ['availableKeys' => [], 'errors' => []],
            ],
            'business-edit' => [
                'view' => 'admin/emprendimientos/edit',
                'title' => 'Editar emprendimiento',
                'description' => 'Actualiza la información del emprendimiento.',
                'menu' => 'emprendimientos',
                'data' => ['errors' => []],
            ],
            'business-summary' => [
                'view' => 'emprendedor/resumen/index',
                'title' => 'Resumen del emprendimiento',
                'description' => 'Indicadores de actividad comercial.',
                'menu' => 'resumen',
                'data' => [
                    'ventasHoy' => 0,
                    'productosActivos' => 0,
                    'stockBajo' => 0,
                    'serviciosActivos' => 0,
                    'ventasRecientes' => [],
                    'usaProductos' => true,
                    'usaServicios' => true,
                ],
            ],
            'products' => [
                'view' => 'emprendedor/productos/index',
                'title' => 'Productos',
                'description' => 'Catálogo e inventario del emprendimiento.',
                'menu' => 'productos',
                'data' => [
                    'productos' => [],
                    'categorias' => [],
                    'search' => $this->queryString('buscar'),
                    'category' => $this->queryString('categoria'),
                    'stockFilter' => $this->queryString('stock'),
                ],
            ],
            'product-create' => [
                'view' => 'emprendedor/productos/create',
                'title' => 'Registrar producto',
                'description' => 'Agrega un producto al catálogo.',
                'menu' => 'productos',
                'data' => ['errors' => []],
            ],
            'product-edit' => [
                'view' => 'emprendedor/productos/edit',
                'title' => 'Editar producto',
                'description' => 'Actualiza un producto del catálogo.',
                'menu' => 'productos',
                'data' => ['producto' => [], 'errors' => []],
            ],
            'services' => [
                'view' => 'emprendedor/servicios/index',
                'title' => 'Servicios',
                'description' => 'Oferta de servicios del emprendimiento.',
                'menu' => 'servicios',
                'data' => [
                    'servicios' => [],
                    'search' => $this->queryString('buscar'),
                    'status' => $this->queryString('estado'),
                ],
            ],
            'service-create' => [
                'view' => 'emprendedor/servicios/create',
                'title' => 'Registrar servicio',
                'description' => 'Agrega un servicio al catálogo.',
                'menu' => 'servicios',
                'data' => ['errors' => []],
            ],
            'service-edit' => [
                'view' => 'emprendedor/servicios/edit',
                'title' => 'Editar servicio',
                'description' => 'Actualiza un servicio del catálogo.',
                'menu' => 'servicios',
                'data' => ['servicio' => [], 'errors' => []],
            ],
            'employees' => [
                'view' => 'emprendedor/empleados/index',
                'title' => 'Equipo de trabajo',
                'description' => 'Cuentas asociadas al emprendimiento.',
                'menu' => 'empleados',
                'data' => ['empleados' => []],
            ],
            'employee-create' => [
                'view' => 'emprendedor/empleados/create',
                'title' => 'Agregar empleado',
                'description' => 'Crea una cuenta para el equipo de trabajo.',
                'menu' => 'empleados',
                'data' => ['errors' => []],
            ],
            'employee-edit' => [
                'view' => 'emprendedor/empleados/edit',
                'title' => 'Editar empleado',
                'description' => 'Actualiza los datos de una cuenta.',
                'menu' => 'empleados',
                'data' => ['empleado' => [], 'errors' => []],
            ],
            'sales' => [
                'view' => 'emprendedor/ventas/index',
                'title' => 'Ventas',
                'description' => 'Historial de ventas del emprendimiento.',
                'menu' => 'ventas',
                'data' => [
                    'routePrefix' => $routePrefix,
                    'ventas' => [],
                    'search' => $this->queryString('buscar'),
                    'from' => $this->queryString('desde'),
                    'to' => $this->queryString('hasta'),
                ],
            ],
            'sale-create' => [
                'view' => 'emprendedor/ventas/create',
                'title' => 'Nueva venta',
                'description' => 'Registra una venta del emprendimiento.',
                'menu' => 'ventas',
                'data' => [
                    'routePrefix' => $routePrefix,
                    'productos' => [],
                    'servicios' => [],
                    'errors' => [],
                ],
            ],
            'business-settings' => [
                'view' => 'emprendedor/configuracion/index',
                'title' => 'Configuración',
                'description' => 'Información y modelo de catálogo.',
                'menu' => 'configuracion',
                'data' => ['negocio' => null, 'categoria' => null],
            ],
            'business-settings-edit' => [
                'view' => 'emprendedor/configuracion/edit',
                'title' => 'Editar perfil comercial',
                'description' => 'Actualiza la información del emprendimiento.',
                'menu' => 'configuracion',
                'data' => [
                    'negocio' => [
                        'nombre' => '',
                        'usa_productos' => 1,
                        'usa_servicios' => 1,
                    ],
                    'categoria' => '',
                    'errors' => [],
                ],
            ],
            'change-password' => [
                'view' => 'cuenta/cambiar_clave',
                'title' => 'Cambiar contraseña',
                'description' => '',
                'menu' => '',
                'data' => ['errors' => []],
            ],
        ];
    }

    private function editDefaults(string $page, int $id): array
    {
        return match ($page) {
            'business-edit' => [
                'negocio' => [
                    'id' => $id,
                    'nombre' => '',
                    'propietario' => null,
                    'categoria' => '',
                    'correo' => '',
                    'activo' => 1,
                    'database_key' => '',
                ],
                'categoria' => '',
                'propietario' => [],
            ],
            'product-edit' => ['producto' => ['id' => $id]],
            'service-edit' => ['servicio' => ['id' => $id]],
            'employee-edit' => [
                'empleado' => [
                    'id' => $id,
                    'nombre' => '',
                    'apellido' => '',
                    'correo' => '',
                    'activo' => 1,
                ],
            ],
            default => [],
        };
    }

    private function queryString(string $key): string
    {
        $value = $this->request->getGet($key);

        return is_string($value) ? $value : '';
    }

    private function currentBusiness(): ?array
    {
        $currentId = (int) session()->get('current_business_id');

        foreach (session()->get('auth_businesses') ?? [] as $business) {
            if ((int) $business['id'] === $currentId) {
                return $business;
            }
        }

        return null;
    }
}
