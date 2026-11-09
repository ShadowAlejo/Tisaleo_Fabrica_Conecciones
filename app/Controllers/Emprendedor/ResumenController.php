<?php

namespace App\Controllers\Emprendedor;

use App\Controllers\BaseController;
use CodeIgniter\Database\Exceptions\DatabaseException;

class ResumenController extends BaseController
{
    public function index(): string
    {
        $database = tenant_db();

        return $this->renderPage('emprendedor/resumen/index', 'Resumen del negocio', 'resumen', 'Un vistazo a ventas, catálogo y alertas del emprendimiento.', [
            'ventasHoy' => (float) ($database->table('ventas')->selectSum('total')->where('fec_eliminacion', null)->where('fecha_venta >=', date('Y-m-d 00:00:00'))->get()->getRowArray()['total'] ?? 0),
            'productosActivos' => $database->table('productos')->where('activo', 1)->where('fec_eliminacion', null)->countAllResults(),
            'stockBajo' => $database->table('productos')->where('activo', 1)->where('fec_eliminacion', null)->where('cantidad <= stock_minimo', null, false)->countAllResults(),
            'serviciosActivos' => $database->table('servicios')->where('estado', 'activo')->where('fec_eliminacion', null)->countAllResults(),
            'ventasRecientes' => $database->table('ventas')
                ->where('fec_eliminacion', null)
                ->orderBy('fecha_venta', 'DESC')
                ->limit(5)
                ->get()->getResultArray(),
            'usaProductos' => $this->catalogEnabled('productos'),
            'usaServicios' => $this->catalogEnabled('servicios'),
        ]);
    }
}
