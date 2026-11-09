<?= $this->extend('layouts/sistema') ?>
<?= $this->section('actions') ?>
<a class="btn btn-success" href="<?= site_url('emprendedor/servicios/create') ?>">Registrar servicio</a>
<?= $this->endSection() ?>
<?= $this->section('content') ?>
<form class="toolbar d-flex flex-wrap align-items-center gap-2 mb-3" method="get">
    <input class="form-control" type="search" name="buscar" aria-label="Buscar servicios" placeholder="Buscar servicio" value="<?= esc($search) ?>">
    <select class="form-select" name="estado" aria-label="Filtrar servicios"><option value="">Todos los estados</option><option value="activo" <?= $status === 'activo' ? 'selected' : '' ?>>Activos</option><option value="inactivo" <?= $status === 'inactivo' ? 'selected' : '' ?>>Inactivos</option></select>
    <button class="btn btn-outline-secondary" type="submit">Filtrar</button>
</form>
<div class="table-responsive rounded border bg-white"><table class="table table-hover align-middle mb-0">
    <thead class="table-light"><tr><th>Servicio</th><th>Categoría</th><th>Precio (USD)</th><th>Estado</th><th>Acciones</th></tr></thead>
    <tbody>
    <?php if ($servicios === []): ?>
        <tr><td colspan="5"><div class="empty-state"><strong>Sin servicios para mostrar</strong><p>Registra un servicio para iniciar tu catálogo.</p><a class="btn btn-success" href="<?= site_url('emprendedor/servicios/create') ?>">Crear servicio</a></div></td></tr>
    <?php else: foreach ($servicios as $servicio): ?>
        <tr>
            <td><strong><?= esc($servicio['nombre']) ?></strong><div class="small text-body-secondary"><?= esc($servicio['descripcion'] ?? '') ?></div></td>
            <td><?= esc($servicio['categoria'] ?? '—') ?></td>
            <td>$<?= number_format((float) $servicio['precio'], 2, ',', '.') ?></td>
            <td><?= $servicio['estado'] === 'activo' ? '<span class="badge text-bg-success">Activo</span>' : '<span class="badge text-bg-secondary">Inactivo</span>' ?></td>
            <td class="text-nowrap">
                <a class="btn btn-sm btn-outline-primary" href="<?= site_url('emprendedor/servicios/edit/' . (int) $servicio['id']) ?>">Editar</a>
                <?php if ($servicio['estado'] === 'activo'): ?><form class="d-inline" method="post" action="<?= site_url('emprendedor/servicios/' . (int) $servicio['id'] . '/eliminar') ?>" onsubmit="return confirm('¿Desactivar este servicio?')"><?= csrf_field() ?><button class="btn btn-sm btn-outline-danger" type="submit">Desactivar</button></form><?php endif ?>
            </td>
        </tr>
    <?php endforeach; endif ?>
    </tbody>
</table></div>
<?= $this->endSection() ?>
