<?= $this->extend('layouts/sistema') ?>
<?= $this->section('content') ?>
<section class="row row-cols-2 row-cols-lg-4 g-3 mb-4" aria-label="Indicadores del emprendimiento">
    <article class="stat"><span class="stat-label">Ventas de hoy</span><strong class="stat-value">$ <?= number_format($ventasHoy, 2, ',', '.') ?></strong><span class="stat-foot">Ventas completadas de hoy</span></article>
    <article class="stat"><span class="stat-label">Productos activos</span><strong class="stat-value"><?= (int) $productosActivos ?></strong><span class="stat-foot">En el catálogo</span></article>
    <article class="stat"><span class="stat-label">Stock bajo</span><strong class="stat-value"><?= (int) $stockBajo ?></strong><span class="stat-foot">En o por debajo del mínimo</span></article>
    <article class="stat"><span class="stat-label">Servicios activos</span><strong class="stat-value"><?= (int) $serviciosActivos ?></strong><span class="stat-foot">Disponibles para venta</span></article>
</section>
<div class="row g-3">
    <section class="card p-3 col-12 col-lg-8">
        <div class="panel-heading"><div><h2>Ventas recientes</h2><p>Últimos registros de este negocio</p></div><a class="panel-link" href="<?= site_url('emprendedor/ventas') ?>">Ver historial</a></div>
        <?php if ($ventasRecientes === []): ?>
            <div class="empty-state"><strong>Aún no hay ventas para mostrar</strong><p>Las ventas confirmadas aparecerán aquí.</p><a class="btn btn-success" href="<?= site_url('emprendedor/ventas/create') ?>">Abrir venta rápida</a></div>
        <?php else: ?>
            <div class="table-responsive"><table class="table"><thead><tr><th>Referencia</th><th>Fecha</th><th>Total</th></tr></thead><tbody><?php foreach ($ventasRecientes as $venta): ?><tr><td>#<?= (int) $venta['id'] ?></td><td><?= esc($venta['fecha_venta']) ?></td><td>$<?= number_format((float) $venta['total'], 2, ',', '.') ?></td></tr><?php endforeach ?></tbody></table></div>
        <?php endif ?>
    </section>
    <section class="card p-3 col-12 col-lg-4">
        <div class="panel-heading"><div><h2>Atajos</h2><p>Acciones del negocio</p></div></div>
        <div class="row row-cols-1 row-cols-md-2 g-2">
            <?php if ($usaProductos): ?><a class="card p-3 text-body text-decoration-none" href="<?= site_url('emprendedor/productos/create') ?>"><strong>Registrar producto</strong><span class="small text-body-secondary">Catálogo físico e inventario.</span></a><?php endif ?>
            <?php if ($usaServicios): ?><a class="card p-3 text-body text-decoration-none" href="<?= site_url('emprendedor/servicios/create') ?>"><strong>Registrar servicio</strong><span class="small text-body-secondary">Oferta comercial sin control de stock.</span></a><?php endif ?>
            <a class="card p-3 text-body text-decoration-none" href="<?= site_url('emprendedor/empleados') ?>"><strong>Equipo de trabajo</strong><span class="small text-body-secondary">Gestiona las cuentas de este negocio.</span></a>
            <a class="card p-3 text-body text-decoration-none" href="<?= site_url('emprendedor/configuracion') ?>"><strong>Perfil comercial</strong><span class="small text-body-secondary">Información del emprendimiento.</span></a>
        </div>
    </section>
</div>
<?= $this->endSection() ?>
