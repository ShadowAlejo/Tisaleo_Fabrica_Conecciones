<?php

namespace App\Controllers\Emprendedor;

use App\Controllers\BaseController;
use CodeIgniter\Database\Exceptions\DatabaseException;
use CodeIgniter\HTTP\RedirectResponse;

class VentasController extends BaseController
{
    public function index(): string|\CodeIgniter\HTTP\RedirectResponse
    {
        $database = tenant_db();
        $query = $database->table('ventas')
            ->select('ventas.id, ventas.fecha_venta, ventas.metodo_pago, ventas.total, COUNT(detalle_venta.id) AS articulos')
            ->join('detalle_venta', 'detalle_venta.venta_id = ventas.id AND detalle_venta.fec_eliminacion IS NULL', 'left')
            ->where('ventas.fec_eliminacion', null);

        $searchInput = $this->request->getGet('buscar');
        $search = is_string($searchInput) ? trim($searchInput) : '';
        if ($search !== '' && ctype_digit($search)) {
            $query->where('ventas.id', (int) $search);
        }
        $fromInput = $this->request->getGet('desde');
        $from = is_string($fromInput) ? $fromInput : '';
        if ($this->validDate($from)) {
            $query->where('ventas.fecha_venta >=', $from . ' 00:00:00');
        }
        $toInput = $this->request->getGet('hasta');
        $to = is_string($toInput) ? $toInput : '';
        if ($this->validDate($to)) {
            $query->where('ventas.fecha_venta <=', $to . ' 23:59:59');
        }

        $prefix = $this->role === 'empleado' ? 'empleado' : 'emprendedor';

        return $this->renderPage(
            'emprendedor/ventas/index',
            'Historial de ventas',
            'ventas',
            'Consulta de ventas y artículos registrados para este negocio.',
            [
                'ventas' => $query->groupBy('ventas.id')->orderBy('ventas.fecha_venta', 'DESC')->get()->getResultArray(),
                'search' => $search,
                'from' => $from,
                'to' => $to,
                'routePrefix' => $prefix,
            ],
        );
    }

    public function create(): string|\CodeIgniter\HTTP\RedirectResponse
    {
        $database = tenant_db();
        $prefix = $this->role === 'empleado' ? 'empleado' : 'emprendedor';

        return $this->renderPage(
            'emprendedor/ventas/create',
            $this->role === 'empleado' ? 'Nueva venta' : 'Venta rápida',
            'ventas',
            'Selecciona los artículos; los precios y el inventario se validan en el servidor.',
            [
                'productos' => $this->catalogEnabled('productos')
                    ? $database->table('productos')->where('activo', 1)->where('fec_eliminacion', null)->orderBy('nombre')->get()->getResultArray()
                    : [],
                'servicios' => $this->catalogEnabled('servicios')
                    ? $database->table('servicios')->where('estado', 'activo')->where('fec_eliminacion', null)->orderBy('nombre')->get()->getResultArray()
                    : [],
                'routePrefix' => $prefix,
                'errors' => session()->getFlashdata('errors') ?? [],
            ],
        );
    }

    public function store(): RedirectResponse
    {
        $items = $this->request->getPost('items');
        $method = $this->request->getPost('metodo_pago');
        $prefix = $this->role === 'empleado' ? 'empleado' : 'emprendedor';
        if (! is_array($items) || $items === [] || ! is_string($method) || ! in_array($method, ['efectivo', 'transferencia', 'mixto'], true)) {
            return redirect()->back()->withInput()->with('errors', ['venta' => 'Agrega al menos un artículo e indica el medio de cobro.']);
        }

        $database = tenant_db();
        $database->transBegin();
        try {
            $lineItems = [];
            $subtotal = 0.0;
            foreach ($items as $item) {
                if (! is_array($item) || ! in_array($item['tipo'] ?? null, ['producto', 'servicio'], true)) {
                    throw new \InvalidArgumentException('El ticket contiene un artículo inválido.');
                }
                if (! $this->catalogEnabled($item['tipo'] === 'producto' ? 'productos' : 'servicios')) {
                    throw new \InvalidArgumentException('Ese tipo de catálogo está desactivado para este negocio.');
                }
                $idInput = $item['id'] ?? null;
                $quantityInput = $item['cantidad'] ?? null;
                if ((! is_string($idInput) && ! is_int($idInput)) || (! is_string($quantityInput) && ! is_int($quantityInput) && ! is_float($quantityInput))) {
                    throw new \InvalidArgumentException('Revisa el artículo y la cantidad indicados.');
                }
                $id = filter_var($idInput, FILTER_VALIDATE_INT);
                $quantityText = (string) $quantityInput;
                $quantity = preg_match('/\A(?:\d+)(?:\.\d{1,2})?\z/', $quantityText) ? (float) $quantityText : false;
                if ($id === false || $id < 1 || $quantity === false || $quantity <= 0 || $quantity > 999999) {
                    throw new \InvalidArgumentException('Revisa el artículo y la cantidad indicados.');
                }

                if ($item['tipo'] === 'producto') {
                    $record = $database->query(
                        'SELECT id, nombre, precio, cantidad FROM productos WHERE id = ? AND activo = 1 AND fec_eliminacion IS NULL FOR UPDATE',
                        [$id],
                    )->getRowArray();
                    if ($record === null || (float) $record['cantidad'] < $quantity) {
                        throw new \InvalidArgumentException('Un producto ya no tiene existencias suficientes.');
                    }
                    $lineItems[] = [
                        'type' => 'producto',
                        'id' => (int) $record['id'],
                        'name' => $record['nombre'],
                        'quantity' => $quantity,
                        'price' => (float) $record['precio'],
                    ];
                } else {
                    $record = $database->table('servicios')
                        ->where('id', $id)->where('estado', 'activo')->where('fec_eliminacion', null)
                        ->get()->getRowArray();
                    if ($record === null) {
                        throw new \InvalidArgumentException('Un servicio seleccionado ya no está disponible.');
                    }
                    $lineItems[] = [
                        'type' => 'servicio',
                        'id' => (int) $record['id'],
                        'name' => $record['nombre'],
                        'quantity' => $quantity,
                        'price' => (float) $record['precio'],
                    ];
                }
                $lineSubtotal = round($quantity * $lineItems[array_key_last($lineItems)]['price'], 2);
                $subtotal += $lineSubtotal;
            }

            $database->table('ventas')->insert([
                'usuario_id' => (int) session('auth_user')['id'],
                'estado' => 'completada',
                'metodo_pago' => $method,
                'subtotal' => number_format($subtotal, 2, '.', ''),
                'total' => number_format($subtotal, 2, '.', ''),
            ]);
            $saleId = (int) $database->insertID();

            foreach ($lineItems as $line) {
                $lineSubtotal = round($line['quantity'] * $line['price'], 2);
                $database->table('detalle_venta')->insert([
                    'venta_id' => $saleId,
                    'producto_id' => $line['type'] === 'producto' ? $line['id'] : null,
                    'servicio_id' => $line['type'] === 'servicio' ? $line['id'] : null,
                    'nombre_item' => $line['name'],
                    'cantidad' => $line['quantity'],
                    'precio_unitario' => number_format($line['price'], 2, '.', ''),
                    'subtotal' => number_format($lineSubtotal, 2, '.', ''),
                ]);

                if ($line['type'] === 'producto') {
                    $database->query(
                        'UPDATE productos SET cantidad = cantidad - ? WHERE id = ? AND cantidad >= ?',
                        [$line['quantity'], $line['id'], $line['quantity']],
                    );
                    if ($database->affectedRows() !== 1) {
                        throw new \InvalidArgumentException('El inventario cambió mientras se registraba la venta. Revisa las existencias.');
                    }
                    $database->table('movimientos_inventario')->insert([
                        'producto_id' => $line['id'],
                        'usuario_id' => (int) session('auth_user')['id'],
                        'venta_id' => $saleId,
                        'tipo' => 'salida',
                        'cantidad' => $line['quantity'],
                        'motivo' => 'Venta #' . $saleId,
                    ]);
                }
            }

            if (! $database->transStatus()) {
                throw new DatabaseException('No se pudo completar la venta.');
            }
            $database->transCommit();
        } catch (\InvalidArgumentException $exception) {
            $database->transRollback();

            return redirect()->back()->withInput()->with('errors', ['venta' => $exception->getMessage()]);
        } catch (DatabaseException $exception) {
            $database->transRollback();
            log_message('error', 'No se pudo registrar la venta: {message}', ['message' => $exception->getMessage()]);

            return redirect()->back()->withInput()->with('auth_error', 'No se pudo registrar la venta. Verifica la conexión de la base del negocio e inténtalo nuevamente.');
        }

        return redirect()->to(site_url($prefix . '/ventas'))->with('success', 'Venta registrada correctamente.');
    }

    private function validDate(string $date): bool
    {
        $parsed = \DateTime::createFromFormat('!Y-m-d', $date);

        return $parsed !== false && $parsed->format('Y-m-d') === $date;
    }
}
