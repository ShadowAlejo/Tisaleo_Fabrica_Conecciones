<?= $this->extend('layouts/sistema') ?>
<?= $this->section('actions') ?>
<a class="btn btn-success" href="<?= site_url('emprendedor/ventas/create') ?>">Nueva venta</a>
<?= $this->endSection() ?>
<?= $this->section('content') ?>
<div class="toolbar d-flex flex-wrap align-items-center gap-2 mb-3"><input class="form-control" type="search" aria-label="Buscar ventas" placeholder="Buscar por referencia" disabled><input class="form-control" type="date" aria-label="Filtrar desde" disabled><input class="form-control" type="date" aria-label="Filtrar hasta" disabled><button class="btn btn-outline-secondary" type="button" disabled>Exportar CSV</button></div>
<div class="table-responsive rounded border bg-white"><table class="table table-hover align-middle mb-0"><thead class="table-light"><tr><th>Fecha</th><th>Referencia</th><th>Artículos</th><th>Medio de cobro</th><th>Total (USD)</th><th></th></tr></thead><tbody><tr><td colspan="6"><div class="empty-state"><strong>Sin ventas registradas</strong><p>El historial mostrará ventas confirmadas cuando el punto de venta y el almacenamiento estén conectados.</p><a class="btn btn-success" href="<?= site_url('emprendedor/ventas/create') ?>">Abrir venta rápida</a></div></td></tr></tbody></table></div>
<?= $this->endSection() ?>
