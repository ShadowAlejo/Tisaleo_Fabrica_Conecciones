<?php
$product = $producto ?? [];
?>
<?php if (($errors ?? []) !== []): ?>
    <div class="alert alert-danger" role="alert">
        <ul class="mb-0"><?php foreach ($errors as $error): ?><li><?= esc($error) ?></li><?php endforeach ?></ul>
    </div>
<?php endif ?>
<section class="card p-3 p-md-4 form-shell">
    <form method="post" action="<?= site_url($isEdit ? 'emprendedor/productos/' . $product['id'] : 'emprendedor/productos') ?>">
        <?= csrf_field() ?>
        <div class="row g-3">
            <div class="col-12 col-md-6"><label class="form-label" for="product-name">Nombre del producto</label><input class="form-control" id="product-name" name="nombre" maxlength="150" value="<?= esc(old('nombre', $product['nombre'] ?? '')) ?>" required></div>
            <div class="col-12 col-md-6"><label class="form-label" for="product-code">Código (opcional)</label><input class="form-control" id="product-code" name="codigo" maxlength="60" value="<?= esc(old('codigo', $product['codigo'] ?? '')) ?>"></div>
            <div class="col-12 col-md-6"><label class="form-label" for="product-category">Sector / categoría</label><select class="form-select" id="product-category" name="categoria" required>
                <option value="">Seleccionar categoría</option>
                <?php foreach (['Agropecuario', 'Gastronómico', 'Artesanal', 'Textil', 'Turístico', 'Otro'] as $category): ?>
                    <option value="<?= esc($category) ?>" <?= old('categoria', $product['categoria_unidad'] ?? '') === $category ? 'selected' : '' ?>><?= esc($category) ?></option>
                <?php endforeach ?>
            </select></div>
            <div class="col-12 col-md-6"><label class="form-label" for="product-price">Precio de venta (USD)</label><input class="form-control" id="product-price" name="precio" type="text" inputmode="decimal" placeholder="0,00" value="<?= esc(old('precio', number_format((float) ($product['precio_venta'] ?? 0), 2, ',', ''))) ?>" required><div class="form-text">Usa coma y dos decimales; por ejemplo, 12,50.</div></div>
            <div class="col-12 col-md-6"><label class="form-label" for="product-stock">Existencias</label><input class="form-control" id="product-stock" name="stock" type="text" inputmode="decimal" placeholder="0,00" value="<?= esc(old('stock', number_format((float) ($product['cantidad'] ?? 0), 2, ',', ''))) ?>" required><div class="form-text">Usa coma y dos decimales; por ejemplo, 10,00.</div></div>
            <div class="col-12 col-md-6"><label class="form-label" for="product-minimum">Alerta de stock mínimo</label><input class="form-control" id="product-minimum" name="stock_minimo" type="text" inputmode="decimal" placeholder="0,00" value="<?= esc(old('stock_minimo', number_format((float) ($product['stock_minimo'] ?? 0), 2, ',', ''))) ?>" required><div class="form-text">Usa coma y hasta dos decimales; por ejemplo, 5,00.</div></div>
            <div class="col-12"><label class="form-label" for="product-description">Descripción (opcional)</label><textarea class="form-control" id="product-description" name="descripcion" maxlength="5000"><?= esc(old('descripcion', $product['descripcion'] ?? '')) ?></textarea></div>
        </div>
        <div class="d-flex flex-wrap gap-2 mt-4 pt-3 border-top"><button class="btn btn-success" type="submit"><?= $isEdit ? 'Guardar cambios' : 'Guardar producto' ?></button><a class="btn btn-outline-secondary" href="<?= site_url('emprendedor/productos') ?>">Cancelar</a></div>
    </form>
</section>
