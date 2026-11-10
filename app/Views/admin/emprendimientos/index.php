<?= $this->extend('layouts/sistema') ?>
<?= $this->section('actions') ?>
<?php if ($availableKeys !== []): ?><a class="btn btn-success" href="<?= site_url('admin/emprendimientos/create') ?>">Nuevo emprendimiento</a><?php endif ?>
<?= $this->endSection() ?>
<?= $this->section('content') ?>
<?php if ($availableKeys === []): ?><div class="alert alert-info" role="status">No hay bases operativas libres. Solo se pueden crear emprendimientos usando una base preconfigurada que todavía no esté asignada.</div><?php endif ?>
<div class="table-responsive rounded border bg-white"><table class="table table-hover align-middle mb-0">
    <thead class="table-light"><tr><th>Emprendimiento</th><th>Propietario</th><th>Categoría</th><th>Base</th><th>Estado</th><th>Acciones</th></tr></thead>
    <tbody>
    <?php if ($emprendimientos === []): ?>
        <tr><td colspan="6"><div class="empty-state"><strong>Directorio vacío</strong><p>Aún no hay emprendimientos registrados.</p></div></td></tr>
    <?php else: foreach ($emprendimientos as $negocio): ?>
        <tr>
            <td><strong><?= esc($negocio['nombre']) ?></strong></td>
            <td><?= esc($negocio['propietario'] ? (trim(($negocio['propietario']['nombre'] ?? '') . ' ' . ($negocio['propietario']['apellido'] ?? '')) ?: $negocio['propietario']['usuario']) : 'Sin propietario') ?><div class="small text-body-secondary"><?= esc($negocio['propietario']['correo'] ?? $negocio['propietario']['usuario'] ?? '') ?></div></td>
            <td><?= esc($negocio['categoria'] ?? '—') ?></td><td><?= esc($negocio['database_key'] ?? '—') ?></td>
            <td><?= (int) $negocio['activo'] === 1 ? '<span class="badge text-bg-success">Activo</span>' : '<span class="badge text-bg-secondary">Inactivo</span>' ?></td>
            <td><a class="btn btn-sm btn-outline-primary" href="<?= site_url('admin/emprendimientos/edit/' . (int) $negocio['id']) ?>">Editar</a></td>
        </tr>
    <?php endforeach; endif ?>
    </tbody>
</table></div>
<?= $this->endSection() ?>
