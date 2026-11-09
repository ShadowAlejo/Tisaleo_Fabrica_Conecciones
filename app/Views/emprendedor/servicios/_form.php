<?php $service = $servicio ?? []; ?>
<?php if (($errors ?? []) !== []): ?>
    <div class="alert alert-danger" role="alert"><ul class="mb-0"><?php foreach ($errors as $error): ?><li><?= esc($error) ?></li><?php endforeach ?></ul></div>
<?php endif ?>
<section class="card p-3 p-md-4 form-shell">
    <form method="post" action="<?= site_url($isEdit ? 'emprendedor/servicios/' . $service['id'] : 'emprendedor/servicios') ?>">
        <?= csrf_field() ?>
        <div class="row g-3">
            <div class="col-12 col-md-6"><label class="form-label" for="service-name">Nombre del servicio</label><input class="form-control" id="service-name" name="nombre" maxlength="150" value="<?= esc(old('nombre', $service['nombre'] ?? '')) ?>" required></div>
            <div class="col-12 col-md-6"><label class="form-label" for="service-category">Sector / categoría</label><select class="form-select" id="service-category" name="categoria"><option value="">Seleccionar categoría</option><?php foreach (['Agropecuario', 'Gastronómico', 'Artesanal', 'Textil', 'Turístico', 'Otro'] as $category): ?><option value="<?= esc($category) ?>" <?= old('categoria', $service['categoria'] ?? '') === $category ? 'selected' : '' ?>><?= esc($category) ?></option><?php endforeach ?></select></div>
            <div class="col-12 col-md-6"><label class="form-label" for="service-price">Precio (USD)</label><input class="form-control" id="service-price" name="precio" type="text" inputmode="decimal" placeholder="0,00" value="<?= esc(old('precio', number_format((float) ($service['precio'] ?? 0), 2, ',', ''))) ?>" required><div class="form-text">Usa coma y dos decimales; por ejemplo, 12,50.</div></div>
            <div class="col-12 col-md-6"><label class="form-label" for="service-state">Estado</label><select class="form-select" id="service-state" name="estado" required><option value="activo" <?= old('estado', $service['estado'] ?? 'activo') === 'activo' ? 'selected' : '' ?>>Activo</option><option value="inactivo" <?= old('estado', $service['estado'] ?? '') === 'inactivo' ? 'selected' : '' ?>>Inactivo</option></select></div>
            <div class="col-12"><label class="form-label" for="service-description">Descripción</label><textarea class="form-control" id="service-description" name="descripcion" maxlength="5000"><?= esc(old('descripcion', $service['descripcion'] ?? '')) ?></textarea></div>
        </div>
        <div class="d-flex flex-wrap gap-2 mt-4 pt-3 border-top"><button class="btn btn-success" type="submit"><?= $isEdit ? 'Guardar cambios' : 'Guardar servicio' ?></button><a class="btn btn-outline-secondary" href="<?= site_url('emprendedor/servicios') ?>">Cancelar</a></div>
    </form>
</section>
