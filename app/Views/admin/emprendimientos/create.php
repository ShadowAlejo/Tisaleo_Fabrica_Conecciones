<?= $this->extend('layouts/sistema') ?>
<?= $this->section('content') ?>
<section class="card p-3 p-md-4 form-shell">
    <p class="form-hint">Formulario de estructura. El registro y la asignación de propietario todavía no guardan información.</p>
    <form>
        <div class="row g-3">
            <div class="col-12 col-md-6"><label class="form-label" for="business-name">Nombre comercial</label><input class="form-control" id="business-name" name="nombre" placeholder="Ej. Taller La Colmena"></div>
            <div class="col-12 col-md-6"><label class="form-label" for="business-sector">Sector</label><select class="form-select" id="business-sector" name="sector"><option value="">Seleccionar sector</option><option>Agropecuario</option><option>Gastronómico</option><option>Artesanal</option><option>Textil</option><option>Turístico</option><option>Otro</option></select></div>
            <div class="col-12 col-md-6"><label class="form-label" for="owner-name">Nombre del propietario</label><input class="form-control" id="owner-name" name="propietario" placeholder="Nombre y apellido"></div>
            <div class="col-12 col-md-6"><label class="form-label" for="owner-email">Correo de contacto</label><input class="form-control" id="owner-email" name="correo" type="email" placeholder="nombre@correo.com"></div>
            <div class="col-12 col-md-6"><label class="form-label" for="business-phone">Teléfono</label><input class="form-control" id="business-phone" name="telefono" type="tel" placeholder="09XXXXXXXX"></div>
            <div class="col-12 col-md-6"><label class="form-label" for="business-id">RUC / RIMPE</label><input class="form-control" id="business-id" name="identificacion" placeholder="Identificación tributaria"></div>
            <div class="col-12"><label class="form-label" for="business-address">Dirección</label><input class="form-control" id="business-address" name="direccion" placeholder="Sector, calle o referencia"></div>
        </div>
        <div class="d-flex flex-wrap gap-2 mt-4 pt-3 border-top"><button class="btn btn-success" type="button" disabled>Crear emprendimiento</button><a class="btn btn-outline-secondary" href="<?= site_url('admin/emprendimientos') ?>">Volver al directorio</a></div>
    </form>
</section>
<?= $this->endSection() ?>
