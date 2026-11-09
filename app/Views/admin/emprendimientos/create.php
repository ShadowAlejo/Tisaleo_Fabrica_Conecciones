<?= $this->extend('layouts/sistema') ?>
<?= $this->section('content') ?>
<?php if (($errors ?? []) !== []): ?><div class="alert alert-danger" role="alert"><ul class="mb-0"><?php foreach ($errors as $error): ?><li><?= esc($error) ?></li><?php endforeach ?></ul></div><?php endif ?>
<?php if ($availableKeys === []): ?>
    <div class="alert alert-warning">No existe una base operativa preconfigurada y libre. Añade de forma segura una conexión autorizada antes de registrar otro negocio.</div>
<?php else: ?>
<section class="card p-3 p-md-4 form-shell">
    <p class="form-hint">Se creará una cuenta de propietario con contraseña temporal. La base operativa solo puede elegirse entre las conexiones preconfiguradas.</p>
    <form method="post" action="<?= site_url('admin/emprendimientos') ?>">
        <?= csrf_field() ?>
        <div class="row g-3">
            <div class="col-12 col-md-6"><label class="form-label" for="business-name">Nombre comercial</label><input class="form-control" id="business-name" name="nombre" maxlength="150" value="<?= esc(old('nombre')) ?>" required></div>
            <div class="col-12 col-md-6"><label class="form-label" for="business-category">Categoría</label><select class="form-select" id="business-category" name="categoria" required><option value="">Seleccionar categoría</option><?php foreach (['Agropecuario', 'Gastronómico', 'Artesanal', 'Textil', 'Turístico', 'Otro'] as $categoria): ?><option value="<?= esc($categoria) ?>" <?= old('categoria') === $categoria ? 'selected' : '' ?>><?= esc($categoria) ?></option><?php endforeach ?></select></div>
            <div class="col-12 col-md-6"><label class="form-label" for="owner-name">Nombre del propietario</label><input class="form-control" id="owner-name" name="propietario" maxlength="100" value="<?= esc(old('propietario')) ?>" required></div>
            <div class="col-12 col-md-6"><label class="form-label" for="owner-email">Correo de acceso</label><input class="form-control" id="owner-email" name="correo" type="email" maxlength="190" value="<?= esc(old('correo')) ?>" required></div>
            <div class="col-12 col-md-6"><label class="form-label" for="business-phone">Teléfono</label><input class="form-control" id="business-phone" name="telefono" type="tel" maxlength="30" value="<?= esc(old('telefono')) ?>"></div>
            <div class="col-12 col-md-6"><label class="form-label" for="business-id">RUC / RIMPE</label><input class="form-control" id="business-id" name="identificacion" maxlength="40" value="<?= esc(old('identificacion')) ?>"></div>
            <div class="col-12"><label class="form-label" for="business-address">Dirección</label><input class="form-control" id="business-address" name="direccion" maxlength="255" value="<?= esc(old('direccion')) ?>"></div>
            <div class="col-12"><label class="form-label" for="database-key">Base operativa</label><select class="form-select" id="database-key" name="database_key" required><option value="">Seleccionar base disponible</option><?php foreach ($availableKeys as $key): ?><option value="<?= esc($key) ?>" <?= old('database_key') === $key ? 'selected' : '' ?>><?= esc($key) ?></option><?php endforeach ?></select></div>
        </div>
        <div class="d-flex flex-wrap gap-2 mt-4 pt-3 border-top"><button class="btn btn-success" type="submit">Crear emprendimiento</button><a class="btn btn-outline-secondary" href="<?= site_url('admin/emprendimientos') ?>">Volver al directorio</a></div>
    </form>
</section>
<?php endif ?>
<?= $this->endSection() ?>
