<?= $this->extend('layouts/sistema') ?>
<?= $this->section('actions') ?>
<a class="btn btn-success" href="<?= site_url($routePrefix . '/ventas/create') ?>">Nueva venta</a>
<?= $this->endSection() ?>
<?= $this->section('content') ?>
<form class="toolbar d-flex flex-wrap align-items-center gap-2 mb-3" method="get">
    <input class="form-control" type="search" name="buscar" aria-label="Buscar ventas" placeholder="Número de venta" value="<?= esc($search) ?>">
    <label class="visually-hidden" for="sales-from">Desde</label><input class="form-control" id="sales-from" name="desde" type="date" value="<?= esc($from) ?>">
    <label class="visually-hidden" for="sales-to">Hasta</label><input class="form-control" id="sales-to" name="hasta" type="date" value="<?= esc($to) ?>">
    <button class="btn btn-outline-secondary" type="submit">Filtrar</button>
</form>
<div class="table-responsive rounded border bg-white"><table class="table table-hover align-middle mb-0">
    <thead class="table-light"><tr><th>Fecha</th><th>Referencia</th><th>Artículos</th><th>Medio de cobro</th><th>Total (USD)</th></tr></thead>
    <tbody>
    <?php if ($ventas === []): ?>
        <tr><td colspan="5"><div class="empty-state"><strong>Sin ventas registradas</strong><p>Las ventas confirmadas aparecerán aquí.</p><a class="btn btn-success" href="<?= site_url($routePrefix . '/ventas/create') ?>">Abrir venta rápida</a></div></td></tr>
    <?php else: foreach ($ventas as $venta): ?>
        <tr><td><?= esc($venta['fecha_venta']) ?></td><td>#<?= (int) $venta['id'] ?></td><td><?= (int) $venta['articulos'] ?></td><td><?= esc(ucfirst($venta['metodo_pago'] ?? '—')) ?></td><td>$<?= number_format((float) $venta['total'], 2, ',', '.') ?></td></tr>
    <?php endforeach; endif ?>
    </tbody>
</table></div>
<?= $this->endSection() ?>
