<!doctype html>
<html lang="es">
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Cambiar contraseña | Tisaleo Emprende</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="<?= base_url('assets/css/sistema.css') ?>">
</head>
<body class="bg-light">
<main class="container py-5">
    <section class="card p-4 mx-auto form-shell" style="max-width: 520px">
        <h1 class="h3">Cambia tu contraseña</h1>
        <p>Por seguridad, establece una contraseña personal antes de continuar.</p>
        <?php if ($error = session()->getFlashdata('auth_error')): ?>
            <div class="alert alert-danger" role="alert"><?= esc($error) ?></div>
        <?php endif ?>
        <form method="post" action="<?= site_url('cuenta/cambiar-clave') ?>">
            <?= csrf_field() ?>
            <label class="form-label" for="password">Nueva contraseña</label>
            <input class="form-control mb-2" id="password" name="password" type="password" minlength="8" maxlength="10" required autocomplete="new-password">
            <?php if (isset($errors['password'])): ?><div class="text-danger small mb-2"><?= esc($errors['password']) ?></div><?php endif ?>
            <label class="form-label" for="password_confirm">Confirma la contraseña</label>
            <input class="form-control mb-2" id="password_confirm" name="password_confirm" type="password" minlength="8" maxlength="10" required autocomplete="new-password">
            <?php if (isset($errors['password_confirm'])): ?><div class="text-danger small mb-2"><?= esc($errors['password_confirm']) ?></div><?php endif ?>
            <button class="btn btn-success mt-3" type="submit">Guardar contraseña</button>
        </form>
    </section>
</main>
</body>
</html>
