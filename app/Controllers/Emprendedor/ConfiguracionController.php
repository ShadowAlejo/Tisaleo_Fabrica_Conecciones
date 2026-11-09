<?php

namespace App\Controllers\Emprendedor;

use App\Controllers\BaseController;
use CodeIgniter\Database\Exceptions\DatabaseException;
use CodeIgniter\HTTP\RedirectResponse;

class ConfiguracionController extends BaseController
{
    public function index(): string
    {
        $business = $this->currentBusiness();

        return $this->renderPage('emprendedor/configuracion/index', 'Configuración', 'configuracion', 'Perfil comercial del emprendimiento activo.', [
            'negocio' => $business,
            'categoria' => $business['categoria'] ?? null,
        ]);
    }

    public function edit(): string|RedirectResponse
    {
        $business = $this->currentBusiness();
        if ($business === null) {
            return redirect()->to(site_url('emprendedor'))->with('auth_error', 'No se encontró el negocio activo.');
        }

        return $this->renderPage('emprendedor/configuracion/edit', 'Editar perfil comercial', 'configuracion', 'Actualiza la información general del negocio.', [
            'negocio' => $business,
            'categoria' => $business['categoria'],
            'errors' => session()->getFlashdata('errors') ?? [],
        ]);
    }

    public function update(): RedirectResponse
    {
        if (! $this->validate([
            'nombre' => 'required|max_length[150]',
            'identificacion' => 'permit_empty|max_length[40]',
            'representante' => 'permit_empty|max_length[150]',
            'telefono' => 'permit_empty|max_length[30]',
            'correo' => 'permit_empty|valid_email|max_length[190]',
            'categoria' => 'required|max_length[100]',
            'direccion' => 'permit_empty|max_length[255]',
            'descripcion' => 'permit_empty|max_length[5000]',
        ]) || ! $this->validatePostScalars([
            'nombre', 'identificacion', 'representante', 'telefono', 'correo', 'categoria', 'direccion', 'descripcion',
            'usa_productos', 'usa_servicios',
        ])) {
            return redirect()->back()->withInput()->with('errors', $this->validator->getErrors());
        }

        $usesProducts = $this->request->getPost('usa_productos') === '1';
        $usesServices = $this->request->getPost('usa_servicios') === '1';
        if (! $usesProducts && ! $usesServices) {
            return redirect()->back()->withInput()->with('errors', ['catalogo' => 'Activa al menos un tipo de catálogo.']);
        }

        $database = db_connect();
        $database->transBegin();
        try {
            $database->table('emprendimientos')
                ->where('id', (int) session('current_business_id'))
                ->where('fec_eliminacion', null)
                ->update([
                    'nombre' => trim((string) $this->request->getPost('nombre')),
                    'identificacion' => trim((string) $this->request->getPost('identificacion')) ?: null,
                    'representante' => trim((string) $this->request->getPost('representante')) ?: null,
                    'telefono' => trim((string) $this->request->getPost('telefono')) ?: null,
                    'correo' => trim((string) $this->request->getPost('correo')) ?: null,
                    'direccion' => trim((string) $this->request->getPost('direccion')) ?: null,
                    'descripcion' => trim((string) $this->request->getPost('descripcion')) ?: null,
                    'categoria' => trim((string) $this->request->getPost('categoria')),
                    'usa_productos' => (int) $usesProducts,
                    'usa_servicios' => (int) $usesServices,
                ]);
            if (! $database->transStatus()) {
                throw new DatabaseException('No se pudo guardar el perfil comercial.');
            }
            $database->transCommit();
        } catch (DatabaseException $exception) {
            $database->transRollback();
            log_message('error', 'No se pudo actualizar el perfil del negocio: {message}', ['message' => $exception->getMessage()]);

            return redirect()->back()->withInput()->with('auth_error', 'No se pudo guardar la configuración del negocio.');
        }
        $businesses = session('auth_businesses') ?? [];
        foreach ($businesses as &$business) {
            if ((int) $business['id'] === (int) session('current_business_id')) {
                $business['nombre'] = trim((string) $this->request->getPost('nombre'));
                $business['usa_productos'] = $usesProducts;
                $business['usa_servicios'] = $usesServices;
            }
        }
        unset($business);
        session()->set('auth_businesses', $businesses);

        return redirect()->to(site_url('emprendedor/configuracion'))->with('success', 'Configuración guardada correctamente.');
    }

    /**
     * @return array<string, mixed>|null
     */
    private function currentBusiness(): ?array
    {
        return db_connect()->table('emprendimientos')
            ->where('id', (int) session('current_business_id'))
            ->where('fec_eliminacion', null)
            ->get()->getRowArray();
    }
}
