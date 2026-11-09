<?= $this->extend('layouts/sistema') ?>
<?= $this->section('content') ?>
<?= view('emprendedor/productos/_form', ['isEdit' => true, 'producto' => $producto, 'errors' => $errors ?? []]) ?>
<?= $this->endSection() ?>
