<?php

namespace App\Database\Seeds;

use CodeIgniter\CLI\CLI;
use CodeIgniter\Database\Seeder;
use RuntimeException;

class EmprendimientosSeeder extends Seeder
{
    /**
     * Catálogo de los 26 emprendimientos con sus credenciales de base de datos.
     *
     * @var list<array{
     *     numero: int,
     *     categoria: string,
     *     nombre: string,
     *     correo: string,
     *     database_key: string,
     *     usuario_bd: string,
     *     contrasenia_bd: string
     * }>
     */
    private array $emprendimientos = [
        [
            'numero'         => 1,
            'categoria'      => 'Artesanales',
            'nombre'         => 'Calzado John H. Mateo',
            'correo'         => 'calzado_john@tisaleoemprende.ec',
            'database_key'   => 'db_emp_calzado_john',
            'usuario_bd'     => 'emp_calzado_john',
            'contrasenia_bd' => 'DbPass_calzado1',
        ],
        [
            'numero'         => 2,
            'categoria'      => 'Artesanales',
            'nombre'         => 'ALJU',
            'correo'         => 'alju@tisaleoemprende.ec',
            'database_key'   => 'db_emp_alju',
            'usuario_bd'     => 'emp_alju',
            'contrasenia_bd' => 'DbPass_alju2',
        ],
        [
            'numero'         => 3,
            'categoria'      => 'Artesanales',
            'nombre'         => 'Lufeli',
            'correo'         => 'lufeli@tisaleoemprende.ec',
            'database_key'   => 'db_emp_lufeli',
            'usuario_bd'     => 'emp_lufeli',
            'contrasenia_bd' => 'DbPass_lufeli3',
        ],
        [
            'numero'         => 4,
            'categoria'      => 'Artesanales',
            'nombre'         => 'Helados Golositos',
            'correo'         => 'helados_golositos@tisaleoemprende.ec',
            'database_key'   => 'db_emp_helados_golositos',
            'usuario_bd'     => 'emp_helados_golositos',
            'contrasenia_bd' => 'DbPass_helados4',
        ],
        [
            'numero'         => 5,
            'categoria'      => 'Artesanales',
            'nombre'         => 'Heladería Karito',
            'correo'         => 'heladeria_karito@tisaleoemprende.ec',
            'database_key'   => 'db_emp_heladeria_karito',
            'usuario_bd'     => 'emp_heladeria_karito',
            'contrasenia_bd' => 'DbPass_heladeria5',
        ],
        [
            'numero'         => 6,
            'categoria'      => 'Artesanales',
            'nombre'         => 'Conos Kelvin',
            'correo'         => 'conos_kelvin@tisaleoemprende.ec',
            'database_key'   => 'db_emp_conos_kelvin',
            'usuario_bd'     => 'emp_conos_kelvin',
            'contrasenia_bd' => 'DbPass_conos6',
        ],
        [
            'numero'         => 7,
            'categoria'      => 'Artesanales',
            'nombre'         => 'Turrones- Don Goyo',
            'correo'         => 'turrones_don_goyo@tisaleoemprende.ec',
            'database_key'   => 'db_emp_turrones_don_goyo',
            'usuario_bd'     => 'emp_turrones_don_goyo',
            'contrasenia_bd' => 'DbPass_turrones7',
        ],
        [
            'numero'         => 8,
            'categoria'      => 'Agricultura',
            'nombre'         => 'Razu - Corp',
            'correo'         => 'razu_corp@tisaleoemprende.ec',
            'database_key'   => 'db_emp_razu_corp',
            'usuario_bd'     => 'emp_razu_corp',
            'contrasenia_bd' => 'DbPass_razu8',
        ],
        [
            'numero'         => 9,
            'categoria'      => 'Agricultura',
            'nombre'         => 'Bodega G&A "Dulce Mora"',
            'correo'         => 'bodega_ga_dulce_mora@tisaleoemprende.ec',
            'database_key'   => 'db_emp_bodega_ga',
            'usuario_bd'     => 'emp_bodega_ga',
            'contrasenia_bd' => 'DbPass_bodega9',
        ],
        [
            'numero'         => 10,
            'categoria'      => 'Agricultura',
            'nombre'         => 'SirackAgro Industria',
            'correo'         => 'sirackagro_industria@tisaleoemprende.ec',
            'database_key'   => 'db_emp_sirackagro',
            'usuario_bd'     => 'emp_sirackagro',
            'contrasenia_bd' => 'DbPass_sirack10',
        ],
        [
            'numero'         => 11,
            'categoria'      => 'Agricultura',
            'nombre'         => 'Vinos San Juan',
            'correo'         => 'vinos_san_juan@tisaleoemprende.ec',
            'database_key'   => 'db_emp_vinos_san_juan',
            'usuario_bd'     => 'emp_vinos_san_juan',
            'contrasenia_bd' => 'DbPass_vinos11',
        ],
        [
            'numero'         => 12,
            'categoria'      => 'Artesanales',
            'nombre'         => 'SachaLuna',
            'correo'         => 'sachaluna@tisaleoemprende.ec',
            'database_key'   => 'db_emp_sachaluna',
            'usuario_bd'     => 'emp_sachaluna',
            'contrasenia_bd' => 'DbPass_sacha12',
        ],
        [
            'numero'         => 13,
            'categoria'      => 'Agricultura',
            'nombre'         => 'Granja Ainhoa',
            'correo'         => 'granja_ainhoa@tisaleoemprende.ec',
            'database_key'   => 'db_emp_granja_ainhoa',
            'usuario_bd'     => 'emp_granja_ainhoa',
            'contrasenia_bd' => 'DbPass_granja13',
        ],
        [
            'numero'         => 14,
            'categoria'      => 'Agricultura',
            'nombre'         => 'Vinos La Florida',
            'correo'         => 'vinos_la_florida@tisaleoemprende.ec',
            'database_key'   => 'db_emp_vinos_la_florida',
            'usuario_bd'     => 'emp_vinos_la_florida',
            'contrasenia_bd' => 'DbPass_vinos14',
        ],
        [
            'numero'         => 15,
            'categoria'      => 'Agricultura',
            'nombre'         => 'Vinos M&M',
            'correo'         => 'vinos_mm@tisaleoemprende.ec',
            'database_key'   => 'db_emp_vinos_mm',
            'usuario_bd'     => 'emp_vinos_mm',
            'contrasenia_bd' => 'DbPass_vinos15',
        ],
        [
            'numero'         => 16,
            'categoria'      => 'Agricultura',
            'nombre'         => 'Barros Nicole',
            'correo'         => 'barros_nicole@tisaleoemprende.ec',
            'database_key'   => 'db_emp_barros_nicole',
            'usuario_bd'     => 'emp_barros_nicole',
            'contrasenia_bd' => 'DbPass_barros16',
        ],
        [
            'numero'         => 17,
            'categoria'      => 'Agricultura',
            'nombre'         => 'Vinos Mopocita',
            'correo'         => 'vinos_mopocita@tisaleoemprende.ec',
            'database_key'   => 'db_emp_vinos_mopocita',
            'usuario_bd'     => 'emp_vinos_mopocita',
            'contrasenia_bd' => 'DbPass_vinos17',
        ],
        [
            'numero'         => 18,
            'categoria'      => 'Agricultura',
            'nombre'         => 'Vinos y Miel de Abeja Don Bolo',
            'correo'         => 'vinos_miel_don_bolo@tisaleoemprende.ec',
            'database_key'   => 'db_emp_vinos_don_bolo',
            'usuario_bd'     => 'emp_vinos_don_bolo',
            'contrasenia_bd' => 'DbPass_vinos18',
        ],
        [
            'numero'         => 19,
            'categoria'      => 'Turístico',
            'nombre'         => 'Granja Ecológica San José',
            'correo'         => 'granja_ecologica_san_jose@tisaleoemprende.ec',
            'database_key'   => 'db_emp_granja_san_jose',
            'usuario_bd'     => 'emp_granja_san_jose',
            'contrasenia_bd' => 'DbPass_granja19',
        ],
        [
            'numero'         => 20,
            'categoria'      => 'Turístico',
            'nombre'         => 'Museo Santa Lucía',
            'correo'         => 'museo_santa_lucia@tisaleoemprende.ec',
            'database_key'   => 'db_emp_museo_santa_lucia',
            'usuario_bd'     => 'emp_museo_santa_lucia',
            'contrasenia_bd' => 'DbPass_museo20',
        ],
        [
            'numero'         => 21,
            'categoria'      => 'Turístico',
            'nombre'         => 'Granja San Martin',
            'correo'         => 'granja_san_martin@tisaleoemprende.ec',
            'database_key'   => 'db_emp_granja_san_martin',
            'usuario_bd'     => 'emp_granja_san_martin',
            'contrasenia_bd' => 'DbPass_granja21',
        ],
        [
            'numero'         => 22,
            'categoria'      => 'Turístico',
            'nombre'         => 'Quinta "La Guadalupana"',
            'correo'         => 'quinta_la_guadalupana@tisaleoemprende.ec',
            'database_key'   => 'db_emp_la_guadalupana',
            'usuario_bd'     => 'emp_la_guadalupana',
            'contrasenia_bd' => 'DbPass_quinta22',
        ],
        [
            'numero'         => 23,
            'categoria'      => 'Agropecuarios',
            'nombre'         => 'San Miguel',
            'correo'         => 'san_miguel@tisaleoemprende.ec',
            'database_key'   => 'db_emp_san_miguel',
            'usuario_bd'     => 'emp_san_miguel',
            'contrasenia_bd' => 'DbPass_sanmiguel23',
        ],
        [
            'numero'         => 24,
            'categoria'      => 'Agropecuarios',
            'nombre'         => 'Asociación de productores agropecuarios "Unión y Hermandad"',
            'correo'         => 'asoc_union_y_hermandad@tisaleoemprende.ec',
            'database_key'   => 'db_emp_union_hermandad',
            'usuario_bd'     => 'emp_union_hermandad',
            'contrasenia_bd' => 'DbPass_union24',
        ],
        [
            'numero'         => 25,
            'categoria'      => 'Agropecuarios',
            'nombre'         => 'Asociación Agropecuaria Quinchicoto',
            'correo'         => 'asoc_agropecuaria_quinchicoto@tisaleoemprende.ec',
            'database_key'   => 'db_emp_asoc_quinchicoto',
            'usuario_bd'     => 'emp_asoc_quinchicoto',
            'contrasenia_bd' => 'DbPass_asoc25',
        ],
        [
            'numero'         => 26,
            'categoria'      => 'Agropecuarios',
            'nombre'         => 'Asociación Unión Tisaleña',
            'correo'         => 'asoc_union_tisalena@tisaleoemprende.ec',
            'database_key'   => 'db_emp_union_tisalena',
            'usuario_bd'     => 'emp_union_tisalena',
            'contrasenia_bd' => 'DbPass_union26',
        ],
    ];

    public function run(): void
    {
        $this->db->transBegin();

        try {
            $inserted = 0;
            $updated = 0;

            foreach ($this->emprendimientos as $emp) {
                $existing = $this->db->table('emprendimientos')
                    ->where('database_key', $emp['database_key'])
                    ->orWhere('nombre', $emp['nombre'])
                    ->get()
                    ->getRowArray();

                $payload = [
                    'categoria'      => $emp['categoria'],
                    'nombre'         => $emp['nombre'],
                    'correo'         => $emp['correo'],
                    'database_key'   => $emp['database_key'],
                    'usuario_bd'     => $emp['usuario_bd'],
                    'contrasenia_bd' => $emp['contrasenia_bd'],
                    'activo'         => 1,
                    'usa_productos'  => 1,
                    'usa_servicios'  => 1,
                ];

                if ($existing !== null) {
                    $this->db->table('emprendimientos')
                        ->where('id', $existing['id'])
                        ->update($payload);
                    $updated++;
                } else {
                    $this->db->table('emprendimientos')->insert($payload);
                    $inserted++;
                }
            }

            if (! $this->db->transStatus()) {
                throw new RuntimeException('Error al guardar los 26 emprendimientos en la base central.');
            }

            $this->db->transCommit();
            CLI::write("EmprendimientosSeeder completado: {$inserted} creados, {$updated} actualizados.", 'green');
        } catch (\Throwable $exception) {
            $this->db->transRollback();
            throw $exception;
        }
    }
}
