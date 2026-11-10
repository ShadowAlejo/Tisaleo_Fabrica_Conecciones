<?php

namespace App\Commands;

use Config\Database;
use CodeIgniter\CLI\BaseCommand;
use CodeIgniter\CLI\CLI;
use RuntimeException;

class ImportEmprendimientoUsers extends BaseCommand
{
    protected $db;
    protected $group = 'Database';
    protected $name = 'users:import-emprendimientos';
    protected $description = 'Imports business owner accounts and their login emails from a UTF-8 CSV file.';
    protected $usage = 'users:import-emprendimientos <csv-path>';
    protected $arguments = [
        'csv-path' => 'CSV con Nombre del Emprendimiento, Usuario, Contraseña, y opcionalmente Usuario_bd, Contrasenia_bd, Correos.',
    ];

    public function run(array $params)
    {
        $this->db = Database::connect();

        $path = $params[0] ?? null;
        if (! is_string($path) || ! is_file($path) || ! is_readable($path)) {
            throw new RuntimeException('Indica la ruta de un CSV legible con las cuentas de los emprendimientos.');
        }

        $accounts = $this->readAccounts($path);
        foreach (['usuario', 'correo', 'nombre'] as $field) {
            if (! $this->db->fieldExists($field, 'usuarios')) {
                throw new RuntimeException('Falta una columna del esquema de usuarios. Ejecuta primero php spark migrate.');
            }
        }

        $owners = [];
        $seenUsernames = [];
        $seenEmails = [];
        $seenBusinesses = [];
        foreach ($accounts as $account) {
            $username = trim($account['username']);
            if (! preg_match('/\A[a-zA-Z0-9._-]{1,80}\z/', $username)) {
                throw new RuntimeException('El CSV contiene un usuario vacío o con formato no válido.');
            }
            $usernameKey = mb_strtolower($username);
            if (isset($seenUsernames[$usernameKey])) {
                throw new RuntimeException('El CSV contiene nombres de usuario duplicados.');
            }
            $seenUsernames[$usernameKey] = true;

            $rawEmail = trim($account['email']);
            if ($rawEmail !== '') {
                $email = mb_strtolower($rawEmail);
                if (! filter_var($email, FILTER_VALIDATE_EMAIL) || strlen($email) > 254) {
                    throw new RuntimeException('El CSV contiene un correo vacío o no válido.');
                }
                if (isset($seenEmails[$email])) {
                    throw new RuntimeException('El CSV contiene correos duplicados.');
                }
                $seenEmails[$email] = true;
            } else {
                $email = mb_strtolower($username) . '@tisaleoemprende.ec';
            }

            if (strlen($account['password']) < 8 || strlen($account['password']) > 72) {
                throw new RuntimeException('Todas las contraseñas deben tener entre 8 y 72 bytes.');
            }

            $businesses = $this->db->table('emprendimientos')
                ->select('id, nombre')
                ->where('nombre', trim($account['business']))
                ->where('activo', 1)
                ->where('fec_eliminacion', null)
                ->get()
                ->getResultArray();
            if (count($businesses) !== 1) {
                throw new RuntimeException('No se encontró un único emprendimiento activo para una fila del CSV.');
            }
            $businessId = (int) $businesses[0]['id'];
            if (isset($seenBusinesses[$businessId])) {
                throw new RuntimeException('El CSV contiene más de una cuenta para el mismo emprendimiento.');
            }
            $seenBusinesses[$businessId] = true;

            $owners[] = [
                'business_id' => $businessId,
                'username' => $username,
                'email' => $email,
                'password' => $account['password'],
                'db_user' => $account['db_user'] ?? '',
                'db_password' => $account['db_password'] ?? '',
            ];
        }

        if ($owners === []) {
            throw new RuntimeException('El CSV no contiene cuentas para importar.');
        }

        $this->db->transBegin();
        try {
            $roleId = $this->findOrCreateOwnerRole();
            $created = 0;
            $skipped = 0;

            foreach ($owners as $owner) {
                $emailOwner = $this->db->table('usuarios')
                    ->where('correo', $owner['email'])
                    ->get()
                    ->getRowArray();

                if ($emailOwner !== null && strcasecmp((string) $emailOwner['usuario'], $owner['username']) !== 0) {
                    throw new RuntimeException('Un correo del CSV ya está asignado a otra cuenta.');
                }

                $existing = $this->db->table('usuarios')
                    ->where('usuario', $owner['username'])
                    ->get()
                    ->getRowArray();

                if ($existing !== null) {
                    if (
                        (int) $existing['rol_id'] !== $roleId
                        || (int) $existing['emprendimiento_id'] !== $owner['business_id']
                        || (int) $existing['activo'] !== 1
                        || $existing['fec_eliminacion'] !== null
                    ) {
                        throw new RuntimeException('Un usuario ya existe, pero no corresponde a la cuenta activa de su emprendimiento.');
                    }

                    $this->db->table('usuarios')
                        ->where('id', $existing['id'])
                        ->update([
                            'nombre'   => null,
                            'apellido' => null,
                            'usuario'  => $owner['username'],
                            'correo'   => $owner['email'],
                        ]);

                    if ($this->db->fieldExists('usuario_bd', 'emprendimientos') && ($owner['db_user'] !== '' || $owner['db_password'] !== '')) {
                        $updateBusiness = [];
                        if ($owner['db_user'] !== '') {
                            $updateBusiness['usuario_bd'] = $owner['db_user'];
                        }
                        if ($owner['db_password'] !== '') {
                            $updateBusiness['contrasenia_bd'] = $owner['db_password'];
                        }
                        $this->db->table('emprendimientos')
                            ->where('id', $owner['business_id'])
                            ->update($updateBusiness);
                    }

                    $skipped++;
                    continue;
                }

                $insertUser = [
                    'rol_id'             => $roleId,
                    'emprendimiento_id'  => $owner['business_id'],
                    'nombre'             => null,
                    'apellido'           => null,
                    'usuario'            => $owner['username'],
                    'correo'             => $owner['email'],
                    'password_hash'      => password_hash($owner['password'], PASSWORD_DEFAULT),
                    'debe_cambiar_clave' => 1,
                    'activo'             => 1,
                ];

                $this->db->table('usuarios')->insert($insertUser);
                $userId = (int) $this->db->insertID();

                if ($this->db->fieldExists('usuario_bd', 'emprendimientos') && ($owner['db_user'] !== '' || $owner['db_password'] !== '')) {
                    $updateBusiness = [];
                    if ($owner['db_user'] !== '') {
                        $updateBusiness['usuario_bd'] = $owner['db_user'];
                    }
                    if ($owner['db_password'] !== '') {
                        $updateBusiness['contrasenia_bd'] = $owner['db_password'];
                    }
                    $this->db->table('emprendimientos')
                        ->where('id', $owner['business_id'])
                        ->update($updateBusiness);
                }

                $this->db->table('usuario_emprendimientos')->insert([
                    'usuario_id' => $userId,
                    'emprendimiento_id' => $owner['business_id'],
                ]);
                $created++;
            }

            if (! $this->db->transStatus()) {
                throw new RuntimeException('No se pudieron guardar todas las cuentas del CSV.');
            }

            $this->db->transCommit();
            CLI::write('Importación completa: ' . $created . ' cuentas creadas; ' . $skipped . ' cuentas existentes actualizadas sin cambiar su contraseña.', 'green');
        } catch (\Throwable $exception) {
            $this->db->transRollback();
            throw $exception;
        }
    }

    /**
     * @return list<array{business: string, username: string, password: string, email: string}>
     */
    private function readAccounts(string $path): array
    {
        $handle = fopen($path, 'rb');
        if ($handle === false) {
            throw new RuntimeException('No se pudo abrir el CSV indicado.');
        }

        try {
            $firstLine = null;
            while (($line = fgets($handle)) !== false) {
                if (trim($line) !== '') {
                    $firstLine = $line;
                    break;
                }
            }
            if ($firstLine === null) {
                throw new RuntimeException('El CSV está vacío.');
            }

            $delimiter = substr_count($firstLine, ';') > substr_count($firstLine, ',') ? ';' : ',';
            rewind($handle);
            $headers = null;
            while (($row = fgetcsv($handle, null, $delimiter, '"', '\\')) !== false) {
                if (count(array_filter($row, static fn ($value): bool => trim((string) $value) !== '')) > 0) {
                    $headers = $row;
                    break;
                }
            }
            if ($headers === null) {
                throw new RuntimeException('No se pudieron leer los encabezados del CSV.');
            }

            $columns = [];
            $unnamedColumns = [];
            foreach ($headers as $index => $header) {
                $header = $this->normalizeCsvValue((string) $header);
                $header = preg_replace('/^\xEF\xBB\xBF/', '', $header);
                $normalized = mb_strtolower(trim($header));
                $normalized = iconv('UTF-8', 'ASCII//TRANSLIT//IGNORE', $normalized) ?: $normalized;
                $normalized = preg_replace('/[^a-z0-9]+/', '', $normalized);
                if ($normalized === 'nombredelemprendimiento') {
                    $columns['business'] = $index;
                } elseif ($normalized === 'usuario') {
                    $columns['username'] = $index;
                } elseif (in_array($normalized, ['contrasena', 'contrasea', 'password'], true)) {
                    $columns['password'] = $index;
                } elseif (in_array($normalized, ['correo', 'correos', 'email', 'emailaddress', 'correoelectronico'], true)) {
                    $columns['email'] = $index;
                } elseif (in_array($normalized, ['usuariobd', 'usuario_bd', 'userbd', 'dbuser'], true)) {
                    $columns['db_user'] = $index;
                } elseif (in_array($normalized, ['contraseniabd', 'contrasenabd', 'contrasenia_bd', 'contrasena_bd', 'passwordbd', 'dbpassword'], true)) {
                    $columns['db_password'] = $index;
                } elseif ($normalized === '') {
                    $unnamedColumns[] = $index;
                } else {
                    throw new RuntimeException('El CSV contiene una columna no reconocida: ' . $header . '. Deja solo emprendimiento, usuario, contraseña, correos y credenciales de BD.');
                }
            }

            if (! isset($columns['business'], $columns['username'], $columns['password'])) {
                throw new RuntimeException('El CSV debe incluir al menos las columnas Nombre del Emprendimiento, Usuario y Contraseña.');
            }

            $accounts = [];
            while (($row = fgetcsv($handle, null, $delimiter, '"', '\\')) !== false) {
                if ($row === [null] || count(array_filter($row, static fn ($value): bool => trim((string) $value) !== '')) === 0) {
                    continue;
                }
                $row = array_map(fn ($value): string => $this->normalizeCsvValue((string) $value), $row);

                foreach ($unnamedColumns as $column) {
                    $value = trim((string) ($row[$column] ?? ''));
                    if ($value === '') {
                        continue;
                    }
                    if ($column !== 0 || ! ctype_digit($value) || (int) $value !== count($accounts) + 1) {
                        throw new RuntimeException('El CSV contiene datos en una columna sin encabezado.');
                    }
                }

                $business = trim((string) ($row[$columns['business']] ?? ''));
                $username = trim((string) ($row[$columns['username']] ?? ''));
                $password = (string) ($row[$columns['password']] ?? '');
                $email = isset($columns['email']) ? trim((string) ($row[$columns['email']] ?? '')) : '';
                $dbUser = isset($columns['db_user']) ? trim((string) ($row[$columns['db_user']] ?? '')) : '';
                $dbPassword = isset($columns['db_password']) ? (string) ($row[$columns['db_password']] ?? '') : '';

                if ($business === '' || $username === '' || $password === '') {
                    throw new RuntimeException('El CSV contiene una fila incompleta.');
                }

                $accounts[] = [
                    'business' => $business,
                    'username' => $username,
                    'password' => $password,
                    'email' => $email,
                    'db_user' => $dbUser,
                    'db_password' => $dbPassword,
                ];
            }

            return $accounts;
        } finally {
            fclose($handle);
        }
    }

    private function normalizeCsvValue(string $value): string
    {
        if (! mb_check_encoding($value, 'UTF-8')) {
            return mb_convert_encoding($value, 'UTF-8', 'Windows-1252');
        }

        return $value;
    }

    private function findOrCreateOwnerRole(): int
    {
        $role = $this->db->table('roles')->where('nombre', 'propietario')->get()->getRowArray();
        if ($role !== null) {
            return (int) $role['id'];
        }

        $this->db->table('roles')->insert([
            'nombre' => 'propietario',
            'descripcion' => 'Propietario de un emprendimiento',
        ]);

        return (int) $this->db->insertID();
    }
}
