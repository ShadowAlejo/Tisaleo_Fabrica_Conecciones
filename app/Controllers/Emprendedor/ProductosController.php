<?php

namespace App\Controllers\Emprendedor;

use App\Controllers\BaseController;
use CodeIgniter\Database\Exceptions\DatabaseException;
use CodeIgniter\HTTP\RedirectResponse;

class ProductosController extends BaseController
{
    public function index(): string|RedirectResponse
    {
        if (! $this->catalogEnabled('productos')) {
            return $this->catalogDisabled();
        }
        $database = tenant_db();
        $query = $database->table('productos')
            ->where('fec_eliminacion', null)
            ->where('activo', 1);
        $searchInput = $this->request->getGet('buscar');
        $search = is_string($searchInput) ? trim($searchInput) : '';
        if ($search !== '') {
            $query->groupStart()
                ->like('nombre', $search)
                ->orLike('codigo', $search)
                ->groupEnd();
        }
        $categoryInput = $this->request->getGet('categoria');
        $category = is_string($categoryInput) ? trim($categoryInput) : '';
        if ($category !== '') {
            $query->where('categoria_unidad', $category);
        }
        $stock = $this->request->getGet('stock');
        if ($stock === 'bajo') {
            $query->where('cantidad <= stock_minimo', null, false);
        } elseif ($stock === 'disponible') {
            $query->where('cantidad > stock_minimo', null, false);
        }

        return $this->renderPage(
            'emprendedor/productos/index',
            'Productos',
            'productos',
            'Catálogo de productos físicos y control de existencias.',
            [
                'productos' => $query
                    ->select('productos.*')
                    ->orderBy('nombre')->get()->getResultArray(),
                'categorias' => $database->table('productos')
                    ->select('categoria_unidad')
                    ->distinct()
                    ->where('activo', 1)
                    ->where('fec_eliminacion', null)
                    ->orderBy('categoria_unidad')
                    ->get()->getResultArray(),
                'search' => $search,
                'category' => $category,
                'stockFilter' => $stock,
            ],
        );
    }

    public function create(): string|RedirectResponse
    {
        if (! $this->catalogEnabled('productos')) {
            return $this->catalogDisabled();
        }
        return $this->renderPage('emprendedor/productos/create', 'Registrar producto', 'productos', 'Define los datos comerciales y el inventario inicial.', [
            'errors' => session()->getFlashdata('errors') ?? [],
        ]);
    }

    public function store(): RedirectResponse
    {
        if (! $this->catalogEnabled('productos')) {
            return $this->catalogDisabled();
        }
        $data = $this->validatedProduct();
        if ($data === null) {
            return redirect()->back()->withInput()->with('errors', $this->validator->getErrors());
        }

        $database = tenant_db();
        if ($data['codigo'] !== null && $database->table('productos')
            ->where('codigo', $data['codigo'])
            ->countAllResults() > 0) {
            return redirect()->back()->withInput()->with('errors', ['codigo' => 'Ese código ya está registrado, incluso en productos desactivados.']);
        }

        $database->transBegin();
        try {
            $database->table('productos')->insert($data);
            $productId = (int) $database->insertID();
            if ($data['cantidad'] > 0) {
                $database->table('movimientos_inventario')->insert([
                    'producto_id' => $productId,
                    'tipo' => 'entrada',
                    'cantidad' => $data['cantidad'],
                    'motivo' => 'Inventario inicial',
                ]);
            }

            if (! $database->transStatus()) {
                throw new DatabaseException('No se pudo registrar el producto y su inventario.');
            }
            $database->transCommit();
        } catch (DatabaseException $exception) {
            $database->transRollback();
            log_message('error', 'No se pudo crear el producto: {message}', ['message' => $exception->getMessage()]);

            return redirect()->back()->withInput()->with('auth_error', 'No se pudo guardar el producto. Verifica los datos y la conexión de la base del negocio.');
        }

        return redirect()->to(site_url('emprendedor/productos'))->with('success', 'Producto registrado correctamente.');
    }

    public function edit(int $id): string|RedirectResponse
    {
        if (! $this->catalogEnabled('productos')) {
            return $this->catalogDisabled();
        }
        $product = tenant_db()->table('productos')
            ->where('id', $id)
            ->where('fec_eliminacion', null)
            ->get()->getRowArray();
        if ($product === null) {
            return redirect()->to(site_url('emprendedor/productos'))->with('auth_error', 'No se encontró el producto solicitado.');
        }

        return $this->renderPage('emprendedor/productos/edit', 'Editar producto', 'productos', 'Actualiza los datos comerciales y las existencias.', [
            'producto' => $product,
            'errors' => session()->getFlashdata('errors') ?? [],
        ]);
    }

    public function update(int $id): RedirectResponse
    {
        if (! $this->catalogEnabled('productos')) {
            return $this->catalogDisabled();
        }
        $database = tenant_db();
        $product = $database->table('productos')
            ->where('id', $id)
            ->where('fec_eliminacion', null)
            ->get()->getRowArray();
        if ($product === null) {
            return redirect()->to(site_url('emprendedor/productos'))->with('auth_error', 'No se encontró el producto solicitado.');
        }

        $data = $this->validatedProduct();
        if ($data === null) {
            return redirect()->back()->withInput()->with('errors', $this->validator->getErrors());
        }
        if ($data['codigo'] !== null && $database->table('productos')
            ->where('codigo', $data['codigo'])
            ->where('id !=', $id)
            ->countAllResults() > 0) {
            return redirect()->back()->withInput()->with('errors', ['codigo' => 'Ese código ya está registrado, incluso en productos desactivados.']);
        }

        $difference = (float) $data['cantidad'] - (float) $product['cantidad'];
        $database->transBegin();
        try {
            $database->table('productos')->where('id', $id)->update($data);
            if (abs($difference) > 0.0001) {
                $database->table('movimientos_inventario')->insert([
                    'producto_id' => $id,
                    'tipo' => $difference > 0 ? 'ajuste_entrada' : 'ajuste_salida',
                    'cantidad' => abs($difference),
                    'motivo' => 'Ajuste desde edición del producto',
                ]);
            }
            if (! $database->transStatus()) {
                throw new DatabaseException('No se pudo actualizar el producto y su inventario.');
            }
            $database->transCommit();
        } catch (DatabaseException $exception) {
            $database->transRollback();
            log_message('error', 'No se pudo actualizar el producto: {message}', ['message' => $exception->getMessage()]);

            return redirect()->back()->withInput()->with('auth_error', 'No se pudo actualizar el producto. Verifica la conexión de la base del negocio.');
        }

        return redirect()->to(site_url('emprendedor/productos'))->with('success', 'Producto actualizado correctamente.');
    }

    public function delete(int $id): RedirectResponse
    {
        if (! $this->catalogEnabled('productos')) {
            return $this->catalogDisabled();
        }
        $database = tenant_db();
        try {
            $database->table('productos')->where('id', $id)->where('fec_eliminacion', null)->update([
                'activo' => 0,
                'fec_eliminacion' => date('Y-m-d H:i:s'),
            ]);
        } catch (DatabaseException $exception) {
            log_message('error', 'No se pudo desactivar el producto: {message}', ['message' => $exception->getMessage()]);

            return redirect()->back()->with('auth_error', 'No se pudo desactivar el producto.');
        }

        return redirect()->to(site_url('emprendedor/productos'))->with('success', 'Producto desactivado.');
    }

    /**
     * @return array<string, mixed>|null
     */
    private function validatedProduct(): ?array
    {
        $rules = [
            'nombre' => 'required|max_length[150]',
            'codigo' => 'permit_empty|max_length[60]',
            'categoria' => 'required|max_length[100]',
            'precio' => 'required|decimal|greater_than_equal_to[0]|less_than_equal_to[99999999.99]',
            'stock' => 'required|decimal|greater_than_equal_to[0]|less_than_equal_to[999999999.99]',
            'stock_minimo' => 'required|decimal|greater_than_equal_to[0]|less_than_equal_to[999999999.99]',
            'descripcion' => 'permit_empty|max_length[5000]',
        ];
        $input = [];
        foreach (array_keys($rules) as $field) {
            $value = $this->request->getPost($field);
            if ($value !== null && ! is_string($value) && ! is_numeric($value)) {
                $this->validateData([], $rules);
                $this->validator->setError($field, 'El valor indicado no es válido.');

                return null;
            }
            $input[$field] = $value;
        }

        foreach (['precio', 'stock'] as $field) {
            $number = (string) ($input[$field] ?? '');
            if (! preg_match('/\A\d+(?:[.,]\d{1,2})?\z/', $number)) {
                $this->validateData($input, $rules);
                $this->validator->setError($field, 'El valor debe tener hasta dos decimales, usando coma o punto.');

                return null;
            }
            $input[$field] = str_replace(',', '.', $number);
        }

        $minimum = (string) ($input['stock_minimo'] ?? '');
        if (! preg_match('/\A\d+(?:[.,]\d{1,2})?\z/', $minimum)) {
            $this->validateData($input, $rules);
            $this->validator->setError('stock_minimo', 'El stock mínimo debe tener hasta dos decimales, usando coma o punto.');

            return null;
        }
        $input['stock_minimo'] = str_replace(',', '.', $minimum);
        if (! $this->validateData($input, $rules)) {
            return null;
        }

        return [
            'nombre' => trim((string) $this->request->getPost('nombre')),
            'codigo' => trim((string) $this->request->getPost('codigo')) ?: null,
            'categoria_unidad' => trim((string) $this->request->getPost('categoria')),
            'unidad_medida' => 'unidad',
            'precio_venta' => number_format((float) $input['precio'], 2, '.', ''),
            'cantidad' => number_format((float) $input['stock'], 2, '.', ''),
            'stock_minimo' => number_format((float) $input['stock_minimo'], 2, '.', ''),
            'descripcion' => trim((string) $this->request->getPost('descripcion')) ?: null,
            'activo' => 1,
        ];
    }

    private function catalogDisabled(): RedirectResponse
    {
        return redirect()->to(site_url('emprendedor'))->with('auth_error', 'El catálogo de productos está desactivado para este negocio.');
    }
}
