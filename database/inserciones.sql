USE usuarios_tisaleo;

-- ============================================================
-- 1. INSERTAR ROLES OFICIALES
-- ============================================================

INSERT INTO roles (nombre, descripcion)
VALUES
('admin', 'Administrador del sistema'),
('propietario', 'Propietario de un emprendimiento'),
('empleado', 'Empleado de un emprendimiento')
ON DUPLICATE KEY UPDATE
    descripcion = VALUES(descripcion);


-- ============================================================
-- 2. INSERTAR LOS 26 EMPRENDIMIENTOS CON CREDENCIALES DINÁMICAS
-- ============================================================

INSERT INTO emprendimientos
(
    categoria,
    nombre,
    correo,
    database_key,
    usuario_bd,
    contrasenia_bd,
    activo
)
VALUES

('Artesanales', 'Calzado John H. Mateo',
 'calzado_john@tisaleoemprende.ec',
 'db_emp_calzado_john', 'emp_calzado_john', 'DbPass_calzado1', 1),

('Artesanales', 'ALJU',
 'alju@tisaleoemprende.ec',
 'db_emp_alju', 'emp_alju', 'DbPass_alju2', 1),

('Artesanales', 'Lufeli',
 'lufeli@tisaleoemprende.ec',
 'db_emp_lufeli', 'emp_lufeli', 'DbPass_lufeli3', 1),

('Artesanales', 'Helados Golositos',
 'helados_golositos@tisaleoemprende.ec',
 'db_emp_helados_golositos', 'emp_helados_golositos', 'DbPass_helados4', 1),

('Artesanales', 'Heladería Karito',
 'heladeria_karito@tisaleoemprende.ec',
 'db_emp_heladeria_karito', 'emp_heladeria_karito', 'DbPass_heladeria5', 1),

('Artesanales', 'Conos Kelvin',
 'conos_kelvin@tisaleoemprende.ec',
 'db_emp_conos_kelvin', 'emp_conos_kelvin', 'DbPass_conos6', 1),

('Artesanales', 'Turrones- Don Goyo',
 'turrones_don_goyo@tisaleoemprende.ec',
 'db_emp_turrones_don_goyo', 'emp_turrones_don_goyo', 'DbPass_turrones7', 1),

('Agricultura', 'Razu - Corp',
 'razu_corp@tisaleoemprende.ec',
 'db_emp_razu_corp', 'emp_razu_corp', 'DbPass_razu8', 1),

('Agricultura', 'Bodega G&A "Dulce Mora"',
 'bodega_ga_dulce_mora@tisaleoemprende.ec',
 'db_emp_bodega_ga', 'emp_bodega_ga', 'DbPass_bodega9', 1),

('Agricultura', 'SirackAgro Industria',
 'sirackagro_industria@tisaleoemprende.ec',
 'db_emp_sirackagro', 'emp_sirackagro', 'DbPass_sirack10', 1),

('Agricultura', 'Vinos San Juan',
 'vinos_san_juan@tisaleoemprende.ec',
 'db_emp_vinos_san_juan', 'emp_vinos_san_juan', 'DbPass_vinos11', 1),

('Artesanales', 'SachaLuna',
 'sachaluna@tisaleoemprende.ec',
 'db_emp_sachaluna', 'emp_sachaluna', 'DbPass_sacha12', 1),

('Agricultura', 'Granja Ainhoa',
 'granja_ainhoa@tisaleoemprende.ec',
 'db_emp_granja_ainhoa', 'emp_granja_ainhoa', 'DbPass_granja13', 1),

('Agricultura', 'Vinos La Florida',
 'vinos_la_florida@tisaleoemprende.ec',
 'db_emp_vinos_la_florida', 'emp_vinos_la_florida', 'DbPass_vinos14', 1),

('Agricultura', 'Vinos M&M',
 'vinos_mm@tisaleoemprende.ec',
 'db_emp_vinos_mm', 'emp_vinos_mm', 'DbPass_vinos15', 1),

('Agricultura', 'Barros Nicole',
 'barros_nicole@tisaleoemprende.ec',
 'db_emp_barros_nicole', 'emp_barros_nicole', 'DbPass_barros16', 1),

('Agricultura', 'Vinos Mopocita',
 'vinos_mopocita@tisaleoemprende.ec',
 'db_emp_vinos_mopocita', 'emp_vinos_mopocita', 'DbPass_vinos17', 1),

('Agricultura', 'Vinos y Miel de Abeja Don Bolo',
 'vinos_miel_don_bolo@tisaleoemprende.ec',
 'db_emp_vinos_don_bolo', 'emp_vinos_don_bolo', 'DbPass_vinos18', 1),

('Turístico', 'Granja Ecológica San José',
 'granja_ecologica_san_jose@tisaleoemprende.ec',
 'db_emp_granja_san_jose', 'emp_granja_san_jose', 'DbPass_granja19', 1),

('Turístico', 'Museo Santa Lucía',
 'museo_santa_lucia@tisaleoemprende.ec',
 'db_emp_museo_santa_lucia', 'emp_museo_santa_lucia', 'DbPass_museo20', 1),

('Turístico', 'Granja San Martin',
 'granja_san_martin@tisaleoemprende.ec',
 'db_emp_granja_san_martin', 'emp_granja_san_martin', 'DbPass_granja21', 1),

('Turístico', 'Quinta "La Guadalupana"',
 'quinta_la_guadalupana@tisaleoemprende.ec',
 'db_emp_la_guadalupana', 'emp_la_guadalupana', 'DbPass_quinta22', 1),

('Agropecuarios', 'San Miguel',
 'san_miguel@tisaleoemprende.ec',
 'db_emp_san_miguel', 'emp_san_miguel', 'DbPass_sanmiguel23', 1),

('Agropecuarios', 'Asociación de productores agropecuarios "Unión y Hermandad"',
 'asoc_union_y_hermandad@tisaleoemprende.ec',
 'db_emp_union_hermandad', 'emp_union_hermandad', 'DbPass_union24', 1),

('Agropecuarios', 'Asociación Agropecuaria Quinchicoto',
 'asoc_agropecuaria_quinchicoto@tisaleoemprende.ec',
 'db_emp_asoc_quinchicoto', 'emp_asoc_quinchicoto', 'DbPass_asoc25', 1),

('Agropecuarios', 'Asociación Unión Tisaleña',
 'asoc_union_tisalena@tisaleoemprende.ec',
 'db_emp_union_tisalena', 'emp_union_tisalena', 'DbPass_union26', 1)

ON DUPLICATE KEY UPDATE
    categoria = VALUES(categoria),
    nombre = VALUES(nombre),
    correo = VALUES(correo),
    usuario_bd = VALUES(usuario_bd),
    contrasenia_bd = VALUES(contrasenia_bd),
    activo = VALUES(activo);


-- ============================================================
-- 3. VERIFICAR LOS EMPRENDIMIENTOS INSERTADOS
-- ============================================================

SELECT
    id,
    categoria,
    nombre,
    correo,
    database_key,
    usuario_bd,
    contrasenia_bd,
    activo
FROM emprendimientos
ORDER BY id;


-- ============================================================
-- 4. VERIFICAR LOS ROLES
-- ============================================================

SELECT
    id,
    nombre,
    descripcion
FROM roles
ORDER BY id;


-- ============================================================
-- 5. COMPROBAR CANTIDAD DE EMPRENDIMIENTOS
-- ============================================================

SELECT COUNT(*) AS total_emprendimientos
FROM emprendimientos;
