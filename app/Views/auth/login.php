<!doctype html>
<html lang="es">
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Iniciar sesión | Tisaleo Emprende</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet" integrity="sha384-QWTKZyjpPEjISv5WaRU9OFeRpok6YctnYmDr5pNlyT2bRjXh0JMhjY6hW+ALEwIH" crossorigin="anonymous">
    <link rel="stylesheet" href="<?= base_url('assets/css/sistema.css') ?>">
</head>
<body class="login-page">
<main class="login-shell container">
    <section class="login-card">
        <a class="brand login-brand" href="<?= site_url('login') ?>">
            <span class="brand-mark" aria-hidden="true">TE</span>
            <span class="brand-copy"><strong>Tisaleo Emprende</strong><span>Gestión comercial local</span></span>
        </a>
        <div class="login-heading">
            <div class="eyebrow">Acceso al sistema</div>
            <h1>Bienvenido</h1>
            <p>Ingresa con tu correo y contraseña para administrar tus emprendimientos.</p>
        </div>
        <?php if (! empty($error)): ?>
            <div class="alert alert-danger" role="alert"><?= esc($error) ?></div>
        <?php endif ?>
        <form method="post" action="<?= site_url('login') ?>">
            <?= csrf_field() ?>
            <div class="mb-3">
                <label for="correo" class="form-label">Correo electrónico</label>
                <input type="email" class="form-control" id="correo" name="correo" placeholder="nombre@ejemplo.com" data-example="nombre@ejemplo.com" maxlength="190" autocomplete="username" required>
            </div>
            <div class="mb-4">
                <label for="password" class="form-label">Contraseña</label>
                <input type="password" class="form-control" id="password" name="password" placeholder="Ejemplo8!" data-example="Ejemplo8!" maxlength="72" autocomplete="current-password" required>
            </div>
            <button type="submit" class="btn btn-success w-100 py-2">Iniciar sesión</button>
        </form>
    </section>
</main>
<script>
    const exampleFields = document.querySelectorAll('[data-example]');

    exampleFields.forEach((field) => {

        // Al entrar al campo, desaparece el ejemplo
        field.addEventListener('focus', () => {
            field.placeholder = '';
        });

        // Al salir del campo, comprueba si está vacío
        field.addEventListener('blur', () => {
            if (field.value === '') {
                field.placeholder = field.dataset.example;
            }
        });

    });

    // Restaurar los ejemplos al regresar a la página
    window.addEventListener('pageshow', () => {
        exampleFields.forEach((field) => {
            field.value = '';
            field.placeholder = field.dataset.example;
        });
    });
</script>
</body>
</html>
