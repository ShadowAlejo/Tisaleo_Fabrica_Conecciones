<?= $this->extend('layouts/sistema') ?>
<?= $this->section('actions') ?>
<a class="btn btn-success" href="<?= site_url('emprendedor/empleados/create') ?>">Agregar empleado</a>
<?= $this->endSection() ?>
<?= $this->section('content') ?>
<div class="inline-notice mb-3">La administración de cuentas y sus permisos todavía no está implementada. Esta sección solo define la estructura visual del equipo.</div>
<div class="table-responsive rounded border bg-white"><table class="table table-hover align-middle mb-0"><thead class="table-light"><tr><th>Empleado</th><th>Correo</th><th>Teléfono</th><th>Estado</th><th></th></tr></thead><tbody><tr><td colspan="5"><div class="empty-state"><strong>Aún no hay empleados</strong><p>Las cuentas se asociarán al emprendimiento actual cuando se implemente autenticación y persistencia.</p><a class="btn btn-success" href="<?= site_url('emprendedor/empleados/create') ?>">Agregar primer empleado</a></div></td></tr></tbody></table></div>
<?= $this->endSection() ?>
