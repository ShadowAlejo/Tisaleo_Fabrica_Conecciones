<?php
$navigation = match ($role) {
    'admin' => [
        ['label' => 'Resumen general', 'url' => 'admin', 'key' => 'resumen'],
        ['label' => 'Emprendimientos', 'url' => 'admin/emprendimientos', 'key' => 'emprendimientos'],
    ],
    'empleado' => [
        ['label' => 'Resumen', 'url' => 'emprendedor', 'key' => 'resumen'],
    ],
    default => [
        ['label' => 'Resumen', 'url' => 'emprendedor', 'key' => 'resumen'],
    ],
};
$roleLabels = [
    'admin' => 'Administración',
    'propietario' => 'Propietario',
    'empleado' => 'Empleado',
];
$roleLabel = $roleLabels[$role] ?? 'Propietario';
$authUser = session('auth_user') ?? [];
$businesses = session('auth_businesses') ?? [];
$currentBusinessId = (int) (session('current_business_id') ?? 0);
$currentBusiness = null;
foreach ($businesses as $business) {
    if ((int) $business['id'] === $currentBusinessId) {
        $currentBusiness = $business;
        break;
    }
}
if ($currentBusiness !== null) {
    $catalogItems = [];
    if (! empty($currentBusiness['usa_productos'])) {
        $catalogItems[] = ['label' => 'Productos', 'url' => 'emprendedor/productos', 'key' => 'productos'];
    }
    if (! empty($currentBusiness['usa_servicios'])) {
        $catalogItems[] = ['label' => 'Servicios', 'url' => 'emprendedor/servicios', 'key' => 'servicios'];
    }
    $navigationItems = array_merge($catalogItems, [
        ['label' => 'Ventas', 'url' => $role === 'empleado' ? 'empleado/ventas' : 'emprendedor/ventas', 'key' => 'ventas'],
    ], $role === 'empleado' ? [] : [
        ['label' => 'Equipo', 'url' => 'emprendedor/empleados', 'key' => 'empleados'],
    ], [
        ['label' => 'Configuración', 'url' => 'emprendedor/configuracion', 'key' => 'configuracion'],
    ]);
    $insertionIndex = $role === 'admin' ? 2 : 1;
    array_splice($navigation, $insertionIndex, 0, $navigationItems);
}
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
                <strong><?= esc($currentBusiness['nombre'] ?? ($role === 'admin' ? 'Vista global' : 'Sin emprendimiento')) ?></strong>
            </div>
            <div>
                <p class="nav-label d-none d-lg-block">Menú principal</p>
                <nav class="main-nav nav flex-row flex-lg-column flex-nowrap overflow-auto" aria-label="Navegación principal">
                    <?php foreach ($navigation as $item): ?>
                        <a class="nav-link" href="<?= site_url($item['url']) ?>" <?= $activeMenu === $item['key'] ? 'aria-current="page"' : '' ?>><?= esc($item['label']) ?></a>
                    <?php endforeach ?>
                </nav>
            </div>
            <div class="sidebar-foot d-none d-lg-block">Tisaleo, Tungurahua<br>Gestión de emprendimientos locales</div>
        </aside>
        <div class="workspace col d-flex flex-column min-vh-100">
            <header class="topbar d-flex align-items-center justify-content-between gap-3 px-3 px-md-4">
                <div class="topbar-context">Tisaleo, Tungurahua <span aria-hidden="true">/</span> <?= esc($roleLabel) ?></div>
                <div class="topbar-profile">
                    <?php if (count($businesses) > 1): ?>
                        <form class="business-switcher d-flex align-items-center gap-2" method="post" action="<?= site_url('emprendedor/negocio') ?>">
                            <?= csrf_field() ?>
                            <label class="visually-hidden" for="emprendimiento_id">Emprendimiento activo</label>
                            <select class="form-select form-select-sm" id="emprendimiento_id" name="emprendimiento_id" onchange="this.form.submit()">
                                <?php foreach ($businesses as $business): ?>
                                    <option value="<?= (int) $business['id'] ?>" <?= (int) $business['id'] === $currentBusinessId ? 'selected' : '' ?>><?= esc($business['nombre']) ?></option>
                                <?php endforeach ?>
                            </select>
                        </form>
                    <?php endif ?>
                    <span class="profile-initial" aria-hidden="true"><?= esc(mb_substr($authUser['name'] ?? $roleLabel, 0, 1)) ?></span>
                    <span><?= esc($authUser['name'] ?? $roleLabel) ?></span>
                    <form method="post" action="<?= site_url('logout') ?>">
                        <?= csrf_field() ?>
                        <button class="btn btn-outline-secondary btn-sm" type="submit">Salir</button>
                    </form>
                </div>
            </header>
            <main class="content container-fluid flex-grow-1 px-3 px-md-4 py-4">
                <?php if ($authError = session()->getFlashdata('auth_error')): ?>
                    <div class="alert alert-danger" role="alert"><?= esc($authError) ?></div>
                <?php endif ?>
                <?php if ($success = session()->getFlashdata('success')): ?>
                    <div class="alert alert-success" role="status"><?= esc($success) ?></div>
                <?php endif ?>
                <?php if ($temporaryPassword = session()->getFlashdata('temporary_password')): ?>
                    <div class="alert alert-warning" role="alert">Contraseña temporal (se muestra una sola vez): <strong><?= esc($temporaryPassword) ?></strong></div>
                <?php endif ?>
                <div class="page-heading d-flex flex-column flex-md-row align-items-md-end justify-content-between gap-3 mb-4">
                    <div>
                        <div class="eyebrow"><?= esc($roleLabel) ?> · Tisaleo Emprende</div>
                        <h1><?= esc($pageTitle) ?></h1>
                        <?php if ($pageDescription !== ''): ?><p class="page-description"><?= esc($pageDescription) ?></p><?php endif ?>
                    </div>
                    <div class="page-actions d-flex flex-wrap gap-2"><?= $this->renderSection('actions') ?></div>
                </div>
                <?= $this->renderSection('content') ?>
            </main>
            <footer class="site-footer border-top bg-white text-secondary small px-3 px-md-4 py-3">Tisaleo Emprende · Gestión comercial local</footer>
        </div>
    </div>
</div>
</body>
</html>
