<?= $this->extend('layouts/sistema') ?>
<?= $this->section('content') ?>
<section class="row row-cols-2 row-cols-lg-4 g-3 mb-4" aria-label="Indicadores generales">
    <article class="stat"><span class="stat-label">Emprendimientos</span><strong class="stat-value">—</strong><span class="stat-foot">Datos por conectar</span></article>
    <article class="stat"><span class="stat-label">Ventas del día</span><strong class="stat-value">$ —</strong><span class="stat-foot">Datos por conectar</span></article>
    <article class="stat"><span class="stat-label">Productos activos</span><strong class="stat-value">—</strong><span class="stat-foot">Datos por conectar</span></article>
    <article class="stat"><span class="stat-label">Cuentas de usuario</span><strong class="stat-value">—</strong><span class="stat-foot">Datos por conectar</span></article>
</section>
<div class="row g-3">
    <section class="card p-3 col-12 col-lg-8">
        <div class="panel-heading"><div><h2>Actividad del sistema</h2><p>Vista global para administración</p></div><a class="panel-link" href="<?= site_url('admin/emprendimientos') ?>">Ver emprendimientos</a></div>
        <div class="empty-state"><strong>Sin actividad conectada</strong><p>Cuando se implemente la persistencia, aquí se resumirán los movimientos de los emprendimientos registrados.</p></div>
    </section>
    <section class="card p-3 col-12 col-lg-4">
        <div class="panel-heading"><div><h2>Accesos de administración</h2><p>Gestión global prevista</p></div></div>
        <div class="row row-cols-1 row-cols-md-2 g-2">
            <a class="card p-3 text-body text-decoration-none" href="<?= site_url('admin/emprendimientos') ?>"><strong>Emprendimientos</strong><span class="small text-body-secondary">Consultar y organizar los espacios comerciales.</span></a>
            <div class="card p-3"><strong>Usuarios y roles</strong><span class="small text-body-secondary">Autenticación y permisos aún no implementados.</span></div>
        </div>
    </section>
</div>
<?= $this->endSection() ?>
