<?php

namespace App\Commands;

use App\Libraries\TenantDatabase;
use CodeIgniter\CLI\BaseCommand;
use CodeIgniter\CLI\CLI;
use RuntimeException;

class LinkProductImage extends BaseCommand
{
    protected $group = 'Database';
    protected $name = 'tenant:image-product';
    protected $description = 'Associates an existing public WebP image with a product in a tenant database.';
    protected $usage = 'tenant:image-product <tenant-key> <product-name> <public-image-path>';
    protected $arguments = [
        'tenant-key' => 'Authorized tenant key, for example razu.',
        'product-name' => 'Exact product name.',
        'public-image-path' => 'Public path such as uploads/productos/vino.webp.',
    ];

    public function run(array $params)
    {
        [$tenantKey, $productName, $imagePath] = array_pad($params, 3, null);
        $tenantDatabase = new TenantDatabase();
        if (
            ! is_string($tenantKey)
            || ! in_array($tenantKey, $tenantDatabase->allowedKeys(), true)
            || ! is_string($productName)
            || trim($productName) === ''
            || ! is_string($imagePath)
            || ! preg_match('#\Auploads/(?:productos|servicios)/[A-Za-z0-9._-]+\.webp\z#i', $imagePath)
        ) {
            throw new RuntimeException('Uso: php spark tenant:image-product <tenant-key> "<nombre exacto>" uploads/productos/imagen.webp');
        }

        $absolutePath = FCPATH . str_replace('/', DIRECTORY_SEPARATOR, $imagePath);
        if (! is_file($absolutePath) || (new \finfo(FILEINFO_MIME_TYPE))->file($absolutePath) !== 'image/webp') {
            throw new RuntimeException('La imagen debe existir en public y ser un archivo WebP válido.');
        }

        $database = $tenantDatabase->connectionForKey($tenantKey);
        $database->initialize();
        if (! $database->tableExists('productos') || ! $database->tableExists('imagenes')) {
            throw new RuntimeException('La base seleccionada no contiene las tablas de productos e imágenes.');
        }

        $product = $database->table('productos')
            ->where('nombre', trim($productName))
            ->where('fec_eliminacion', null)
            ->get()->getRowArray();
        if ($product === null) {
            throw new RuntimeException('No se encontró el producto activo indicado en la base seleccionada.');
        }

        $database->transBegin();
        try {
            $existing = $database->table('imagenes')
                ->where('producto_id', (int) $product['id'])
                ->where('servicio_id', null)
                ->where('fec_eliminacion', null)
                ->orderBy('orden')
                ->orderBy('id')
                ->get()->getRowArray();
            $imageData = [
                'url' => $imagePath,
                'texto_alternativo' => 'Imagen de ' . trim($productName),
                'orden' => 0,
            ];

            if ($existing === null) {
                $database->table('imagenes')->insert(array_merge($imageData, ['producto_id' => (int) $product['id']]));
            } else {
                $database->table('imagenes')->where('id', (int) $existing['id'])->update($imageData);
            }

            if (! $database->transStatus()) {
                throw new RuntimeException('No se pudo asociar la imagen con el producto.');
            }
            $database->transCommit();
        } catch (\Throwable $exception) {
            $database->transRollback();
            throw $exception;
        }

        CLI::write('Imagen asociada a "' . $product['nombre'] . '" en ' . $tenantKey . ': ' . $imagePath, 'green');
    }
}
