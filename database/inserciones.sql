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
-- 2. INSERTAR LOS 26 EMPRENDIMIENTOS
-- ============================================================

INSERT INTO emprendimientos
(
    categoria,
    nombre,
    correo,
    database_key,
    activo
)
VALUES

('Artesanales', 'Calzado John H. Mateo',
 'calzado_john@tisaleoemprende.ec',
 'db_emp_calzado_john', 1),

('Artesanales', 'ALJU',
 'alju@tisaleoemprende.ec',
 'db_emp_alju', 1),

('Artesanales', 'Lufeli',
 'lufeli@tisaleoemprende.ec',
 'db_emp_lufeli', 1),

('Artesanales', 'Helados Golositos',
 'helados_golositos@tisaleoemprende.ec',
 'db_emp_helados_golositos', 1),

('Artesanales', 'Heladería Karito',
 'heladeria_karito@tisaleoemprende.ec',
 'db_emp_heladeria_karito', 1),

('Artesanales', 'Conos Kelvin',
 'conos_kelvin@tisaleoemprende.ec',
 'db_emp_conos_kelvin', 1),

('Artesanales', 'Turrones- Don Goyo',
 'turrones_don_goyo@tisaleoemprende.ec',
 'db_emp_turrones_don_goyo', 1),

('Agricultura', 'Razu - Corp',
 'razu_corp@tisaleoemprende.ec',
 'db_emp_razu_corp', 1),

('Agricultura', 'Bodega G&A "Dulce Mora"',
 'bodega_ga_dulce_mora@tisaleoemprende.ec',
 'db_emp_bodega_ga', 1),

('Agricultura', 'SirackAgro Industria',
 'sirackagro_industria@tisaleoemprende.ec',
 'db_emp_sirackagro', 1),

('Agricultura', 'Vinos San Juan',
 'vinos_san_juan@tisaleoemprende.ec',
 'db_emp_vinos_san_juan', 1),

('Agricultura', 'Granja Ainhoa',
 'granja_ainhoa@tisaleoemprende.ec',
 'db_emp_granja_ainhoa', 1),

('Agricultura', 'Vinos M&M',
 'vinos_mm@tisaleoemprende.ec',
 'db_emp_vinos_mm', 1),

('Agricultura', 'Barros Nicole',
 'barros_nicole@tisaleoemprende.ec',
 'db_emp_barros_nicole', 1),

('Agricultura', 'Vinos Mopocita',
 'vinos_mopocita@tisaleoemprende.ec',
 'db_emp_vinos_mopocita', 1),

('Agricultura', 'Vinos y Miel de Abeja Don Bolo',
 'vinos_miel_don_bolo@tisaleoemprende.ec',
 'db_emp_vinos_don_bolo', 1),

('Turístico', 'Granja Ecológica San José',
 'granja_ecologica_san_jose@tisaleoemprende.ec',
 'db_emp_granja_san_jose', 1),

('Turístico', 'Museo Santa Lucía',
 'museo_santa_lucia@tisaleoemprende.ec',
 'db_emp_museo_santa_lucia', 1),

('Turístico', 'Granja San Martin',
 'granja_san_martin@tisaleoemprende.ec',
 'db_emp_granja_san_martin', 1),

('Agropecuarios', 'San Miguel',
 'san_miguel@tisaleoemprende.ec',
 'db_emp_san_miguel', 1),

('Agropecuarios', 'Asociación de productores agropecuarios "Unión y Hermandad"',
 'asoc_union_y_hermandad@tisaleoemprende.ec',
 'db_emp_union_hermandad', 1),

('Agropecuarios', 'Asociación Agropecuaria Quinchicoto',
 'asoc_agropecuaria_quinchicoto@tisaleoemprende.ec',
 'db_emp_asoc_quinchicoto', 1),

('Agropecuarios', 'Asociación Unión Tisaleña',
 'asoc_union_tisalena@tisaleoemprende.ec',
 'db_emp_union_tisalena', 1)

ON DUPLICATE KEY UPDATE
    categoria = VALUES(categoria),
    nombre = VALUES(nombre),
    correo = VALUES(correo),
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