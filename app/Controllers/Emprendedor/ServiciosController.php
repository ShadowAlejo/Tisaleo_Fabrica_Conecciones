<?php

namespace App\Controllers\Emprendedor;

use App\Controllers\BaseController;
use CodeIgniter\Database\Exceptions\DatabaseException;
use CodeIgniter\HTTP\RedirectResponse;

class ServiciosController extends BaseController
{
    public function index(): string|RedirectResponse
    {
        if (! $this->catalogEnabled('servicios')) {
            return $this->catalogDisabled();
        }
        $query = tenant_db()->table('servicios')
            ->where('fec_eliminacion', null);
        $searchInput = $this->request->getGet('buscar');
        $search = is_string($searchInput) ? trim($searchInput) : '';
        if ($search !== '') {
            $query->groupStart()->like('nombre', $search)->orLike('descripcion', $search)->groupEnd();
        }
        $statusInput = $this->request->getGet('estado');
        $status = is_string($statusInput) ? trim($statusInput) : '';
        if (in_array($status, ['activo', 'inactivo'], true)) {
            $query->where('estado', $status);
        }

        return $this->renderPage(
            'emprendedor/servicios/index',
            'Servicios',
            'servicios',
            'Catálogo de servicios sin control de existencias.',
            [
                'servicios' => $query->orderBy('nombre')->get()->getResultArray(),
                'search' => $search,
                'status' => $status,
            ],
        );
    }

    public function create(): string|RedirectResponse
    {
        if (! $this->catalogEnabled('servicios')) {
            return $this->catalogDisabled();
        }
        return $this->renderPage('emprendedor/servicios/create', 'Registrar servicio', 'servicios', 'Define los datos comerciales del servicio.', [
            'errors' => session()->getFlashdata('errors') ?? [],
        ]);
    }

    public function store(): RedirectResponse
    {
        if (! $this->catalogEnabled('servicios')) {
            return $this->catalogDisabled();
        }
        $data = $this->validatedService();
        if ($data === null) {
            return redirect()->back()->withInput()->with('errors', $this->validator->getErrors());
        }

        try {
            tenant_db()->table('servicios')->insert($data);
        } catch (DatabaseException $exception) {
            log_message('error', 'No se pudo crear el servicio: {message}', ['message' => $exception->getMessage()]);

            return redirect()->back()->withInput()->with('auth_error', 'No se pudo guardar el servicio. Verifica la conexión de la base del negocio.');
        }

        return redirect()->to(site_url('emprendedor/servicios'))->with('success', 'Servicio registrado correctamente.');
    }

    public function edit(int $id): string|RedirectResponse
    {
        if (! $this->catalogEnabled('servicios')) {
            return $this->catalogDisabled();
        }
        $service = tenant_db()->table('servicios')
            ->where('id', $id)
            ->where('fec_eliminacion', null)
            ->get()->getRowArray();
        if ($service === null) {
            return redirect()->to(site_url('emprendedor/servicios'))->with('auth_error', 'No se encontró el servicio solicitado.');
        }

        return $this->renderPage('emprendedor/servicios/edit', 'Editar servicio', 'servicios', 'Actualiza los datos comerciales del servicio.', [
            'servicio' => $service,
            'errors' => session()->getFlashdata('errors') ?? [],
        ]);
    }

    public function update(int $id): RedirectResponse
    {
        if (! $this->catalogEnabled('servicios')) {
            return $this->catalogDisabled();
        }
        $database = tenant_db();
        $serviceExists = $database->table('servicios')
            ->where('id', $id)
            ->where('fec_eliminacion', null)
            ->countAllResults();
        if ($serviceExists === 0) {
            return redirect()->to(site_url('emprendedor/servicios'))->with('auth_error', 'No se encontró el servicio solicitado.');
        }

        $data = $this->validatedService();
        if ($data === null) {
            return redirect()->back()->withInput()->with('errors', $this->validator->getErrors());
        }
        try {
            $database->table('servicios')->where('id', $id)->update($data);
        } catch (DatabaseException $exception) {
            log_message('error', 'No se pudo actualizar el servicio: {message}', ['message' => $exception->getMessage()]);

            return redirect()->back()->withInput()->with('auth_error', 'No se pudo actualizar el servicio.');
        }

        return redirect()->to(site_url('emprendedor/servicios'))->with('success', 'Servicio actualizado correctamente.');
    }

    public function delete(int $id): RedirectResponse
    {
        if (! $this->catalogEnabled('servicios')) {
            return $this->catalogDisabled();
        }
        try {
            tenant_db()->table('servicios')->where('id', $id)->where('fec_eliminacion', null)->update([
                'estado' => 'inactivo',
                'fec_eliminacion' => date('Y-m-d H:i:s'),
            ]);
        } catch (DatabaseException $exception) {
            log_message('error', 'No se pudo desactivar el servicio: {message}', ['message' => $exception->getMessage()]);

            return redirect()->back()->with('auth_error', 'No se pudo desactivar el servicio.');
        }

        return redirect()->to(site_url('emprendedor/servicios'))->with('success', 'Servicio desactivado.');
    }

    /**
     * @return array<string, mixed>|null
     */
    private function validatedService(): ?array
    {
        $rules = [
            'nombre' => 'required|max_length[150]',
            'categoria' => 'permit_empty|max_length[100]',
            'precio' => 'required|decimal|greater_than_equal_to[0]|less_than_equal_to[99999999.99]',
            'estado' => 'required|in_list[activo,inactivo]',
            'descripcion' => 'permit_empty|max_length[5000]',
        ];
        $fields = array_keys($rules);
        if (! $this->validatePostScalars($fields)) {
            return null;
        }
        $input = [];
        foreach ($fields as $field) {
            $input[$field] = $this->request->getPost($field);
        }
        $price = (string) ($input['precio'] ?? '');
        if (! preg_match('/\A\d+(?:[.,]\d{1,2})?\z/', $price)) {
            $this->validateData($input, $rules);
            $this->validator->setError('precio', 'El precio debe tener hasta dos decimales, usando coma o punto.');

            return null;
        }
        $input['precio'] = str_replace(',', '.', $price);
        if (! $this->validateData($input, $rules)) {
            return null;
        }

        return [
            'nombre' => trim((string) $input['nombre']),
            'categoria' => trim((string) $input['categoria']) ?: null,
            'precio' => number_format((float) $input['precio'], 2, '.', ''),
            'estado' => $input['estado'],
            'descripcion' => trim((string) $input['descripcion']) ?: null,
        ];
    }

    private function catalogDisabled(): RedirectResponse
    {
        return redirect()->to(site_url('emprendedor'))->with('auth_error', 'El catálogo de servicios está desactivado para este negocio.');
    }
}
