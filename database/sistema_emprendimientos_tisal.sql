-- Esquema central minimo para iniciar sesion y asociar usuarios a emprendimientos.
-- Preparado para la aplicacion actual; no incluye tablas operativas de productos/ventas.
-- Importar este archivo una sola vez en MariaDB. No ejecutar spark migrate sobre este
-- esquema: las migraciones del proyecto agregan campos que ya se crean aqui.

CREATE DATABASE IF NOT EXISTS sistema_emprendimientos_tisal
    CHARACTER SET utf8mb4
    COLLATE utf8mb4_unicode_ci;

USE sistema_emprendimientos_tisal;

CREATE TABLE IF NOT EXISTS roles (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(50) NOT NULL,
    descripcion VARCHAR(255) NULL,
    fec_creacion TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    fec_actualizacion TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    fec_eliminacion TIMESTAMP NULL DEFAULT NULL,
    UNIQUE KEY uq_roles_nombre (nombre)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS emprendimientos (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    categoria VARCHAR(100) NOT NULL,
    nombre VARCHAR(150) NOT NULL,
    identificacion VARCHAR(40) NULL,
    representante VARCHAR(150) NULL,
    database_key VARCHAR(40) NULL,
    telefono VARCHAR(30) NULL,
    correo VARCHAR(254) NULL,
    direccion VARCHAR(255) NULL,
    descripcion TEXT NULL,
    usa_productos TINYINT(1) NOT NULL DEFAULT 1,
    usa_servicios TINYINT(1) NOT NULL DEFAULT 1,
    activo TINYINT(1) NOT NULL DEFAULT 1,
    fec_creacion TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    fec_actualizacion TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    fec_eliminacion TIMESTAMP NULL DEFAULT NULL,
    UNIQUE KEY uq_emprendimientos_database_key (database_key)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS usuarios (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    rol_id BIGINT UNSIGNED NOT NULL,
    emprendimiento_id BIGINT UNSIGNED NULL,
    nombre VARCHAR(100) NOT NULL,
    apellido VARCHAR(100) NULL,
    correo VARCHAR(254) NOT NULL,
    telefono VARCHAR(30) NULL,
    password_hash VARCHAR(255) NOT NULL,
    debe_cambiar_clave TINYINT(1) NOT NULL DEFAULT 0,
    activo TINYINT(1) NOT NULL DEFAULT 1,
    ultimo_acceso_at DATETIME NULL,
    fec_creacion TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    fec_actualizacion TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    fec_eliminacion TIMESTAMP NULL DEFAULT NULL,
    UNIQUE KEY uq_usuarios_correo (correo),
    INDEX idx_usuarios_emprendimiento (emprendimiento_id),
    INDEX idx_usuarios_rol_activo (rol_id, activo),
    CONSTRAINT fk_usuarios_rol
        FOREIGN KEY (rol_id) REFERENCES roles (id)
        ON UPDATE CASCADE ON DELETE RESTRICT,
    CONSTRAINT fk_usuarios_emprendimiento
        FOREIGN KEY (emprendimiento_id) REFERENCES emprendimientos (id)
        ON UPDATE CASCADE ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS usuario_emprendimientos (
    usuario_id BIGINT UNSIGNED NOT NULL,
    emprendimiento_id BIGINT UNSIGNED NOT NULL,
    PRIMARY KEY (usuario_id, emprendimiento_id),
    INDEX idx_usuario_emprendimientos_emprendimiento (emprendimiento_id),
    CONSTRAINT fk_usuario_emprendimientos_usuario
        FOREIGN KEY (usuario_id) REFERENCES usuarios (id)
        ON UPDATE CASCADE ON DELETE CASCADE,
    CONSTRAINT fk_usuario_emprendimientos_emprendimiento
        FOREIGN KEY (emprendimiento_id) REFERENCES emprendimientos (id)
        ON UPDATE CASCADE ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

INSERT INTO roles (nombre, descripcion)
VALUES
    ('admin', 'Administrador del sistema'),
    ('propietario', 'Propietario de un emprendimiento'),
    ('empleado', 'Empleado de un emprendimiento')
ON DUPLICATE KEY UPDATE descripcion = VALUES(descripcion);

INSERT INTO emprendimientos (
    categoria, nombre, database_key, usa_productos, usa_servicios, activo
)
VALUES
    ('Artesanal', 'Turrones- Don Goyo', 'don_goyo', 1, 1, 1),
    ('Agropecuario', 'Razu - Corp', 'razu', 1, 1, 1),
    ('Agropecuario', 'Bodega G&A "Dulce Mora"', 'dulce_mora', 1, 1, 1)
ON DUPLICATE KEY UPDATE
    categoria = VALUES(categoria),
    nombre = VALUES(nombre),
    activo = 1,
    fec_eliminacion = NULL;

SET @rol_admin_id = (SELECT id FROM roles WHERE nombre = 'admin' LIMIT 1);
SET @rol_propietario_id = (SELECT id FROM roles WHERE nombre = 'propietario' LIMIT 1);
SET @rol_empleado_id = (SELECT id FROM roles WHERE nombre = 'empleado' LIMIT 1);

SET @don_goyo_id = (SELECT id FROM emprendimientos WHERE database_key = 'don_goyo' LIMIT 1);
SET @razu_id = (SELECT id FROM emprendimientos WHERE database_key = 'razu' LIMIT 1);
SET @dulce_mora_id = (SELECT id FROM emprendimientos WHERE database_key = 'dulce_mora' LIMIT 1);

-- La cuenta con TISALEO_OWNER_EMAIL es el administrador global.


--
-- Las claves que se guardan en la base son con hash
--

INSERT INTO usuarios (
    rol_id, emprendimiento_id, nombre, apellido, correo, password_hash,
    debe_cambiar_clave, activo
)
VALUES (
    @rol_admin_id, NULL, 'Administrador', 'Tisaleo',
    'admin@tisaleo.local',
    '$2y$10$XoG83pNzyzmhHNrZ5fDYn.Pz86amPt7CNmqW2DJkR.X8Qy9C0IQdS',
    1, 1
)
ON DUPLICATE KEY UPDATE id = LAST_INSERT_ID(id);

INSERT INTO usuarios (
    rol_id, emprendimiento_id, nombre, apellido, correo, password_hash,
    debe_cambiar_clave, activo
)
VALUES
    (@rol_propietario_id, @don_goyo_id, 'Propietario', 'Don Goyo', 'propietario.dongoyo@tisaleo.local', '$2y$10$UlS3Hn0UHRslVjFGk3I.9OjhkbGN/RxMsDIKa7.LSGXUWlASiIjvm', 1, 1),
    (@rol_propietario_id, @razu_id, 'Propietario', 'RaZu', 'propietario.razu@tisaleo.local', '$2y$10$s7tXrynzt6uS9hXOGe/rIebF7G8usi9uz/ZXMEn8QHf1b3UNGBNdu', 1, 1),
    (@rol_propietario_id, @dulce_mora_id, 'Propietario', 'Dulce Mora', 'propietario.dulcemora@tisaleo.local', '$2y$10$BKn4Iek56HDDqBE3h3Py3urM3LfEalVV7H77O9ZoGp1vY3hKDnXWS', 1, 1),
    (@rol_empleado_id, @don_goyo_id, 'Empleado', 'Don Goyo', 'empleado.dongoyo@tisaleo.local', '$2y$10$6UZevwj22FuY2lG2DI6t7eDjtSmz2WnjJjxy43XlYmC5lwFSBcX1y', 1, 1),
    (@rol_empleado_id, @razu_id, 'Empleado', 'RaZu', 'empleado.razu@tisaleo.local', '$2y$10$wWrM8CV5DSC0enEB/9FF1.mP11Gxxy7UAReWQ21Jx2FC5pwBLmR8e', 1, 1),
    (@rol_empleado_id, @dulce_mora_id, 'Empleado', 'Dulce Mora', 'empleado.dulcemora@tisaleo.local', '$2y$10$J4RWpUoPoyYFg1.0T0ijAu2duJgoXnkgPp0ostTf2oGLegsbhybmK', 1, 1)
ON DUPLICATE KEY UPDATE id = LAST_INSERT_ID(id);

INSERT INTO usuario_emprendimientos (usuario_id, emprendimiento_id)
SELECT usuarios.id, cuentas.emprendimiento_id
FROM usuarios
JOIN (
    SELECT 'propietario.dongoyo@tisaleo.local' AS correo, @don_goyo_id AS emprendimiento_id
    UNION ALL SELECT 'propietario.razu@tisaleo.local', @razu_id
    UNION ALL SELECT 'propietario.dulcemora@tisaleo.local', @dulce_mora_id
    UNION ALL SELECT 'empleado.dongoyo@tisaleo.local', @don_goyo_id
    UNION ALL SELECT 'empleado.razu@tisaleo.local', @razu_id
    UNION ALL SELECT 'empleado.dulcemora@tisaleo.local', @dulce_mora_id
) AS cuentas ON cuentas.correo = usuarios.correo
ON DUPLICATE KEY UPDATE emprendimiento_id = VALUES(emprendimiento_id);
