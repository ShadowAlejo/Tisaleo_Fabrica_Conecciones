<?= $this->extend('layouts/sistema') ?>
<?= $this->section('content') ?>
<?php if (($errors ?? []) !== []): ?><div class="alert alert-danger" role="alert"><ul class="mb-0"><?php foreach ($errors as $error): ?><li><?= esc($error) ?></li><?php endforeach ?></ul></div><?php endif ?>
<section class="card p-3 p-md-4 form-shell">
    <form method="post" action="<?= site_url('admin/emprendimientos/' . (int) $negocio['id']) ?>">
        <?= csrf_field() ?>
        <div class="row g-3">
            <div class="col-12 col-md-6"><label class="form-label" for="business-name">Nombre comercial</label><input class="form-control" id="business-name" name="nombre" maxlength="150" value="<?= esc(old('nombre', $negocio['nombre'])) ?>" required></div>
            <div class="col-12 col-md-6"><label class="form-label" for="business-category">Categoría</label><select class="form-select" id="business-category" name="categoria" required><option value="">Seleccionar categoría</option><?php foreach (['Agropecuario', 'Gastronómico', 'Artesanal', 'Textil', 'Turístico', 'Otro'] as $value): ?><option value="<?= esc($value) ?>" <?= old('categoria', $categoria) === $value ? 'selected' : '' ?>><?= esc($value) ?></option><?php endforeach ?><?php if (! in_array($categoria, ['Agropecuario', 'Gastronómico', 'Artesanal', 'Textil', 'Turístico', 'Otro'], true)): ?><option value="<?= esc($categoria) ?>" selected><?= esc($categoria) ?></option><?php endif ?></select></div>
            <div class="col-12 col-md-6"><label class="form-label" for="owner-name">Propietario</label><input class="form-control" id="owner-name" name="propietario" maxlength="100" value="<?= esc(old('propietario', trim(($propietario['nombre'] ?? '') . ' ' . ($propietario['apellido'] ?? '')))) ?>" required></div>
            <div class="col-12 col-md-6"><label class="form-label" for="owner-email">Correo de acceso</label><input class="form-control" id="owner-email" name="correo" type="email" maxlength="190" value="<?= esc(old('correo', $propietario['correo'] ?? $negocio['correo'])) ?>" required></div>
            <div class="col-12 col-md-6"><label class="form-label" for="business-phone">Teléfono</label><input class="form-control" id="business-phone" name="telefono" type="tel" maxlength="30" value="<?= esc(old('telefono', $negocio['telefono'] ?? '')) ?>"></div>
            <div class="col-12 col-md-6"><label class="form-label" for="business-id">RUC / RIMPE</label><input class="form-control" id="business-id" name="identificacion" maxlength="40" value="<?= esc(old('identificacion', $negocio['identificacion'] ?? '')) ?>"></div>
            <div class="col-12"><label class="form-label" for="business-address">Dirección</label><input class="form-control" id="business-address" name="direccion" maxlength="255" value="<?= esc(old('direccion', $negocio['direccion'] ?? '')) ?>"></div>
            <div class="col-12 col-md-6"><label class="form-label" for="business-state">Estado</label><select class="form-select" id="business-state" name="estado"><option value="1" <?= (string) old('estado', $negocio['activo']) === '1' ? 'selected' : '' ?>>Activo</option><option value="0" <?= (string) old('estado', $negocio['activo']) === '0' ? 'selected' : '' ?>>Inactivo</option></select></div>
            <div class="col-12"><p class="form-hint">Base operativa asignada: <?= esc($negocio['database_key']) ?>. No se puede cambiar desde esta pantalla.</p></div>
        </div>
        <div class="d-flex flex-wrap gap-2 mt-4 pt-3 border-top"><button class="btn btn-success" type="submit">Guardar cambios</button><a class="btn btn-outline-secondary" href="<?= site_url('admin/emprendimientos') ?>">Cancelar</a></div>
    </form>
</section>
<?= $this->endSection() ?>
