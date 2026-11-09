<?php

namespace App\Controllers\Admin;

use App\Controllers\BaseController;
use App\Libraries\TenantDatabase;
use CodeIgniter\Database\Exceptions\DatabaseException;
use CodeIgniter\HTTP\RedirectResponse;
use RuntimeException;

class EmprendimientosController extends BaseController
{
    protected string $role = 'admin';

    public function index(): string
    {
        $businesses = db_connect()->table('emprendimientos AS e')
            ->select('e.id, e.nombre, e.database_key, e.activo, e.categoria')
            ->where('e.fec_eliminacion', null)
            ->orderBy('e.nombre')
            ->get()->getResultArray();

        foreach ($businesses as &$business) {
            $business['propietario'] = $this->findOwner((int) $business['id']);
        }
        unset($business);

        return $this->renderPage('admin/emprendimientos/index', 'Emprendimientos', 'emprendimientos', 'Directorio de espacios comerciales registrados.', [
            'emprendimientos' => $businesses,
            'availableKeys' => $this->availableTenantKeys(),
        ]);
    }

    public function create(): string
    {
        return $this->renderPage('admin/emprendimientos/create', 'Nuevo emprendimiento', 'emprendimientos', 'Registra el negocio y crea la cuenta inicial de su propietario.', [
            'availableKeys' => $this->availableTenantKeys(),
            'errors' => session()->getFlashdata('errors') ?? [],
        ]);
    }

    public function store(): RedirectResponse
    {
        if (! $this->validateBusinessInput(true)) {
            return redirect()->back()->withInput()->with('errors', $this->validator->getErrors());
        }

        $post = $this->request->getPost();
        $email = mb_strtolower(trim((string) $post['correo']));
        $central = db_connect();
        if ($central->table('usuarios')->where('correo', $email)->countAllResults() > 0) {
            return redirect()->back()->withInput()->with('errors', ['correo' => 'Ya existe una cuenta con ese correo.']);
        }

        $tenantKey = (string) $post['database_key'];
        if (! in_array($tenantKey, (new TenantDatabase())->allowedKeys(), true) || $this->tenantKeyInUse($tenantKey)) {
            return redirect()->back()->withInput()->with('errors', ['database_key' => 'Selecciona una base operativa disponible.']);
        }
        try {
            $tenant = (new TenantDatabase())->connectionForKey($tenantKey);
            $tenant->initialize();
            if (! $tenant->tableExists('productos') || ! $tenant->tableExists('servicios')) {
                return redirect()->back()->withInput()->with('errors', ['database_key' => 'La base seleccionada aún no tiene el esquema operativo.']);
            }
        } catch (DatabaseException|RuntimeException $exception) {
            log_message('error', 'No se pudo verificar la base al registrar el negocio: {message}', ['message' => $exception->getMessage()]);

            return redirect()->back()->withInput()->with('auth_error', 'No se pudo conectar con la base seleccionada.');
        }

        $temporaryPassword = bin2hex(random_bytes(5));
        $nameParts = preg_split('/\s+/', trim((string) $post['propietario']), 2) ?: [];
        $central->transBegin();
        try {
            $central->table('emprendimientos')->insert([
                'categoria' => trim((string) $post['categoria']),
                'nombre' => trim((string) $post['nombre']),
                'identificacion' => trim((string) $post['identificacion']) ?: null,
                'representante' => trim((string) $post['propietario']) ?: null,
                'database_key' => $tenantKey,
                'telefono' => trim((string) $post['telefono']) ?: null,
                'correo' => $email,
                'direccion' => trim((string) $post['direccion']) ?: null,
                'activo' => 1,
            ]);
            $businessId = (int) $central->insertID();
            $ownerRole = $this->findOrCreateOwnerRole();
            $central->table('usuarios')->insert([
                'rol_id' => $ownerRole,
                'emprendimiento_id' => $businessId,
                'nombre' => $nameParts[0] ?? '',
                'apellido' => $nameParts[1] ?? '',
                'correo' => $email,
                'password_hash' => password_hash($temporaryPassword, PASSWORD_DEFAULT),
                'debe_cambiar_clave' => 1,
                'activo' => 1,
            ]);
            $ownerId = (int) $central->insertID();
            $central->table('usuario_emprendimientos')->insert([
                'usuario_id' => $ownerId,
                'emprendimiento_id' => $businessId,
            ]);
            if (! $central->transStatus()) {
                throw new DatabaseException('No se pudo guardar el emprendimiento y la cuenta de propietario.');
            }
            $central->transCommit();
        } catch (DatabaseException $exception) {
            $central->transRollback();
            log_message('error', 'No se pudo registrar el emprendimiento: {message}', ['message' => $exception->getMessage()]);

            return redirect()->back()->withInput()->with('auth_error', 'No se pudo crear el emprendimiento. Verifica los datos y la base central.');
        }

        return redirect()->to(site_url('admin/emprendimientos'))
            ->with('success', 'Emprendimiento y cuenta de propietario creados. Comparte la contraseña temporal de forma segura.')
            ->with('temporary_password', $temporaryPassword);
    }

    public function edit(int $id): string|RedirectResponse
    {
        $business = $this->findBusiness($id);
        if ($business === null) {
            return redirect()->to(site_url('admin/emprendimientos'))->with('auth_error', 'No se encontró el emprendimiento.');
        }

        return $this->renderPage('admin/emprendimientos/edit', 'Editar emprendimiento', 'emprendimientos', 'Actualiza los datos y el estado del emprendimiento.', [
            'negocio' => $business,
            'propietario' => $this->findOwner($id),
            'categoria' => $business['categoria'],
            'errors' => session()->getFlashdata('errors') ?? [],
        ]);
    }

    public function update(int $id): RedirectResponse
    {
        $business = $this->findBusiness($id);
        $owner = $this->findOwner($id);
        if ($business === null || $owner === null) {
            return redirect()->to(site_url('admin/emprendimientos'))->with('auth_error', 'No se encontró el emprendimiento o su propietario.');
        }
        if (! $this->validateBusinessInput(false)) {
            return redirect()->back()->withInput()->with('errors', $this->validator->getErrors());
        }

        $post = $this->request->getPost();
        $email = mb_strtolower(trim((string) $post['correo']));
        if (db_connect()->table('usuarios')->where('correo', $email)->where('id !=', $owner['id'])->countAllResults() > 0) {
            return redirect()->back()->withInput()->with('errors', ['correo' => 'Ya existe una cuenta con ese correo.']);
        }

        $nameParts = preg_split('/\s+/', trim((string) $post['propietario']), 2) ?: [];
        $central = db_connect();
        $central->transBegin();
        try {
            $central->table('emprendimientos')->where('id', $id)->update([
                'categoria' => trim((string) $post['categoria']),
                'nombre' => trim((string) $post['nombre']),
                'identificacion' => trim((string) $post['identificacion']) ?: null,
                'representante' => trim((string) $post['propietario']) ?: null,
                'telefono' => trim((string) $post['telefono']) ?: null,
                'correo' => $email,
                'direccion' => trim((string) $post['direccion']) ?: null,
                'activo' => (int) $post['estado'],
            ]);
            $central->table('usuarios')->where('id', (int) $owner['id'])->update([
                'nombre' => $nameParts[0] ?? '',
                'apellido' => $nameParts[1] ?? '',
                'correo' => $email,
            ]);
            if (! $central->transStatus()) {
                throw new DatabaseException('No se pudo actualizar el emprendimiento y su propietario.');
            }
            $central->transCommit();
        } catch (DatabaseException $exception) {
            $central->transRollback();
            log_message('error', 'No se pudo actualizar el emprendimiento: {message}', ['message' => $exception->getMessage()]);

            return redirect()->back()->withInput()->with('auth_error', 'No se pudo guardar el emprendimiento.');
        }

        return redirect()->to(site_url('admin/emprendimientos'))->with('success', 'Emprendimiento actualizado correctamente.');
    }

    private function validateBusinessInput(bool $requireDatabaseKey): bool
    {
        $rules = [
            'nombre' => 'required|max_length[150]',
            'categoria' => 'required|max_length[100]',
            'propietario' => 'required|max_length[100]',
            'correo' => 'required|valid_email|max_length[190]',
            'telefono' => 'permit_empty|max_length[30]',
            'identificacion' => 'permit_empty|max_length[40]',
            'direccion' => 'permit_empty|max_length[255]',
        ];
        if ($requireDatabaseKey) {
            $rules['database_key'] = 'required|max_length[40]';
        } else {
            $rules['estado'] = 'required|in_list[0,1]';
        }

        return $this->validate($rules)
            && $this->validatePostScalars(array_keys($rules));
    }

    /**
     * @return list<string>
     */
    private function availableTenantKeys(): array
    {
        $used = db_connect()->table('emprendimientos')->select('database_key')->where('database_key IS NOT NULL')->get()->getResultArray();
        $usedKeys = array_column($used, 'database_key');

        return array_values(array_diff((new TenantDatabase())->allowedKeys(), $usedKeys));
    }

    private function tenantKeyInUse(string $key): bool
    {
        return db_connect()->table('emprendimientos')->where('database_key', $key)->countAllResults() > 0;
    }

    private function findOrCreateOwnerRole(): int
    {
        $database = db_connect();
        $role = $database->table('roles')->where('nombre', 'propietario')->get()->getRowArray();
        if ($role !== null) {
            return (int) $role['id'];
        }
        $database->table('roles')->insert(['nombre' => 'propietario', 'descripcion' => 'Propietario de un emprendimiento']);

        return (int) $database->insertID();
    }

    /**
     * @return array<string, mixed>|null
     */
    private function findBusiness(int $id): ?array
    {
        return db_connect()->table('emprendimientos')->where('id', $id)->where('fec_eliminacion', null)->get()->getRowArray();
    }

    /**
     * @return array<string, mixed>|null
     */
    private function findOwner(int $businessId): ?array
    {
        return db_connect()->table('usuarios')
            ->select('usuarios.id, usuarios.nombre, usuarios.apellido, usuarios.correo')
            ->join('roles', 'roles.id = usuarios.rol_id')
            ->where('usuarios.emprendimiento_id', $businessId)
            ->where('roles.nombre', 'propietario')
            ->where('usuarios.fec_eliminacion', null)
            ->get()->getRowArray();
    }
}
