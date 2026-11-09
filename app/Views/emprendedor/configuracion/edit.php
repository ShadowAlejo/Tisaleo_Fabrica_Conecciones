<?= $this->extend('layouts/sistema') ?>
<?= $this->section('content') ?>
<?php if (($errors ?? []) !== []): ?><div class="alert alert-danger" role="alert"><ul class="mb-0"><?php foreach ($errors as $error): ?><li><?= esc($error) ?></li><?php endforeach ?></ul></div><?php endif ?>
<section class="card p-3 p-md-4 form-shell">
    <form method="post" action="<?= site_url('emprendedor/configuracion') ?>">
        <?= csrf_field() ?>
        <div class="row g-3">
            <div class="col-12 col-md-6"><label class="form-label" for="business-name">Nombre del emprendimiento</label><input class="form-control" id="business-name" name="nombre" maxlength="150" value="<?= esc(old('nombre', $negocio['nombre'])) ?>" required></div>
            <div class="col-12 col-md-6"><label class="form-label" for="business-id">RUC / RIMPE</label><input class="form-control" id="business-id" name="identificacion" maxlength="40" value="<?= esc(old('identificacion', $negocio['identificacion'] ?? '')) ?>"></div>
            <div class="col-12 col-md-6"><label class="form-label" for="representative">Representante</label><input class="form-control" id="representative" name="representante" maxlength="150" value="<?= esc(old('representante', $negocio['representante'] ?? '')) ?>"></div>
            <div class="col-12 col-md-6"><label class="form-label" for="phone">Teléfono</label><input class="form-control" id="phone" name="telefono" type="tel" maxlength="30" value="<?= esc(old('telefono', $negocio['telefono'] ?? '')) ?>"></div>
            <div class="col-12 col-md-6"><label class="form-label" for="email">Correo</label><input class="form-control" id="email" name="correo" type="email" maxlength="190" value="<?= esc(old('correo', $negocio['correo'] ?? '')) ?>"></div>
            <div class="col-12 col-md-6"><label class="form-label" for="category">Categoría</label><select class="form-select" id="category" name="categoria" required>
                <option value="">Seleccionar categoría</option>
                <?php foreach (['Agropecuario', 'Gastronómico', 'Artesanal', 'Textil', 'Turístico', 'Otro'] as $value): ?><option value="<?= esc($value) ?>" <?= old('categoria', $categoria) === $value ? 'selected' : '' ?>><?= esc($value) ?></option><?php endforeach ?>
                <?php if (! in_array($categoria, ['Agropecuario', 'Gastronómico', 'Artesanal', 'Textil', 'Turístico', 'Otro'], true)): ?><option value="<?= esc($categoria) ?>" selected><?= esc($categoria) ?></option><?php endif ?>
            </select></div>
            <div class="col-12"><label class="form-label" for="address">Dirección</label><input class="form-control" id="address" name="direccion" maxlength="255" value="<?= esc(old('direccion', $negocio['direccion'] ?? '')) ?>"></div>
            <div class="col-12"><label class="form-label" for="description">Descripción</label><textarea class="form-control" id="description" name="descripcion" maxlength="5000"><?= esc(old('descripcion', $negocio['descripcion'] ?? '')) ?></textarea></div>
            <fieldset class="col-12 border-0 p-0 m-0"><legend class="form-label fw-semibold">Tipo de catálogo</legend><div class="row row-cols-1 row-cols-md-2 g-2 mt-1">
                <label class="card p-3"><input type="hidden" name="usa_productos" value="0"><span class="form-check"><input class="form-check-input" type="checkbox" name="usa_productos" value="1" <?= old('usa_productos', $negocio['usa_productos'] ?? 1) ? 'checked' : '' ?>><span class="form-check-label">Productos</span></span><span class="small text-body-secondary">Bienes físicos con control de existencias.</span></label>
                <label class="card p-3"><input type="hidden" name="usa_servicios" value="0"><span class="form-check"><input class="form-check-input" type="checkbox" name="usa_servicios" value="1" <?= old('usa_servicios', $negocio['usa_servicios'] ?? 1) ? 'checked' : '' ?>><span class="form-check-label">Servicios</span></span><span class="small text-body-secondary">Oferta comercial sin control de stock.</span></label>
            </div></fieldset>
        </div>
        <div class="d-flex flex-wrap gap-2 mt-4 pt-3 border-top"><button class="btn btn-success" type="submit">Guardar configuración</button><a class="btn btn-outline-secondary" href="<?= site_url('emprendedor/configuracion') ?>">Cancelar</a></div>
    </form>
</section>
<?= $this->endSection() ?>
