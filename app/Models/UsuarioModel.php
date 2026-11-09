<?php

namespace App\Models;

use CodeIgniter\Model;

class UsuarioModel extends Model
{
    protected $table = 'usuarios';
    protected $primaryKey = 'id';
    protected $returnType = 'array';
    protected $allowedFields = [];

    public function findActiveByEmail(string $email): ?array
    {
        $user = $this->builder()
            ->select('usuarios.id, usuarios.rol_id, usuarios.emprendimiento_id, usuarios.nombre, usuarios.apellido, usuarios.correo, usuarios.password_hash, usuarios.debe_cambiar_clave, roles.nombre AS rol_nombre')
            ->join('roles', 'roles.id = usuarios.rol_id')
            ->where('usuarios.correo', $email)
            ->where('usuarios.activo', 1)
            ->where('usuarios.fec_eliminacion', null)
            ->get()
            ->getRowArray();

        return $user === null ? null : $user;
    }

    /**
     * @return list<array{id: int, nombre: string, tenant_key: string|null, usa_productos: bool, usa_servicios: bool}>
     */
    public function findBusinesses(int $userId): array
    {
        $business = db_connect()->table('usuarios AS u')
            ->select('e.id, e.nombre, e.database_key AS tenant_key, e.usa_productos, e.usa_servicios')
            ->join('emprendimientos AS e', 'e.id = u.emprendimiento_id')
            ->where('u.id', $userId)
            ->where('u.activo', 1)
            ->where('u.fec_eliminacion', null)
            ->where('e.activo', 1)
            ->where('e.fec_eliminacion', null)
            ->get()
            ->getRowArray();

        return $business === null ? [] : [[
            'id' => (int) $business['id'],
            'nombre' => $business['nombre'],
            'tenant_key' => $business['tenant_key'],
            'usa_productos' => (bool) $business['usa_productos'],
            'usa_servicios' => (bool) $business['usa_servicios'],
        ]];
    }

    /**
     * @return list<array{id: int, nombre: string, tenant_key: string|null, usa_productos: bool, usa_servicios: bool}>
     */
    public function findActiveBusinesses(): array
    {
        $businesses = db_connect()->table('emprendimientos')
            ->select('id, nombre, database_key AS tenant_key, usa_productos, usa_servicios')
            ->where('activo', 1)
            ->where('fec_eliminacion', null)
            ->orderBy('nombre')
            ->get()
            ->getResultArray();

        return array_map(static fn (array $business): array => [
            'id' => (int) $business['id'],
            'nombre' => $business['nombre'],
            'tenant_key' => $business['tenant_key'],
            'usa_productos' => (bool) $business['usa_productos'],
            'usa_servicios' => (bool) $business['usa_servicios'],
        ], $businesses);
    }

    public function findActiveBusiness(int $businessId): ?array
    {
        $business = db_connect()->table('emprendimientos')
            ->select('id, nombre, database_key AS tenant_key, usa_productos, usa_servicios')
            ->where('id', $businessId)
            ->where('activo', 1)
            ->where('fec_eliminacion', null)
            ->get()
            ->getRowArray();

        return $business === null ? null : [
            'id' => (int) $business['id'],
            'nombre' => $business['nombre'],
            'tenant_key' => $business['tenant_key'],
            'usa_productos' => (bool) $business['usa_productos'],
            'usa_servicios' => (bool) $business['usa_servicios'],
        ];
    }

    public function findBusinessForUser(int $userId, int $businessId): ?array
    {
        foreach ($this->findBusinesses($userId) as $business) {
            if ($business['id'] === $businessId) {
                return $business;
            }
        }

        return null;
    }

    public function recordLogin(int $userId): void
    {
        $this->builder()
            ->where('id', $userId)
            ->update(['ultimo_acceso_at' => date('Y-m-d H:i:s')]);
    }
}
