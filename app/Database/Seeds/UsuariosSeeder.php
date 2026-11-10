<?php

namespace App\Database\Seeds;

use CodeIgniter\CLI\CLI;
use CodeIgniter\Database\Seeder;
use RuntimeException;

class UsuariosSeeder extends Seeder
{
    /**
     * Catálogo de los 26 usuarios de los emprendimientos.
     *
     * @var list<array{
     *     numero: int,
     *     emprendimiento: string,
     *     database_key: string,
     *     usuario: string,
     *     contrasena: string,
     *     usuario_bd: string,
     *     contrasenia_bd: string
     * }>
     */
    private array $cuentas = [
        [
            'numero'         => 1,
            'emprendimiento' => 'Calzado John H. Mateo',
            'database_key'   => 'db_emp_calzado_john',
            'usuario'        => 'calzado_john',
            'contrasena'     => 'CalzadoJohn2026*',
            'usuario_bd'     => 'emp_calzado_john',
            'contrasenia_bd' => 'DbPass_calzado1',
        ],
        [
            'numero'         => 2,
            'emprendimiento' => 'ALJU',
            'database_key'   => 'db_emp_alju',
            'usuario'        => 'alju',
            'contrasena'     => 'Alju2026*',
            'usuario_bd'     => 'emp_alju',
            'contrasenia_bd' => 'DbPass_alju2',
        ],
        [
            'numero'         => 3,
            'emprendimiento' => 'Lufeli',
            'database_key'   => 'db_emp_lufeli',
            'usuario'        => 'lufeli',
            'contrasena'     => 'Lufeli2026*',
            'usuario_bd'     => 'emp_lufeli',
            'contrasenia_bd' => 'DbPass_lufeli3',
        ],
        [
            'numero'         => 4,
            'emprendimiento' => 'Helados Golositos',
            'database_key'   => 'db_emp_helados_golositos',
            'usuario'        => 'helados_golositos',
            'contrasena'     => 'HeladosGolositos2026*',
            'usuario_bd'     => 'emp_helados_golositos',
            'contrasenia_bd' => 'DbPass_helados4',
        ],
        [
            'numero'         => 5,
            'emprendimiento' => 'Heladería Karito',
            'database_key'   => 'db_emp_heladeria_karito',
            'usuario'        => 'heladeria_karito',
            'contrasena'     => 'HeladeriaKarito2026*',
            'usuario_bd'     => 'emp_heladeria_karito',
            'contrasenia_bd' => 'DbPass_heladeria5',
        ],
        [
            'numero'         => 6,
            'emprendimiento' => 'Conos Kelvin',
            'database_key'   => 'db_emp_conos_kelvin',
            'usuario'        => 'conos_kelvin',
            'contrasena'     => 'ConosKelvin2026*',
            'usuario_bd'     => 'emp_conos_kelvin',
            'contrasenia_bd' => 'DbPass_conos6',
        ],
        [
            'numero'         => 7,
            'emprendimiento' => 'Turrones- Don Goyo',
            'database_key'   => 'db_emp_turrones_don_goyo',
            'usuario'        => 'turrones_don_goyo',
            'contrasena'     => 'TurronesDonGoyo2026*',
            'usuario_bd'     => 'emp_turrones_don_goyo',
            'contrasenia_bd' => 'DbPass_turrones7',
        ],
        [
            'numero'         => 8,
            'emprendimiento' => 'Razu - Corp',
            'database_key'   => 'db_emp_razu_corp',
            'usuario'        => 'razu_corp',
            'contrasena'     => 'RazuCorp2026*',
            'usuario_bd'     => 'emp_razu_corp',
            'contrasenia_bd' => 'DbPass_razu8',
        ],
        [
            'numero'         => 9,
            'emprendimiento' => 'Bodega G&A "Dulce Mora"',
            'database_key'   => 'db_emp_bodega_ga',
            'usuario'        => 'bodega_ga_dulce_mora',
            'contrasena'     => 'BodegaGADulceMora2026*',
            'usuario_bd'     => 'emp_bodega_ga',
            'contrasenia_bd' => 'DbPass_bodega9',
        ],
        [
            'numero'         => 10,
            'emprendimiento' => 'SirackAgro Industria',
            'database_key'   => 'db_emp_sirackagro',
            'usuario'        => 'sirackagro_industria',
            'contrasena'     => 'SirackAgroIndustria2026*',
            'usuario_bd'     => 'emp_sirackagro',
            'contrasenia_bd' => 'DbPass_sirack10',
        ],
        [
            'numero'         => 11,
            'emprendimiento' => 'Vinos San Juan',
            'database_key'   => 'db_emp_vinos_san_juan',
            'usuario'        => 'vinos_san_juan',
            'contrasena'     => 'VinosSanJuan2026*',
            'usuario_bd'     => 'emp_vinos_san_juan',
            'contrasenia_bd' => 'DbPass_vinos11',
        ],
        [
            'numero'         => 12,
            'emprendimiento' => 'SachaLuna',
            'database_key'   => 'db_emp_sachaluna',
            'usuario'        => 'sachaluna',
            'contrasena'     => 'Sachaluna2026*',
            'usuario_bd'     => 'emp_sachaluna',
            'contrasenia_bd' => 'DbPass_sacha12',
        ],
        [
            'numero'         => 13,
            'emprendimiento' => 'Granja Ainhoa',
            'database_key'   => 'db_emp_granja_ainhoa',
            'usuario'        => 'granja_ainhoa',
            'contrasena'     => 'GranjaAinhoa2026*',
            'usuario_bd'     => 'emp_granja_ainhoa',
            'contrasenia_bd' => 'DbPass_granja13',
        ],
        [
            'numero'         => 14,
            'emprendimiento' => 'Vinos La Florida',
            'database_key'   => 'db_emp_vinos_la_florida',
            'usuario'        => 'vinos_la_florida',
            'contrasena'     => 'VinosLaFlorida2026*',
            'usuario_bd'     => 'emp_vinos_la_florida',
            'contrasenia_bd' => 'DbPass_vinos14',
        ],
        [
            'numero'         => 15,
            'emprendimiento' => 'Vinos M&M',
            'database_key'   => 'db_emp_vinos_mm',
            'usuario'        => 'vinos_mm',
            'contrasena'     => 'VinosMM2026*',
            'usuario_bd'     => 'emp_vinos_mm',
            'contrasenia_bd' => 'DbPass_vinos15',
        ],
        [
            'numero'         => 16,
            'emprendimiento' => 'Barros Nicole',
            'database_key'   => 'db_emp_barros_nicole',
            'usuario'        => 'barros_nicole',
            'contrasena'     => 'BarrosNicole2026*',
            'usuario_bd'     => 'emp_barros_nicole',
            'contrasenia_bd' => 'DbPass_barros16',
        ],
        [
            'numero'         => 17,
            'emprendimiento' => 'Vinos Mopocita',
            'database_key'   => 'db_emp_vinos_mopocita',
            'usuario'        => 'vinos_mopocita',
            'contrasena'     => 'VinosMopocita2026*',
            'usuario_bd'     => 'emp_vinos_mopocita',
            'contrasenia_bd' => 'DbPass_vinos17',
        ],
        [
            'numero'         => 18,
            'emprendimiento' => 'Vinos y Miel de Abeja Don Bolo',
            'database_key'   => 'db_emp_vinos_don_bolo',
            'usuario'        => 'vinos_miel_don_bolo',
            'contrasena'     => 'VinosMielDonBolo2026*',
            'usuario_bd'     => 'emp_vinos_don_bolo',
            'contrasenia_bd' => 'DbPass_vinos18',
        ],
        [
            'numero'         => 19,
            'emprendimiento' => 'Granja Ecológica San José',
            'database_key'   => 'db_emp_granja_san_jose',
            'usuario'        => 'granja_ecologica_san_jose',
            'contrasena'     => 'GranjaSanJose2026*',
            'usuario_bd'     => 'emp_granja_san_jose',
            'contrasenia_bd' => 'DbPass_granja19',
        ],
        [
            'numero'         => 20,
            'emprendimiento' => 'Museo Santa Lucía',
            'database_key'   => 'db_emp_museo_santa_lucia',
            'usuario'        => 'museo_santa_lucia',
            'contrasena'     => 'MuseoSantaLucia2026*',
            'usuario_bd'     => 'emp_museo_santa_lucia',
            'contrasenia_bd' => 'DbPass_museo20',
        ],
        [
            'numero'         => 21,
            'emprendimiento' => 'Granja San Martin',
            'database_key'   => 'db_emp_granja_san_martin',
            'usuario'        => 'granja_san_martin',
            'contrasena'     => 'GranjaSanMartin2026*',
            'usuario_bd'     => 'emp_granja_san_martin',
            'contrasenia_bd' => 'DbPass_granja21',
        ],
        [
            'numero'         => 22,
            'emprendimiento' => 'Quinta "La Guadalupana"',
            'database_key'   => 'db_emp_la_guadalupana',
            'usuario'        => 'quinta_la_guadalupana',
            'contrasena'     => 'QuintaLaGuadalupana2026*',
            'usuario_bd'     => 'emp_la_guadalupana',
            'contrasenia_bd' => 'DbPass_quinta22',
        ],
        [
            'numero'         => 23,
            'emprendimiento' => 'San Miguel',
            'database_key'   => 'db_emp_san_miguel',
            'usuario'        => 'san_miguel',
            'contrasena'     => 'SanMiguel2026*',
            'usuario_bd'     => 'emp_san_miguel',
            'contrasenia_bd' => 'DbPass_sanmiguel23',
        ],
        [
            'numero'         => 24,
            'emprendimiento' => 'Asociación de productores agropecuarios "Unión y Hermandad"',
            'database_key'   => 'db_emp_union_hermandad',
            'usuario'        => 'asoc_union_y_hermandad',
            'contrasena'     => 'UnionYHermandad2026*',
            'usuario_bd'     => 'emp_union_hermandad',
            'contrasenia_bd' => 'DbPass_union24',
        ],
        [
            'numero'         => 25,
            'emprendimiento' => 'Asociación Agropecuaria Quinchicoto',
            'database_key'   => 'db_emp_asoc_quinchicoto',
            'usuario'        => 'asoc_agropecuaria_quinchicoto',
            'contrasena'     => 'AsocQuinchicoto2026*',
            'usuario_bd'     => 'emp_asoc_quinchicoto',
            'contrasenia_bd' => 'DbPass_asoc25',
        ],
        [
            'numero'         => 26,
            'emprendimiento' => 'Asociación Unión Tisaleña',
            'database_key'   => 'db_emp_union_tisalena',
            'usuario'        => 'asoc_union_tisalena',
            'contrasena'     => 'AsocUnionTisalena2026*',
            'usuario_bd'     => 'emp_union_tisalena',
            'contrasenia_bd' => 'DbPass_union26',
        ],
    ];

    public function run(): void
    {
        $this->db->transBegin();

        try {
            $roleId = $this->findOrCreateOwnerRole();
            $created = 0;
            $updated = 0;

            foreach ($this->cuentas as $cuenta) {
                // 1. Obtener el emprendimiento correspondiente
                $business = $this->db->table('emprendimientos')
                    ->where('database_key', $cuenta['database_key'])
                    ->orWhere('nombre', $cuenta['emprendimiento'])
                    ->get()
                    ->getRowArray();

                $businessId = $business !== null ? (int) $business['id'] : null;

                // 2. Construir correo electrónico
                $email = mb_strtolower($cuenta['usuario']) . '@tisaleoemprende.ec';

                // 3. Buscar usuario existente por nombre de usuario o correo
                $existing = $this->db->table('usuarios')
                    ->where('usuario', $cuenta['usuario'])
                    ->orWhere('correo', $email)
                    ->get()
                    ->getRowArray();

                $payload = [
                    'rol_id'             => $roleId,
                    'emprendimiento_id'  => $businessId,
                    'usuario'            => $cuenta['usuario'],
                    'correo'             => $email,
                    'password_hash'      => password_hash($cuenta['contrasena'], PASSWORD_DEFAULT),
                    'debe_cambiar_clave' => 0,
                    'activo'             => 1,
                ];

                if ($existing !== null) {
                    $userId = (int) $existing['id'];
                    $this->db->table('usuarios')->where('id', $userId)->update($payload);
                    $updated++;
                } else {
                    $this->db->table('usuarios')->insert($payload);
                    $userId = (int) $this->db->insertID();
                    $created++;
                }

                // 4. Vincular en tabla intermedia usuario_emprendimientos si existe businessId
                if ($businessId !== null) {
                    $linked = $this->db->table('usuario_emprendimientos')
                        ->where('usuario_id', $userId)
                        ->where('emprendimiento_id', $businessId)
                        ->get()
                        ->getRowArray();

                    if ($linked === null) {
                        $this->db->table('usuario_emprendimientos')->insert([
                            'usuario_id'        => $userId,
                            'emprendimiento_id' => $businessId,
                        ]);
                    }
                }
            }

            if (! $this->db->transStatus()) {
                throw new RuntimeException('Error al guardar las cuentas de usuarios en la base central.');
            }

            $this->db->transCommit();
            CLI::write("UsuariosSeeder completado: {$created} creados, {$updated} actualizados.", 'green');
        } catch (\Throwable $exception) {
            $this->db->transRollback();
            throw $exception;
        }
    }

    private function findOrCreateOwnerRole(): int
    {
        $role = $this->db->table('roles')->where('nombre', 'propietario')->get()->getRowArray();
        if ($role !== null) {
            return (int) $role['id'];
        }

        $this->db->table('roles')->insert([
            'nombre'      => 'propietario',
            'descripcion' => 'Propietario de un emprendimiento',
        ]);

        return (int) $this->db->insertID();
    }
}
