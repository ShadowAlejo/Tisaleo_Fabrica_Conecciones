<?= $this->extend('layouts/sistema') ?>
<?= $this->section('actions') ?>
<a class="btn btn-success" href="<?= site_url('empleado/ventas/create') ?>">Nueva venta</a>
<?= $this->endSection() ?>
<?= $this->section('content') ?>
<div class="toolbar d-flex flex-wrap align-items-center gap-2 mb-3"><input class="form-control" type="search" aria-label="Buscar ventas" placeholder="Buscar por referencia" disabled><input class="form-control" type="date" aria-label="Filtrar fecha" disabled></div>
<div class="table-responsive rounded border bg-white"><table class="table table-hover align-middle mb-0"><thead class="table-light"><tr><th>Fecha</th><th>Referencia</th><th>Artículos</th><th>Total (USD)</th><th></th></tr></thead><tbody><tr><td colspan="5"><div class="empty-state"><strong>Sin ventas para mostrar</strong><p>Este historial se compartirá con el del emprendimiento cuando las ventas se registren en el servidor.</p><a class="btn btn-success" href="<?= site_url('empleado/ventas/create') ?>">Iniciar venta</a></div></td></tr></tbody></table></div>
<?= $this->endSection() ?>
