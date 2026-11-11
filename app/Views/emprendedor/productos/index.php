<?= $this->extend('layouts/sistema') ?>
<?= $this->section('actions') ?>
<a class="btn btn-success" href="<?= site_url('emprendedor/productos/create') ?>">Registrar producto</a>
<?= $this->endSection() ?>
<?= $this->section('content') ?>
<form class="toolbar d-flex flex-wrap align-items-center gap-2 mb-3" method="get">
    <input class="form-control" type="search" name="buscar" aria-label="Buscar productos" placeholder="Buscar por nombre o código" value="<?= esc($search) ?>">
    <select class="form-select" name="categoria" aria-label="Filtrar por categoría">
        <option value="">Todas las categorías</option>
        <?php foreach ($categorias as $item): ?><option value="<?= esc($item['categoria_unidad']) ?>" <?= $category === $item['categoria_unidad'] ? 'selected' : '' ?>><?= esc($item['categoria_unidad']) ?></option><?php endforeach ?>
    </select>
    <select class="form-select" name="stock" aria-label="Filtrar por stock">
        <option value="">Todos los niveles de stock</option>
        <option value="bajo" <?= $stockFilter === 'bajo' ? 'selected' : '' ?>>Stock bajo</option>
        <option value="disponible" <?= $stockFilter === 'disponible' ? 'selected' : '' ?>>Stock suficiente</option>
    </select>
    <button class="btn btn-outline-secondary" type="submit">Filtrar</button>
</form>
<div class="table-responsive rounded border bg-white"><table class="table table-hover align-middle mb-0">
    <thead class="table-light"><tr><th>Producto</th><th>Categoría</th><th>Precio</th><th>Existencias</th><th>Stock mínimo</th><th>Estado</th><th>Acciones</th></tr></thead>
    <tbody>
    <?php if ($productos === []): ?>
        <tr><td colspan="7"><div class="empty-state"><strong>Sin productos para mostrar</strong><p>Registra un producto para iniciar tu catálogo.</p><a class="btn btn-success" href="<?= site_url('emprendedor/productos/create') ?>">Crear producto</a></div></td></tr>
    <?php else: foreach ($productos as $producto): ?>
        <tr>
            <td>
                <div class="d-flex align-items-center gap-2">
                    <?php if (! empty($producto['imagen_url'])): ?>
                        <img src="<?= base_url($producto['imagen_url']) ?>" alt="<?= esc('Imagen de ' . $producto['nombre']) ?>" width="56" height="56" loading="lazy" style="object-fit: cover; border-radius: .375rem">
                    <?php else: ?>
                        <div class="bg-light border rounded d-flex align-items-center justify-content-center text-secondary" style="width: 56px; height: 56px" aria-hidden="true">—</div>
                    <?php endif ?>
                    <div><strong><?= esc($producto['nombre']) ?></strong><div class="small text-body-secondary"><?= esc($producto['codigo'] ?? '') ?></div></div>
                </div>
            </td>
            <td><?= esc($producto['categoria_unidad']) ?></td>
            <td>$<?= number_format((float) $producto['precio'], 2, ',', '.') ?></td>
            <td><?= number_format((float) $producto['cantidad'], 2, ',', '.') ?></td>
            <td><?= number_format((float) $producto['stock_minimo'], 2, ',', '.') ?></td>
            <td><?= (float) $producto['cantidad'] <= (float) $producto['stock_minimo'] ? '<span class="badge text-bg-warning">Stock bajo</span>' : '<span class="badge text-bg-success">Disponible</span>' ?></td>
            <td class="text-nowrap">
                <a class="btn btn-sm btn-outline-primary" href="<?= site_url('emprendedor/productos/edit/' . (int) $producto['id']) ?>">Editar</a>
                <form class="d-inline" method="post" action="<?= site_url('emprendedor/productos/' . (int) $producto['id'] . '/eliminar') ?>" onsubmit="return confirm('¿Desactivar este producto?')"><?= csrf_field() ?><button class="btn btn-sm btn-outline-danger" type="submit">Desactivar</button></form>
            </td>
        </tr>
    <?php endforeach; endif ?>
    </tbody>
</table></div>
<?= $this->endSection() ?>
