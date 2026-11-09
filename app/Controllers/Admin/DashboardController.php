<?php

namespace App\Controllers\Admin;

use App\Controllers\BaseController;
use App\Libraries\TenantDatabase;
use CodeIgniter\Database\Exceptions\DatabaseException;
use RuntimeException;

class DashboardController extends BaseController
{
    protected string $role = 'admin';

    public function index(): string
    {
        $businesses = db_connect()->table('emprendimientos')
            ->select('database_key')
            ->where('activo', 1)
            ->where('fec_eliminacion', null)
            ->get()->getResultArray();
        $salesToday = 0.0;
        $activeProducts = 0;
        $errors = [];
        $tenantDatabase = new TenantDatabase();

        foreach ($businesses as $business) {
            $key = $business['database_key'];
            if (! is_string($key) || ! in_array($key, $tenantDatabase->allowedKeys(), true)) {
                $errors[] = 'Hay un emprendimiento sin una base operativa autorizada.';
                continue;
            }

            try {
                $database = $tenantDatabase->connectionForKey($key);
                $sales = $database->table('ventas')->selectSum('total')->where('fec_eliminacion', null)->where('fecha_venta >=', date('Y-m-d 00:00:00'))->get()->getRowArray();
                $salesToday += (float) ($sales['total'] ?? 0);
                $activeProducts += $database->table('productos')->where('activo', 1)->where('fec_eliminacion', null)->countAllResults();
            } catch (DatabaseException|RuntimeException $exception) {
                log_message('error', 'No se pudo consultar una base de negocio para el resumen global: {message}', ['message' => $exception->getMessage()]);
                $errors[] = 'No se pudieron consultar todas las bases operativas.';
            }
        }

        return $this->renderPage('admin/resumen/index', 'Resumen general', 'resumen', 'Indicadores de la operación registrada.', [
            'emprendimientosActivos' => count($businesses),
            'ventasHoy' => $salesToday,
            'productosActivos' => $activeProducts,
            'usuariosActivos' => db_connect()->table('usuarios')->where('activo', 1)->where('fec_eliminacion', null)->countAllResults(),
            'errors' => array_values(array_unique($errors)),
        ]);
    }
}
