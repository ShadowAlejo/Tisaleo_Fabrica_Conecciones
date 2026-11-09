<?= $this->extend('layouts/sistema') ?>
<?= $this->section('content') ?>
<?php if (($errors ?? []) !== []): ?><div class="alert alert-danger" role="alert"><ul class="mb-0"><?php foreach ($errors as $error): ?><li><?= esc($error) ?></li><?php endforeach ?></ul></div><?php endif ?>
<section class="card p-3 p-md-4 form-shell">
    <p class="form-hint">Se generará una contraseña temporal de un solo uso, y el empleado deberá cambiarla al iniciar sesión.</p>
    <form method="post" action="<?= site_url('emprendedor/empleados') ?>">
        <?= csrf_field() ?>
        <div class="row g-3">
            <div class="col-12 col-md-6"><label class="form-label" for="employee-name">Nombre completo</label><input class="form-control" id="employee-name" name="nombre" maxlength="100" value="<?= esc(old('nombre')) ?>" required></div>
            <div class="col-12 col-md-6"><label class="form-label" for="employee-email">Correo electrónico</label><input class="form-control" id="employee-email" name="correo" type="email" maxlength="190" value="<?= esc(old('correo')) ?>" required></div>
            <div class="col-12 col-md-6"><label class="form-label" for="employee-phone">Teléfono</label><input class="form-control" id="employee-phone" name="telefono" type="tel" maxlength="30" value="<?= esc(old('telefono')) ?>"></div>
        </div>
        <div class="d-flex flex-wrap gap-2 mt-4 pt-3 border-top"><button class="btn btn-success" type="submit">Crear cuenta</button><a class="btn btn-outline-secondary" href="<?= site_url('emprendedor/empleados') ?>">Cancelar</a></div>
    </form>
</section>
<?= $this->endSection() ?>
