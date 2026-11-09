<?php

namespace App\Controllers\Emprendedor;

use App\Controllers\BaseController;
use CodeIgniter\Database\Exceptions\DatabaseException;
use CodeIgniter\HTTP\RedirectResponse;

class EmpleadosController extends BaseController
{
    public function index(): string
    {
        $businessId = (int) session('current_business_id');
        $employees = db_connect()->table('usuarios')
            ->select('usuarios.id, usuarios.nombre, usuarios.apellido, usuarios.correo, usuarios.telefono, usuarios.activo, usuarios.debe_cambiar_clave')
            ->join('roles', 'roles.id = usuarios.rol_id')
            ->where('usuarios.emprendimiento_id', $businessId)
            ->where('roles.nombre', 'empleado')
            ->where('usuarios.fec_eliminacion', null)
            ->orderBy('usuarios.nombre')
            ->get()->getResultArray();

        return $this->renderPage('emprendedor/empleados/index', 'Equipo de trabajo', 'empleados', 'Administra las cuentas de empleado asignadas a este negocio.', [
            'empleados' => $employees,
        ]);
    }

    public function create(): string
    {
        return $this->renderPage('emprendedor/empleados/create', 'Agregar empleado', 'empleados', 'Crea una cuenta exclusiva para el negocio activo.', [
            'errors' => session()->getFlashdata('errors') ?? [],
        ]);
    }

    public function store(): RedirectResponse
    {
        if (! $this->validate([
            'nombre' => 'required|max_length[100]',
            'correo' => 'required|valid_email|max_length[190]',
            'telefono' => 'permit_empty|max_length[30]',
        ]) || ! $this->validatePostScalars(['nombre', 'correo', 'telefono'])) {
            return redirect()->back()->withInput()->with('errors', $this->validator->getErrors());
        }

        $email = mb_strtolower(trim((string) $this->request->getPost('correo')));
        $central = db_connect();
        if ($central->table('usuarios')->where('correo', $email)->countAllResults() > 0) {
            return redirect()->back()->withInput()->with('errors', ['correo' => 'Ya existe una cuenta con ese correo.']);
        }

        $parts = preg_split('/\s+/', trim((string) $this->request->getPost('nombre')), 2) ?: [];
        $temporaryPassword = bin2hex(random_bytes(5));
        $businessId = (int) session('current_business_id');
        $central->transBegin();
        try {
            $role = $central->table('roles')->where('nombre', 'empleado')->get()->getRowArray();
            if ($role === null) {
                throw new DatabaseException('No existe un rol de empleado en la base central.');
            }

            $central->table('usuarios')->insert([
                'rol_id' => (int) $role['id'],
                'emprendimiento_id' => $businessId,
                'nombre' => $parts[0] ?? '',
                'apellido' => $parts[1] ?? '',
                'correo' => $email,
                'telefono' => trim((string) $this->request->getPost('telefono')) ?: null,
                'password_hash' => password_hash($temporaryPassword, PASSWORD_DEFAULT),
                'debe_cambiar_clave' => 1,
                'activo' => 1,
            ]);
            $employeeId = (int) $central->insertID();
            $central->table('usuario_emprendimientos')->insert([
                'usuario_id' => $employeeId,
                'emprendimiento_id' => $businessId,
            ]);

            if (! $central->transStatus()) {
                throw new DatabaseException('No se pudo crear la cuenta y asignarla al negocio.');
            }
            $central->transCommit();
        } catch (DatabaseException $exception) {
            $central->transRollback();
            log_message('error', 'No se pudo crear la cuenta de empleado: {message}', ['message' => $exception->getMessage()]);

            return redirect()->back()->withInput()->with('auth_error', 'No se pudo crear el empleado. Verifica los datos y la base central.');
        }

        return redirect()->to(site_url('emprendedor/empleados'))
            ->with('success', 'Empleado creado. Comparte la contraseña temporal de forma segura.')
            ->with('temporary_password', $temporaryPassword);
    }

    public function edit(int $id): string|RedirectResponse
    {
        $employee = $this->findEmployeeForCurrentBusiness($id);
        if ($employee === null) {
            return redirect()->to(site_url('emprendedor/empleados'))->with('auth_error', 'No se encontró el empleado solicitado.');
        }

        return $this->renderPage('emprendedor/empleados/edit', 'Editar empleado', 'empleados', 'Actualiza los datos y el estado de la cuenta asignada a este negocio.', [
            'empleado' => $employee,
            'errors' => session()->getFlashdata('errors') ?? [],
        ]);
    }

    public function update(int $id): RedirectResponse
    {
        $employee = $this->findEmployeeForCurrentBusiness($id);
        if ($employee === null) {
            return redirect()->to(site_url('emprendedor/empleados'))->with('auth_error', 'No se encontró el empleado solicitado.');
        }
        if (! $this->validate([
            'nombre' => 'required|max_length[100]',
            'correo' => 'required|valid_email|max_length[190]',
            'telefono' => 'permit_empty|max_length[30]',
            'estado' => 'required|in_list[0,1]',
        ]) || ! $this->validatePostScalars(['nombre', 'correo', 'telefono', 'estado'])) {
            return redirect()->back()->withInput()->with('errors', $this->validator->getErrors());
        }

        $email = mb_strtolower(trim((string) $this->request->getPost('correo')));
        if (db_connect()->table('usuarios')->where('correo', $email)->where('id !=', $id)->countAllResults() > 0) {
            return redirect()->back()->withInput()->with('errors', ['correo' => 'Ya existe una cuenta con ese correo.']);
        }

        $parts = preg_split('/\s+/', trim((string) $this->request->getPost('nombre')), 2) ?: [];
        try {
            db_connect()->table('usuarios')->where('id', $id)->update([
                'nombre' => $parts[0] ?? '',
                'apellido' => $parts[1] ?? '',
                'correo' => $email,
                'telefono' => trim((string) $this->request->getPost('telefono')) ?: null,
                'activo' => (int) $this->request->getPost('estado'),
            ]);
        } catch (DatabaseException $exception) {
            log_message('error', 'No se pudo actualizar la cuenta de empleado: {message}', ['message' => $exception->getMessage()]);

            return redirect()->back()->withInput()->with('auth_error', 'No se pudo actualizar el empleado.');
        }

        return redirect()->to(site_url('emprendedor/empleados'))->with('success', 'Empleado actualizado correctamente.');
    }

    /**
     * @return array<string, mixed>|null
     */
    private function findEmployeeForCurrentBusiness(int $id): ?array
    {
        return db_connect()->table('usuarios')
            ->select('usuarios.id, usuarios.nombre, usuarios.apellido, usuarios.correo, usuarios.telefono, usuarios.activo')
            ->join('roles', 'roles.id = usuarios.rol_id')
            ->where('usuarios.emprendimiento_id', (int) session('current_business_id'))
            ->where('roles.nombre', 'empleado')
            ->where('usuarios.id', $id)
            ->where('usuarios.fec_eliminacion', null)
            ->get()->getRowArray();
    }
}
