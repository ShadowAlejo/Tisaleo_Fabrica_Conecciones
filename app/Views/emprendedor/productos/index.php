<?= $this->extend('layouts/sistema') ?>
<?= $this->section('actions') ?>
<a class="btn btn-success" href="<?= site_url('emprendedor/productos/create') ?>">Registrar producto</a>
<?= $this->endSection() ?>
<?= $this->section('content') ?>
<div class="toolbar d-flex flex-wrap align-items-center gap-2 mb-3"><input class="form-control" type="search" aria-label="Buscar productos" placeholder="Buscar por nombre o código" disabled><select class="form-select" aria-label="Filtrar por categoría" disabled><option>Todas las categorías</option></select><select class="form-select" aria-label="Filtrar por stock" disabled><option>Todos los niveles de stock</option></select></div>
<div class="table-responsive rounded border bg-white"><table class="table table-hover align-middle mb-0"><thead class="table-light"><tr><th>Producto</th><th>Categoría</th><th>Precio</th><th>Existencias</th><th>Stock mínimo</th><th>Estado</th><th></th></tr></thead><tbody><tr><td colspan="7"><div class="empty-state"><strong>Catálogo todavía vacío</strong><p>Los productos físicos aparecerán aquí cuando se conecte el almacenamiento. El stock y el Kardex todavía no se modifican desde esta plantilla.</p><a class="btn btn-success" href="<?= site_url('emprendedor/productos/create') ?>">Crear primer producto</a></div></td></tr></tbody></table></div>
<?= $this->endSection() ?>
