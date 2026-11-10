-- ============================================================
-- BASE DE DATOS CENTRAL DE USUARIOS Y GESTIÓN: usuarios_tisaleo
-- ============================================================

CREATE DATABASE IF NOT EXISTS usuarios_tisaleo
    CHARACTER SET utf8mb4
    COLLATE utf8mb4_unicode_ci;

USE usuarios_tisaleo;

-- Desactivar temporalmente revisión de claves foráneas para recreación limpia
SET FOREIGN_KEY_CHECKS = 0;
DROP TABLE IF EXISTS auditoria_accesos;
DROP TABLE IF EXISTS usuario_emprendimientos;
DROP TABLE IF EXISTS aceptaciones_terminos;
DROP TABLE IF EXISTS terminos_condiciones;
DROP TABLE IF EXISTS usuarios;
DROP TABLE IF EXISTS emprendimientos;
DROP TABLE IF EXISTS roles;
SET FOREIGN_KEY_CHECKS = 1;

-- ============================================================
-- 1. TABLA: ROLES
-- ============================================================
CREATE TABLE roles (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(50) NOT NULL,
    descripcion VARCHAR(255) NULL,
    fec_creacion TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    fec_actualizacion TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    fec_eliminacion TIMESTAMP NULL DEFAULT NULL,
    UNIQUE KEY uq_roles_nombre (nombre)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================================
-- 2. TABLA: EMPRENDIMIENTOS
-- ============================================================
CREATE TABLE emprendimientos (
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
    usa_productos TINYINT NOT NULL DEFAULT 1,
    usa_servicios TINYINT NOT NULL DEFAULT 1,
    activo TINYINT NOT NULL DEFAULT 1,
    fec_creacion TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    fec_actualizacion TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    fec_eliminacion TIMESTAMP NULL DEFAULT NULL,
    UNIQUE KEY uq_emprendimientos_database_key (database_key),
    INDEX idx_emprendimientos_activo (activo, fec_eliminacion)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================================
-- 3. TABLA: USUARIOS
-- ============================================================
CREATE TABLE usuarios (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    rol_id BIGINT UNSIGNED NOT NULL,
    emprendimiento_id BIGINT UNSIGNED NULL,
    nombre VARCHAR(100) NOT NULL,
    apellido VARCHAR(100) NULL,
    correo VARCHAR(254) NOT NULL,
    telefono VARCHAR(30) NULL,
    password_hash VARCHAR(255) NOT NULL,
    debe_cambiar_clave TINYINT NOT NULL DEFAULT 0,
    activo TINYINT NOT NULL DEFAULT 1,
    ultimo_acceso_at DATETIME NULL,
    fec_creacion TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    fec_actualizacion TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    fec_eliminacion TIMESTAMP NULL DEFAULT NULL,

    UNIQUE KEY uq_usuarios_correo (correo),
    INDEX idx_usuarios_rol (rol_id),
    INDEX idx_usuarios_emprendimiento (emprendimiento_id),
    INDEX idx_usuarios_activo (activo, fec_eliminacion),

    CONSTRAINT fk_usuarios_rol
        FOREIGN KEY (rol_id) REFERENCES roles (id)
        ON UPDATE CASCADE ON DELETE RESTRICT,

    CONSTRAINT fk_usuarios_emprendimiento
        FOREIGN KEY (emprendimiento_id) REFERENCES emprendimientos (id)
        ON UPDATE CASCADE ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================================
-- 4. TABLA: TERMINOS_CONDICIONES
-- ============================================================
CREATE TABLE terminos_condiciones (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    contenido LONGTEXT NOT NULL,
    activo BOOLEAN NOT NULL DEFAULT 0,
    fec_creacion TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    fec_actualizacion TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    fec_eliminacion TIMESTAMP NULL DEFAULT NULL,
    INDEX idx_terminos_activo (activo, fec_eliminacion)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================================
-- 5. TABLA: ACEPTACIONES_TERMINOS
-- ============================================================
CREATE TABLE aceptaciones_terminos (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    usuario_id BIGINT UNSIGNED NOT NULL,
    terminos_condiciones_id BIGINT UNSIGNED NOT NULL,
    aceptado_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    direccion_ip VARCHAR(45) NULL,
    user_agent VARCHAR(500) NULL,
    fec_creacion TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    fec_actualizacion TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    fec_eliminacion TIMESTAMP NULL DEFAULT NULL,

    UNIQUE KEY uq_aceptacion_usuario_terminos (usuario_id, terminos_condiciones_id),
    INDEX idx_aceptaciones_terminos (terminos_condiciones_id),

    CONSTRAINT fk_aceptaciones_usuario
        FOREIGN KEY (usuario_id) REFERENCES usuarios (id)
        ON UPDATE CASCADE ON DELETE RESTRICT,

    CONSTRAINT fk_aceptaciones_terminos
        FOREIGN KEY (terminos_condiciones_id) REFERENCES terminos_condiciones (id)
        ON UPDATE CASCADE ON DELETE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================================
-- 6. TABLA: USUARIO_EMPRENDIMIENTOS
-- ============================================================
CREATE TABLE usuario_emprendimientos (
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

-- ============================================================
-- 7. TABLA: AUDITORIA_ACCESOS
-- ============================================================
CREATE TABLE auditoria_accesos (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    usuario_id BIGINT UNSIGNED NULL,
    emprendimiento_id BIGINT UNSIGNED NULL,
    tipo_evento VARCHAR(50) NOT NULL,
    direccion_ip VARCHAR(45) NULL,
    user_agent VARCHAR(500) NULL,
    detalles TEXT NULL,
    fec_registro TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,

    INDEX idx_auditoria_accesos_usuario (usuario_id),
    INDEX idx_auditoria_accesos_emprendimiento (emprendimiento_id),
    INDEX idx_auditoria_accesos_fec_registro (fec_registro),

    CONSTRAINT fk_auditoria_accesos_usuario
        FOREIGN KEY (usuario_id) REFERENCES usuarios (id)
        ON UPDATE CASCADE ON DELETE SET NULL,

    CONSTRAINT fk_auditoria_accesos_emprendimiento
        FOREIGN KEY (emprendimiento_id) REFERENCES emprendimientos (id)
        ON UPDATE CASCADE ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================================
-- SEED DE DATOS INICIALES
-- ============================================================

-- Roles básicos
INSERT INTO roles (nombre, descripcion)
VALUES
    ('admin', 'Administrador del sistema'),
    ('propietario', 'Propietario de un emprendimiento'),
    ('empleado', 'Empleado de un emprendimiento')
ON DUPLICATE KEY UPDATE descripcion = VALUES(descripcion);