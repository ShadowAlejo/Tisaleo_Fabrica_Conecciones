<?= $this->extend('layouts/sistema') ?>
<?= $this->section('content') ?>
<div class="row g-3">
    <section class="card p-3 col-12 col-lg-8">
        <div class="panel-heading"><div><h2>Catálogo</h2><p>Productos físicos y servicios del emprendimiento</p></div></div>
        <div class="d-flex flex-wrap gap-2 mb-3" aria-label="Tipo de catálogo"><button class="btn btn-outline-secondary" type="button" disabled>Productos</button><button class="btn btn-outline-secondary" type="button" disabled>Servicios</button></div>
        <div class="toolbar d-flex flex-wrap align-items-center gap-2 mb-3"><input class="form-control" type="search" aria-label="Buscar en catálogo" placeholder="Buscar producto o servicio" disabled></div>
        <div class="empty-state"><strong>Catálogo sin conectar</strong><p>Los artículos disponibles se cargarán aquí. Los productos controlarán stock; los servicios no.</p><a class="panel-link" href="<?= site_url('emprendedor/productos') ?>">Ir al catálogo de productos</a></div>
    </section>
    <section class="card p-3">
        <div class="panel-heading"><div><h2>Ticket actual</h2><p>0 artículos</p></div></div>
        <div class="empty-state"><strong>Ticket vacío</strong><p>Selecciona artículos del catálogo para preparar una venta.</p></div>
        <div class="d-flex flex-column gap-3 mt-3">
            <div class="d-grid gap-2"><label class="form-label" for="payment-method">Medio de cobro</label><select class="form-select" id="payment-method" disabled><option>Seleccionar medio</option><option>Efectivo</option><option>Transferencia</option><option>Mixto</option></select></div>
            <div class="d-grid gap-2"><label class="form-label" for="sale-total">Total</label><input class="form-control" id="sale-total" value="$ 0.00" readonly></div>
            <button class="btn btn-success" type="button" disabled>Confirmar venta</button>
            <p class="form-hint">La confirmación no está activa: aún no crea ventas ni movimientos de stock.</p>
        </div>
    </section>
</div>
<?= $this->endSection() ?>
