<?= $this->extend('layouts/sistema') ?>
<?= $this->section('content') ?>
<div class="row g-3">
    <section class="card p-3 col-12 col-lg-8">
        <div class="panel-heading"><div><h2>Catálogo disponible</h2><p>Productos y servicios del emprendimiento asignado</p></div></div>
        <div class="d-flex flex-wrap gap-2 mb-3"><button class="btn btn-outline-secondary" type="button" disabled>Productos</button><button class="btn btn-outline-secondary" type="button" disabled>Servicios</button></div>
        <div class="toolbar d-flex flex-wrap align-items-center gap-2 mb-3"><input class="form-control" type="search" aria-label="Buscar en catálogo" placeholder="Buscar artículo" disabled></div>
        <div class="empty-state"><strong>Catálogo sin conectar</strong><p>Los artículos se cargarán cuando exista una cuenta vinculada a un emprendimiento.</p></div>
    </section>
    <section class="card p-3 col-12 col-lg-4">
        <div class="panel-heading"><div><h2>Ticket</h2><p>0 artículos</p></div></div>
        <div class="empty-state"><strong>Ticket vacío</strong><p>Agrega artículos para preparar el cobro.</p></div>
        <div class="d-flex flex-column gap-3 mt-3">
            <div class="d-grid gap-2"><label class="form-label" for="payment-method">Medio de cobro</label><select class="form-select" id="payment-method" disabled><option>Seleccionar medio</option><option>Efectivo</option><option>Transferencia</option><option>Mixto</option></select></div>
            <div class="d-grid gap-2"><label class="form-label" for="sale-total">Total</label><input class="form-control" id="sale-total" value="$ 0.00" readonly></div>
            <button class="btn btn-success" type="button" disabled>Confirmar venta</button>
            <p class="form-hint">El cálculo, el cobro y la actualización de stock todavía no están conectados.</p>
        </div>
    </section>
</div>
<?= $this->endSection() ?>
