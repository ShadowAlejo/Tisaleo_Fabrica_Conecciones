<?php
$navigation = match ($role) {
    'admin' => [
        ['label' => 'Resumen general', 'url' => 'admin', 'key' => 'resumen'],
        ['label' => 'Emprendimientos', 'url' => 'admin/emprendimientos', 'key' => 'emprendimientos'],
    ],
    'empleado' => [
        ['label' => 'Punto de venta', 'url' => 'empleado/ventas/create', 'key' => 'ventas'],
        ['label' => 'Historial de ventas', 'url' => 'empleado/ventas', 'key' => 'historial'],
    ],
    default => [
        ['label' => 'Resumen', 'url' => 'emprendedor', 'key' => 'resumen'],
        ['label' => 'Productos', 'url' => 'emprendedor/productos', 'key' => 'productos'],
        ['label' => 'Servicios', 'url' => 'emprendedor/servicios', 'key' => 'servicios'],
        ['label' => 'Ventas', 'url' => 'emprendedor/ventas', 'key' => 'ventas'],
        ['label' => 'Equipo', 'url' => 'emprendedor/empleados', 'key' => 'empleados'],
        ['label' => 'Configuración', 'url' => 'emprendedor/configuracion', 'key' => 'configuracion'],
    ],
};
$roleLabels = [
    'admin' => 'Administración',
    'emprendedor' => 'Propietario',
    'empleado' => 'Empleado',
];
$roleLabel = $roleLabels[$role] ?? 'Propietario';
?>
<!doctype html>
<html lang="es">
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title><?= esc($pageTitle) ?> | Tisaleo Emprende</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet" integrity="sha384-QWTKZyjpPEjISv5WaRU9OFeRpok6YctnYmDr5pNlyT2bRjXh0JMhjY6hW+ALEwIH" crossorigin="anonymous">
    <link rel="stylesheet" href="<?= base_url('assets/css/sistema.css') ?>">
</head>
<body>
<div class="container-fluid">
    <div class="row min-vh-100">
        <aside class="sidebar col-12 col-lg-3 col-xl-2 d-flex flex-column gap-3 p-3 p-lg-4">
            <a class="brand" href="<?= site_url($role === 'admin' ? 'admin' : ($role === 'empleado' ? 'empleado' : 'emprendedor')) ?>">
                <span class="brand-mark" aria-hidden="true">TE</span>
                <span class="brand-copy"><strong>Tisaleo Emprende</strong><span>Gestión comercial local</span></span>
            </a>
            <div class="workspace-label d-none d-lg-block">
                <span>Espacio actual</span>
                <strong><?= $role === 'admin' ? 'Vista global' : 'Emprendimiento de prueba' ?></strong>
            </div>
            <div>
                <p class="nav-label d-none d-lg-block">Menú principal</p>
                <nav class="main-nav nav flex-row flex-lg-column flex-nowrap overflow-auto" aria-label="Navegación principal">
                    <?php foreach ($navigation as $item): ?>
                        <a class="nav-link" href="<?= site_url($item['url']) ?>" <?= $activeMenu === $item['key'] ? 'aria-current="page"' : '' ?>><?= esc($item['label']) ?></a>
                    <?php endforeach ?>
                </nav>
            </div>
            <div class="sidebar-foot d-none d-lg-block">Prototipo de interfaz<br>Acceso y permisos pendientes</div>
        </aside>
        <div class="workspace col d-flex flex-column min-vh-100">
            <header class="topbar d-flex align-items-center justify-content-between gap-3 px-3 px-md-4">
                <div class="topbar-context">Tisaleo, Tungurahua <span aria-hidden="true">/</span> <?= esc($roleLabel) ?></div>
                <div class="topbar-profile"><span class="profile-initial" aria-hidden="true"><?= esc(mb_substr($roleLabel, 0, 1)) ?></span><span><?= esc($roleLabel) ?></span></div>
            </header>
            <main class="content container-fluid flex-grow-1 px-3 px-md-4 py-4">
                <div class="page-heading d-flex flex-column flex-md-row align-items-md-end justify-content-between gap-3 mb-4">
                    <div>
                        <div class="eyebrow"><?= esc($roleLabel) ?> · Tisaleo Emprende</div>
                        <h1><?= esc($pageTitle) ?></h1>
                        <?php if ($pageDescription !== ''): ?><p class="page-description"><?= esc($pageDescription) ?></p><?php endif ?>
                    </div>
                    <div class="page-actions d-flex flex-wrap gap-2"><?= $this->renderSection('actions') ?></div>
                </div>
                <div class="alert alert-warning mb-4" role="note"><strong>Plantilla visual.</strong> Los datos y formularios aún no están conectados a una base de datos; los perfiles no aplican permisos reales.</div>
                <?= $this->renderSection('content') ?>
            </main>
            <footer class="site-footer border-top bg-white text-secondary small px-3 px-md-4 py-3">Tisaleo Emprende · Prototipo local</footer>
        </div>
    </div>
</div>
</body>
</html>
