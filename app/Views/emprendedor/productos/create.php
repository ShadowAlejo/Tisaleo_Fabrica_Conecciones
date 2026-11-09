<?= $this->extend('layouts/sistema') ?>
<?= $this->section('content') ?>
<?= view('emprendedor/productos/_form', ['isEdit' => false, 'errors' => $errors ?? []]) ?>
<?= $this->endSection() ?>
