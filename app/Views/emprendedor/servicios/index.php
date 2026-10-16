<?= $this->extend('layouts/sistema') ?>
<?= $this->section('actions') ?>
<a class="btn btn-success" href="<?= site_url('emprendedor/servicios/create') ?>">Registrar servicio</a>
<?= $this->endSection() ?>
<?= $this->section('content') ?>
<div class="toolbar d-flex flex-wrap align-items-center gap-2 mb-3"><input class="form-control" type="search" aria-label="Buscar servicios" placeholder="Buscar servicio" disabled><select class="form-select" aria-label="Filtrar servicios" disabled><option>Todas las categorías</option></select></div>
<div class="table-responsive rounded border bg-white"><table class="table table-hover align-middle mb-0"><thead class="table-light"><tr><th>Servicio</th><th>Categoría</th><th>Precio (USD)</th><th>Estado</th><th></th></tr></thead><tbody><tr><td colspan="5"><div class="empty-state"><strong>Catálogo de servicios vacío</strong><p>Los servicios se ofrecerán sin control de existencias. El catálogo y los precios aún no se guardan.</p><a class="btn btn-success" href="<?= site_url('emprendedor/servicios/create') ?>">Crear primer servicio</a></div></td></tr></tbody></table></div>
<?= $this->endSection() ?>
