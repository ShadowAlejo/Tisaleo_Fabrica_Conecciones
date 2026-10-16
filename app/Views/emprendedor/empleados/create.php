<?= $this->extend('layouts/sistema') ?>
<?= $this->section('content') ?>
<section class="card p-3 p-md-4 form-shell">
    <p class="form-hint">Estructura para invitar a una persona al equipo. No crea una cuenta ni define permisos reales.</p>
    <div class="inline-notice mb-3">Los permisos del perfil de empleado quedan pendientes de definición. No uses este prototipo para gestionar acceso real.</div>
    <form>
        <div class="row g-3">
            <div class="col-12 col-md-6"><label class="form-label" for="employee-name">Nombre completo</label><input class="form-control" id="employee-name" name="nombre" placeholder="Nombre y apellido"></div>
            <div class="col-12 col-md-6"><label class="form-label" for="employee-email">Correo electrónico</label><input class="form-control" id="employee-email" name="correo" type="email" placeholder="nombre@correo.com"></div>
            <div class="col-12 col-md-6"><label class="form-label" for="employee-phone">Teléfono</label><input class="form-control" id="employee-phone" name="telefono" type="tel" placeholder="09XXXXXXXX"></div>
            <div class="col-12 col-md-6"><label class="form-label" for="employee-status">Estado</label><select class="form-select" id="employee-status" name="estado"><option>Activo</option><option>Inactivo</option></select></div>
        </div>
        <div class="d-flex flex-wrap gap-2 mt-4 pt-3 border-top"><button class="btn btn-success" type="button" disabled>Crear cuenta</button><a class="btn btn-outline-secondary" href="<?= site_url('emprendedor/empleados') ?>">Cancelar</a></div>
    </form>
</section>
<?= $this->endSection() ?>
