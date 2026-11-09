<?= $this->extend('layouts/sistema') ?>
<?= $this->section('actions') ?>
<a class="btn btn-success" href="<?= site_url('emprendedor/empleados/create') ?>">Agregar empleado</a>
<?= $this->endSection() ?>
<?= $this->section('content') ?>
<div class="table-responsive rounded border bg-white"><table class="table table-hover align-middle mb-0">
    <thead class="table-light"><tr><th>Empleado</th><th>Correo</th><th>Teléfono</th><th>Estado</th><th>Acciones</th></tr></thead>
    <tbody>
    <?php if ($empleados === []): ?>
        <tr><td colspan="5"><div class="empty-state"><strong>Aún no hay empleados</strong><p>Agrega una cuenta para el equipo de este negocio.</p><a class="btn btn-success" href="<?= site_url('emprendedor/empleados/create') ?>">Agregar primer empleado</a></div></td></tr>
    <?php else: foreach ($empleados as $empleado): ?>
        <tr>
            <td><?= esc(trim($empleado['nombre'] . ' ' . $empleado['apellido'])) ?></td><td><?= esc($empleado['correo']) ?></td><td><?= esc($empleado['telefono'] ?? '—') ?></td>
            <td><?= (int) $empleado['activo'] === 1 ? '<span class="badge text-bg-success">Activo</span>' : '<span class="badge text-bg-secondary">Inactivo</span>' ?></td>
            <td><a class="btn btn-sm btn-outline-primary" href="<?= site_url('emprendedor/empleados/edit/' . (int) $empleado['id']) ?>">Editar</a></td>
        </tr>
    <?php endforeach; endif ?>
    </tbody>
</table></div>
<p class="form-hint mt-3">Los empleados solo pueden acceder al negocio al que pertenece esta cuenta.</p>
<?= $this->endSection() ?>
