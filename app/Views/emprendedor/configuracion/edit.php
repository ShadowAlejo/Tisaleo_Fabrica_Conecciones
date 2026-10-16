<?= $this->extend('layouts/sistema') ?>
<?= $this->section('content') ?>
<section class="card p-3 p-md-4 form-shell">
    <p class="form-hint">Plantilla del perfil comercial. Los cambios no se guardan todavía.</p>
    <form>
        <div class="row g-3">
            <div class="col-12 col-md-6"><label class="form-label" for="business-name">Nombre del emprendimiento</label><input class="form-control" id="business-name" name="nombre" placeholder="Nombre comercial"></div>
            <div class="col-12 col-md-6"><label class="form-label" for="business-id">RUC / RIMPE</label><input class="form-control" id="business-id" name="identificacion" placeholder="Identificación tributaria"></div>
            <div class="col-12 col-md-6"><label class="form-label" for="representative">Representante</label><input class="form-control" id="representative" name="representante" placeholder="Nombre y apellido"></div>
            <div class="col-12 col-md-6"><label class="form-label" for="phone">Teléfono</label><input class="form-control" id="phone" name="telefono" type="tel" placeholder="09XXXXXXXX"></div>
            <div class="col-12 col-md-6"><label class="form-label" for="sector">Sector</label><select class="form-select" id="sector" name="sector"><option value="">Seleccionar sector</option><option>Agropecuario</option><option>Gastronómico</option><option>Artesanal</option><option>Textil</option><option>Turístico</option><option>Otro</option></select></div>
            <div class="col-12 col-md-6"><label class="form-label" for="address">Dirección</label><input class="form-control" id="address" name="direccion" placeholder="Sector, calle o referencia"></div>
            <fieldset class="col-12 border-0 p-0 m-0"><legend class="form-label fw-semibold">Tipo de catálogo</legend><div class="row row-cols-1 row-cols-md-2 g-2 mt-1"><label class="card p-3"><span class="form-check"><input class="form-check-input" type="checkbox" name="usa_productos" checked><span class="form-check-label">Productos</span></span><span class="small text-body-secondary">Bienes físicos con control de existencias.</span></label><label class="card p-3"><span class="form-check"><input class="form-check-input" type="checkbox" name="usa_servicios" checked><span class="form-check-label">Servicios</span></span><span class="small text-body-secondary">Oferta comercial sin control de stock.</span></label></div></fieldset>
        </div>
        <div class="d-flex flex-wrap gap-2 mt-4 pt-3 border-top"><button class="btn btn-success" type="button" disabled>Guardar configuración</button><a class="btn btn-outline-secondary" href="<?= site_url('emprendedor/configuracion') ?>">Cancelar</a></div>
    </form>
</section>
<?= $this->endSection() ?>
