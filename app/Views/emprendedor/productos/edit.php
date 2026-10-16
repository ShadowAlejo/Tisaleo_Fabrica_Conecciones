<?= $this->extend('layouts/sistema') ?>
<?= $this->section('content') ?>
<section class="card p-3 p-md-4 form-shell">
    <p class="form-hint">Edición visual del producto #<?= esc($id ?? '') ?>. Los datos y el guardado aún no están conectados.</p>
    <form>
        <div class="row g-3">
            <div class="col-12 col-md-6"><label class="form-label" for="product-name">Nombre del producto</label><input class="form-control" id="product-name" name="nombre" placeholder="Nombre del producto"></div>
            <div class="col-12 col-md-6"><label class="form-label" for="product-code">Código</label><input class="form-control" id="product-code" name="codigo" placeholder="Código interno"></div>
            <div class="col-12 col-md-6"><label class="form-label" for="product-category">Sector / categoría</label><select class="form-select" id="product-category" name="categoria"><option value="">Seleccionar categoría</option><option>Agropecuario</option><option>Gastronómico</option><option>Artesanal</option><option>Textil</option><option>Turístico</option><option>Otro</option></select></div>
            <div class="col-12 col-md-6"><label class="form-label" for="product-price">Precio de venta (USD)</label><input class="form-control" id="product-price" name="precio" type="number" min="0" step="0.01" placeholder="0.00"></div>
            <div class="col-12 col-md-6"><label class="form-label" for="product-stock">Existencias</label><input class="form-control" id="product-stock" name="stock" type="number" min="0" step="1" placeholder="0"></div>
            <div class="col-12 col-md-6"><label class="form-label" for="product-minimum">Stock mínimo</label><input class="form-control" id="product-minimum" name="stock_minimo" type="number" min="0" step="1" placeholder="0"></div>
            <div class="col-12"><label class="form-label" for="product-description">Descripción</label><textarea class="form-control" id="product-description" name="descripcion" placeholder="Descripción breve del producto"></textarea></div>
        </div>
        <div class="d-flex flex-wrap gap-2 mt-4 pt-3 border-top"><button class="btn btn-success" type="button" disabled>Guardar cambios</button><a class="btn btn-outline-secondary" href="<?= site_url('emprendedor/productos') ?>">Cancelar</a></div>
    </form>
</section>
<?= $this->endSection() ?>
