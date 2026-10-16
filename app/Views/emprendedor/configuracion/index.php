<?= $this->extend('layouts/sistema') ?>
<?= $this->section('actions') ?>
<a class="btn btn-success" href="<?= site_url('emprendedor/configuracion/edit') ?>">Editar perfil</a>
<?= $this->endSection() ?>
<?= $this->section('content') ?>
<div class="row g-3">
    <section class="card p-3 col-12 col-lg-6">
        <div class="panel-heading"><div><h2>Perfil comercial</h2><p>Información general del negocio</p></div></div>
        <div class="empty-state"><strong>Perfil pendiente</strong><p>Nombre comercial, identificación, representante, teléfono, sector y dirección se configurarán aquí.</p><a class="btn btn-success" href="<?= site_url('emprendedor/configuracion/edit') ?>">Completar perfil</a></div>
    </section>
    <section class="card p-3 col-12 col-lg-6">
        <div class="panel-heading"><div><h2>Modelo de catálogo</h2><p>Se podrá usar productos, servicios o ambos.</p></div></div>
        <div class="section-stack"><div class="inline-notice">La selección se guardará cuando exista persistencia. El sistema deberá mantener al menos un tipo de catálogo activo.</div><span class="tag tag-muted">Sin configuración guardada</span></div>
    </section>
</div>
<?= $this->endSection() ?>
