<?= $this->extend('layouts/sistema') ?>
<?= $this->section('content') ?>
<section class="card p-3 p-md-4 form-shell">
    <p class="form-hint">Los servicios no manejan stock. Este formulario todavía no registra información.</p>
    <form>
        <div class="row g-3">
            <div class="col-12 col-md-6"><label class="form-label" for="service-name">Nombre del servicio</label><input class="form-control" id="service-name" name="nombre" placeholder="Ej. Recorrido guiado"></div>
            <div class="col-12 col-md-6"><label class="form-label" for="service-category">Sector / categoría</label><select class="form-select" id="service-category" name="categoria"><option value="">Seleccionar categoría</option><option>Agropecuario</option><option>Gastronómico</option><option>Artesanal</option><option>Textil</option><option>Turístico</option><option>Otro</option></select></div>
            <div class="col-12 col-md-6"><label class="form-label" for="service-price">Precio (USD)</label><input class="form-control" id="service-price" name="precio" type="number" min="0" step="0.01" placeholder="0.00"></div>
            <div class="col-12 col-md-6"><label class="form-label" for="service-state">Estado</label><select class="form-select" id="service-state" name="estado"><option>Activo</option><option>Inactivo</option></select></div>
            <div class="col-12"><label class="form-label" for="service-description">Descripción</label><textarea class="form-control" id="service-description" name="descripcion" placeholder="Describe qué incluye el servicio"></textarea></div>
        </div>
        <div class="d-flex flex-wrap gap-2 mt-4 pt-3 border-top"><button class="btn btn-success" type="button" disabled>Guardar servicio</button><a class="btn btn-outline-secondary" href="<?= site_url('emprendedor/servicios') ?>">Cancelar</a></div>
    </form>
</section>
<?= $this->endSection() ?>
