<?= $this->extend('layouts/sistema') ?>
<?= $this->section('actions') ?>
<a class="btn btn-success" href="<?= site_url('emprendedor/configuracion/edit') ?>">Editar perfil</a>
<?= $this->endSection() ?>
<?= $this->section('content') ?>
<div class="row g-3">
    <section class="card p-3 col-12 col-lg-6">
        <div class="panel-heading"><div><h2>Perfil comercial</h2><p>Información general del negocio</p></div></div>
        <?php if ($negocio !== null): ?>
            <dl class="row mb-0">
                <dt class="col-sm-5">Nombre comercial</dt><dd class="col-sm-7"><?= esc($negocio['nombre']) ?></dd>
                <dt class="col-sm-5">Identificación</dt><dd class="col-sm-7"><?= esc($negocio['identificacion'] ?? '—') ?></dd>
                <dt class="col-sm-5">Representante</dt><dd class="col-sm-7"><?= esc($negocio['representante'] ?? '—') ?></dd>
                <dt class="col-sm-5">Categoría</dt><dd class="col-sm-7"><?= esc($categoria ?? '—') ?></dd>
                <dt class="col-sm-5">Teléfono</dt><dd class="col-sm-7"><?= esc($negocio['telefono'] ?? '—') ?></dd>
                <dt class="col-sm-5">Correo</dt><dd class="col-sm-7"><?= esc($negocio['correo'] ?? '—') ?></dd>
                <dt class="col-sm-5">Dirección</dt><dd class="col-sm-7"><?= esc($negocio['direccion'] ?? '—') ?></dd>
            </dl>
        <?php else: ?>
            <div class="empty-state"><strong>Perfil no disponible</strong><p>No se encontró el negocio activo.</p></div>
        <?php endif ?>
    </section>
    <section class="card p-3 col-12 col-lg-6">
        <div class="panel-heading"><div><h2>Modelo de catálogo</h2><p>Se podrá usar productos, servicios o ambos.</p></div></div>
        <div class="section-stack">
            <span class="tag tag-muted">Productos: <?= ! empty($negocio['usa_productos']) ? 'Activo' : 'Inactivo' ?></span>
            <span class="tag tag-muted">Servicios: <?= ! empty($negocio['usa_servicios']) ? 'Activo' : 'Inactivo' ?></span>
        </div>
    </section>
</div>
<?= $this->endSection() ?>
