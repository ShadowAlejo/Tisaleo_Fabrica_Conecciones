<?= $this->extend('layouts/sistema') ?>
<?= $this->section('actions') ?>
<a class="btn btn-success" href="<?= site_url('admin/emprendimientos/create') ?>">Nuevo emprendimiento</a>
<?= $this->endSection() ?>
<?= $this->section('content') ?>
<div class="toolbar d-flex flex-wrap align-items-center gap-2 mb-3"><input class="form-control" type="search" aria-label="Buscar emprendimientos" placeholder="Buscar emprendimiento" disabled><select class="form-select" aria-label="Filtrar por sector" disabled><option>Todos los sectores</option></select></div>
<div class="table-responsive rounded border bg-white"><table class="table table-hover align-middle mb-0"><thead class="table-light"><tr><th>Emprendimiento</th><th>Propietario</th><th>Sector</th><th>Estado</th><th>Acciones</th></tr></thead><tbody><tr><td colspan="5"><div class="empty-state"><strong>Directorio sin datos</strong><p>El listado global estará disponible cuando se implemente el registro de emprendimientos en el servidor.</p></div></td></tr></tbody></table></div>
<?= $this->endSection() ?>
