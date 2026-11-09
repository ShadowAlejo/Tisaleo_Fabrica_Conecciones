<?= $this->extend('layouts/sistema') ?>
<?= $this->section('content') ?>
<?= view('emprendedor/servicios/_form', ['isEdit' => true, 'servicio' => $servicio, 'errors' => $errors ?? []]) ?>
<?= $this->endSection() ?>
