-- ============================================================
-- CREACION COMPLETA DE 26 BASES DE DATOS OPERATIVAS Y USUARIOS
-- PROYECTO: TISALEO EMPRENDE
-- Incluye configuración de bases de datos, usuarios, contraseñas y tablas.
-- ============================================================

-- ================= BASE 1/26: db_emp_calzado_john (Calzado John H. Mateo) =================

-- ============================================================
-- BASE DE DATOS OPERATIVA: db_emp_calzado_john
-- EMPRENDIMIENTO: Calzado John H. Mateo
-- ============================================================
CREATE DATABASE IF NOT EXISTS `db_emp_calzado_john`
    CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE `db_emp_calzado_john`;

-- CREACION DE USUARIO DE BASE DE DATOS Y ASIGNACION DE PERMISOS
CREATE USER IF NOT EXISTS 'emp_calzado_john'@'%' IDENTIFIED BY 'DbPass_calzado1';
GRANT ALL PRIVILEGES ON `db_emp_calzado_john`.* TO 'emp_calzado_john'@'%';
CREATE USER IF NOT EXISTS 'emp_calzado_john'@'localhost' IDENTIFIED BY 'DbPass_calzado1';
GRANT ALL PRIVILEGES ON `db_emp_calzado_john`.* TO 'emp_calzado_john'@'localhost';
FLUSH PRIVILEGES;

SET FOREIGN_KEY_CHECKS = 0;
DROP TABLE IF EXISTS detalle_venta;
DROP TABLE IF EXISTS movimientos_inventario;
DROP TABLE IF EXISTS ventas;
DROP TABLE IF EXISTS productos;
DROP TABLE IF EXISTS servicios;
DROP TABLE IF EXISTS auditoria;
SET FOREIGN_KEY_CHECKS = 1;

CREATE TABLE auditoria (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    usuario_id BIGINT UNSIGNED NULL,
    accion VARCHAR(50) NOT NULL,
    tabla_afectada VARCHAR(100) NOT NULL,
    registro_id BIGINT UNSIGNED NULL,
    valores_anteriores JSON NULL,
    valores_nuevos JSON NULL,
    detalle TEXT NULL,
    direccion_ip VARCHAR(45) NULL,
    fec_creacion TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    fec_actualizacion TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    fec_eliminacion TIMESTAMP NULL DEFAULT NULL,
    INDEX idx_auditoria_usuario (usuario_id),
    INDEX idx_auditoria_tabla_registro (tabla_afectada, registro_id),
    INDEX idx_auditoria_fec_creacion (fec_creacion)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE servicios (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(150) NOT NULL,
    descripcion TEXT NULL,
    precio DECIMAL(10,2) NOT NULL DEFAULT 0.00,
    url_imagen VARCHAR(255) NULL,
    estado VARCHAR(30) NOT NULL DEFAULT 'activo',
    fecha_inicio DATE NULL,
    fecha_fin DATE NULL,
    fec_creacion TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    fec_actualizacion TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    fec_eliminacion TIMESTAMP NULL DEFAULT NULL,
    CONSTRAINT chk_servicios_precio CHECK (precio >= 0),
    CONSTRAINT chk_servicios_fechas CHECK (
        fecha_inicio IS NULL OR fecha_fin IS NULL OR fecha_fin >= fecha_inicio
    ),
    INDEX idx_servicios_nombre (nombre),
    INDEX idx_servicios_estado (estado, fec_eliminacion)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE productos (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    codigo VARCHAR(60) NULL,
    nombre VARCHAR(150) NOT NULL,
    descripcion TEXT NULL,
    cantidad INT NOT NULL DEFAULT 0,
    unidad_medida VARCHAR(50) NOT NULL DEFAULT 'unidad',
    categoria_unidad VARCHAR(100) NULL,
    costo_produccion DECIMAL(10,2) NOT NULL DEFAULT 0.00,
    precio_venta DECIMAL(10,2) NOT NULL DEFAULT 0.00,
    url_imagen VARCHAR(255) NULL,
    activo BOOLEAN NOT NULL DEFAULT TRUE,
    fec_creacion TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    fec_actualizacion TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    fec_eliminacion TIMESTAMP NULL DEFAULT NULL,
    CONSTRAINT chk_productos_costo CHECK (costo_produccion >= 0),
    CONSTRAINT chk_productos_precio_venta CHECK (precio_venta >= 0),
    CONSTRAINT chk_productos_cantidad CHECK (cantidad >= 0),
    UNIQUE KEY uq_productos_codigo (codigo),
    INDEX idx_productos_nombre (nombre),
    INDEX idx_productos_activo (activo, fec_eliminacion)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE ventas (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    fecha_venta DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    estado VARCHAR(30) NOT NULL DEFAULT 'completada',
    metodo_pago VARCHAR(50) NULL,
    subtotal DECIMAL(12,2) NOT NULL DEFAULT 0.00,
    descuento DECIMAL(12,2) NOT NULL DEFAULT 0.00,
    impuesto DECIMAL(12,2) NOT NULL DEFAULT 0.00,
    total DECIMAL(12,2) NOT NULL DEFAULT 0.00,
    observaciones TEXT NULL,
    fec_creacion TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    fec_actualizacion TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    fec_eliminacion TIMESTAMP NULL DEFAULT NULL,
    CONSTRAINT chk_ventas_subtotal CHECK (subtotal >= 0),
    CONSTRAINT chk_ventas_descuento CHECK (descuento >= 0),
    CONSTRAINT chk_ventas_impuesto CHECK (impuesto >= 0),
    CONSTRAINT chk_ventas_total CHECK (total >= 0),
    INDEX idx_ventas_fecha (fec_eliminacion, fecha_venta),
    INDEX idx_ventas_estado (estado)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE detalle_venta (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    venta_id BIGINT UNSIGNED NOT NULL,
    producto_id BIGINT UNSIGNED NULL,
    servicio_id BIGINT UNSIGNED NULL,
    nombre_item VARCHAR(150) NOT NULL,
    cantidad DECIMAL(12,2) NOT NULL DEFAULT 1.00,
    precio_unitario DECIMAL(10,2) NOT NULL DEFAULT 0.00,
    descuento DECIMAL(12,2) NOT NULL DEFAULT 0.00,
    subtotal DECIMAL(12,2) NOT NULL DEFAULT 0.00,
    fec_creacion TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    fec_actualizacion TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    fec_eliminacion TIMESTAMP NULL DEFAULT NULL,
    CONSTRAINT chk_detalle_cantidad CHECK (cantidad > 0),
    CONSTRAINT chk_detalle_precio CHECK (precio_unitario >= 0),
    CONSTRAINT chk_detalle_descuento CHECK (descuento >= 0),
    CONSTRAINT chk_detalle_subtotal CHECK (subtotal >= 0),
    CONSTRAINT fk_detalle_venta_venta FOREIGN KEY (venta_id)
        REFERENCES ventas(id) ON UPDATE CASCADE ON DELETE RESTRICT,
    CONSTRAINT fk_detalle_venta_producto FOREIGN KEY (producto_id)
        REFERENCES productos(id) ON UPDATE CASCADE ON DELETE RESTRICT,
    CONSTRAINT fk_detalle_venta_servicio FOREIGN KEY (servicio_id)
        REFERENCES servicios(id) ON UPDATE CASCADE ON DELETE RESTRICT,
    INDEX idx_detalle_venta (venta_id, fec_eliminacion),
    INDEX idx_detalle_producto (producto_id),
    INDEX idx_detalle_servicio (servicio_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE movimientos_inventario (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    producto_id BIGINT UNSIGNED NOT NULL,
    venta_id BIGINT UNSIGNED NULL,
    tipo VARCHAR(30) NOT NULL,
    cantidad DECIMAL(12,2) NOT NULL,
    motivo VARCHAR(255) NULL,
    fec_creacion TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    fec_actualizacion TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    fec_eliminacion TIMESTAMP NULL DEFAULT NULL,
    CONSTRAINT chk_movimiento_cantidad CHECK (cantidad > 0),
    CONSTRAINT fk_movimientos_producto FOREIGN KEY (producto_id)
        REFERENCES productos(id) ON UPDATE CASCADE ON DELETE RESTRICT,
    CONSTRAINT fk_movimientos_venta FOREIGN KEY (venta_id)
        REFERENCES ventas(id) ON UPDATE CASCADE ON DELETE RESTRICT,
    INDEX idx_movimientos_producto_fecha (producto_id, fec_creacion),
    INDEX idx_movimientos_venta (venta_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ================= BASE 2/26: db_emp_alju (ALJU) =================

-- ============================================================
-- BASE DE DATOS OPERATIVA: db_emp_alju
-- EMPRENDIMIENTO: ALJU
-- ============================================================
CREATE DATABASE IF NOT EXISTS `db_emp_alju`
    CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE `db_emp_alju`;

-- CREACION DE USUARIO DE BASE DE DATOS Y ASIGNACION DE PERMISOS
CREATE USER IF NOT EXISTS 'emp_alju'@'%' IDENTIFIED BY 'DbPass_alju2';
GRANT ALL PRIVILEGES ON `db_emp_alju`.* TO 'emp_alju'@'%';
CREATE USER IF NOT EXISTS 'emp_alju'@'localhost' IDENTIFIED BY 'DbPass_alju2';
GRANT ALL PRIVILEGES ON `db_emp_alju`.* TO 'emp_alju'@'localhost';
FLUSH PRIVILEGES;

SET FOREIGN_KEY_CHECKS = 0;
DROP TABLE IF EXISTS detalle_venta;
DROP TABLE IF EXISTS movimientos_inventario;
DROP TABLE IF EXISTS ventas;
DROP TABLE IF EXISTS productos;
DROP TABLE IF EXISTS servicios;
DROP TABLE IF EXISTS auditoria;
SET FOREIGN_KEY_CHECKS = 1;

CREATE TABLE auditoria (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    usuario_id BIGINT UNSIGNED NULL,
    accion VARCHAR(50) NOT NULL,
    tabla_afectada VARCHAR(100) NOT NULL,
    registro_id BIGINT UNSIGNED NULL,
    valores_anteriores JSON NULL,
    valores_nuevos JSON NULL,
    detalle TEXT NULL,
    direccion_ip VARCHAR(45) NULL,
    fec_creacion TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    fec_actualizacion TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    fec_eliminacion TIMESTAMP NULL DEFAULT NULL,
    INDEX idx_auditoria_usuario (usuario_id),
    INDEX idx_auditoria_tabla_registro (tabla_afectada, registro_id),
    INDEX idx_auditoria_fec_creacion (fec_creacion)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE servicios (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(150) NOT NULL,
    descripcion TEXT NULL,
    precio DECIMAL(10,2) NOT NULL DEFAULT 0.00,
    url_imagen VARCHAR(255) NULL,
    estado VARCHAR(30) NOT NULL DEFAULT 'activo',
    fecha_inicio DATE NULL,
    fecha_fin DATE NULL,
    fec_creacion TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    fec_actualizacion TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    fec_eliminacion TIMESTAMP NULL DEFAULT NULL,
    CONSTRAINT chk_servicios_precio CHECK (precio >= 0),
    CONSTRAINT chk_servicios_fechas CHECK (
        fecha_inicio IS NULL OR fecha_fin IS NULL OR fecha_fin >= fecha_inicio
    ),
    INDEX idx_servicios_nombre (nombre),
    INDEX idx_servicios_estado (estado, fec_eliminacion)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE productos (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    codigo VARCHAR(60) NULL,
    nombre VARCHAR(150) NOT NULL,
    descripcion TEXT NULL,
    cantidad INT NOT NULL DEFAULT 0,
    unidad_medida VARCHAR(50) NOT NULL DEFAULT 'unidad',
    categoria_unidad VARCHAR(100) NULL,
    costo_produccion DECIMAL(10,2) NOT NULL DEFAULT 0.00,
    precio_venta DECIMAL(10,2) NOT NULL DEFAULT 0.00,
    url_imagen VARCHAR(255) NULL,
    activo BOOLEAN NOT NULL DEFAULT TRUE,
    fec_creacion TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    fec_actualizacion TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    fec_eliminacion TIMESTAMP NULL DEFAULT NULL,
    CONSTRAINT chk_productos_costo CHECK (costo_produccion >= 0),
    CONSTRAINT chk_productos_precio_venta CHECK (precio_venta >= 0),
    CONSTRAINT chk_productos_cantidad CHECK (cantidad >= 0),
    UNIQUE KEY uq_productos_codigo (codigo),
    INDEX idx_productos_nombre (nombre),
    INDEX idx_productos_activo (activo, fec_eliminacion)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE ventas (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    fecha_venta DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    estado VARCHAR(30) NOT NULL DEFAULT 'completada',
    metodo_pago VARCHAR(50) NULL,
    subtotal DECIMAL(12,2) NOT NULL DEFAULT 0.00,
    descuento DECIMAL(12,2) NOT NULL DEFAULT 0.00,
    impuesto DECIMAL(12,2) NOT NULL DEFAULT 0.00,
    total DECIMAL(12,2) NOT NULL DEFAULT 0.00,
    observaciones TEXT NULL,
    fec_creacion TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    fec_actualizacion TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    fec_eliminacion TIMESTAMP NULL DEFAULT NULL,
    CONSTRAINT chk_ventas_subtotal CHECK (subtotal >= 0),
    CONSTRAINT chk_ventas_descuento CHECK (descuento >= 0),
    CONSTRAINT chk_ventas_impuesto CHECK (impuesto >= 0),
    CONSTRAINT chk_ventas_total CHECK (total >= 0),
    INDEX idx_ventas_fecha (fec_eliminacion, fecha_venta),
    INDEX idx_ventas_estado (estado)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE detalle_venta (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    venta_id BIGINT UNSIGNED NOT NULL,
    producto_id BIGINT UNSIGNED NULL,
    servicio_id BIGINT UNSIGNED NULL,
    nombre_item VARCHAR(150) NOT NULL,
    cantidad DECIMAL(12,2) NOT NULL DEFAULT 1.00,
    precio_unitario DECIMAL(10,2) NOT NULL DEFAULT 0.00,
    descuento DECIMAL(12,2) NOT NULL DEFAULT 0.00,
    subtotal DECIMAL(12,2) NOT NULL DEFAULT 0.00,
    fec_creacion TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    fec_actualizacion TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    fec_eliminacion TIMESTAMP NULL DEFAULT NULL,
    CONSTRAINT chk_detalle_cantidad CHECK (cantidad > 0),
    CONSTRAINT chk_detalle_precio CHECK (precio_unitario >= 0),
    CONSTRAINT chk_detalle_descuento CHECK (descuento >= 0),
    CONSTRAINT chk_detalle_subtotal CHECK (subtotal >= 0),
    CONSTRAINT fk_detalle_venta_venta FOREIGN KEY (venta_id)
        REFERENCES ventas(id) ON UPDATE CASCADE ON DELETE RESTRICT,
    CONSTRAINT fk_detalle_venta_producto FOREIGN KEY (producto_id)
        REFERENCES productos(id) ON UPDATE CASCADE ON DELETE RESTRICT,
    CONSTRAINT fk_detalle_venta_servicio FOREIGN KEY (servicio_id)
        REFERENCES servicios(id) ON UPDATE CASCADE ON DELETE RESTRICT,
    INDEX idx_detalle_venta (venta_id, fec_eliminacion),
    INDEX idx_detalle_producto (producto_id),
    INDEX idx_detalle_servicio (servicio_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE movimientos_inventario (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    producto_id BIGINT UNSIGNED NOT NULL,
    venta_id BIGINT UNSIGNED NULL,
    tipo VARCHAR(30) NOT NULL,
    cantidad DECIMAL(12,2) NOT NULL,
    motivo VARCHAR(255) NULL,
    fec_creacion TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    fec_actualizacion TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    fec_eliminacion TIMESTAMP NULL DEFAULT NULL,
    CONSTRAINT chk_movimiento_cantidad CHECK (cantidad > 0),
    CONSTRAINT fk_movimientos_producto FOREIGN KEY (producto_id)
        REFERENCES productos(id) ON UPDATE CASCADE ON DELETE RESTRICT,
    CONSTRAINT fk_movimientos_venta FOREIGN KEY (venta_id)
        REFERENCES ventas(id) ON UPDATE CASCADE ON DELETE RESTRICT,
    INDEX idx_movimientos_producto_fecha (producto_id, fec_creacion),
    INDEX idx_movimientos_venta (venta_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ================= BASE 3/26: db_emp_lufeli (Lufeli) =================

-- ============================================================
-- BASE DE DATOS OPERATIVA: db_emp_lufeli
-- EMPRENDIMIENTO: Lufeli
-- ============================================================
CREATE DATABASE IF NOT EXISTS `db_emp_lufeli`
    CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE `db_emp_lufeli`;

-- CREACION DE USUARIO DE BASE DE DATOS Y ASIGNACION DE PERMISOS
CREATE USER IF NOT EXISTS 'emp_lufeli'@'%' IDENTIFIED BY 'DbPass_lufeli3';
GRANT ALL PRIVILEGES ON `db_emp_lufeli`.* TO 'emp_lufeli'@'%';
CREATE USER IF NOT EXISTS 'emp_lufeli'@'localhost' IDENTIFIED BY 'DbPass_lufeli3';
GRANT ALL PRIVILEGES ON `db_emp_lufeli`.* TO 'emp_lufeli'@'localhost';
FLUSH PRIVILEGES;

SET FOREIGN_KEY_CHECKS = 0;
DROP TABLE IF EXISTS detalle_venta;
DROP TABLE IF EXISTS movimientos_inventario;
DROP TABLE IF EXISTS ventas;
DROP TABLE IF EXISTS productos;
DROP TABLE IF EXISTS servicios;
DROP TABLE IF EXISTS auditoria;
SET FOREIGN_KEY_CHECKS = 1;

CREATE TABLE auditoria (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    usuario_id BIGINT UNSIGNED NULL,
    accion VARCHAR(50) NOT NULL,
    tabla_afectada VARCHAR(100) NOT NULL,
    registro_id BIGINT UNSIGNED NULL,
    valores_anteriores JSON NULL,
    valores_nuevos JSON NULL,
    detalle TEXT NULL,
    direccion_ip VARCHAR(45) NULL,
    fec_creacion TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    fec_actualizacion TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    fec_eliminacion TIMESTAMP NULL DEFAULT NULL,
    INDEX idx_auditoria_usuario (usuario_id),
    INDEX idx_auditoria_tabla_registro (tabla_afectada, registro_id),
    INDEX idx_auditoria_fec_creacion (fec_creacion)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE servicios (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(150) NOT NULL,
    descripcion TEXT NULL,
    precio DECIMAL(10,2) NOT NULL DEFAULT 0.00,
    url_imagen VARCHAR(255) NULL,
    estado VARCHAR(30) NOT NULL DEFAULT 'activo',
    fecha_inicio DATE NULL,
    fecha_fin DATE NULL,
    fec_creacion TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    fec_actualizacion TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    fec_eliminacion TIMESTAMP NULL DEFAULT NULL,
    CONSTRAINT chk_servicios_precio CHECK (precio >= 0),
    CONSTRAINT chk_servicios_fechas CHECK (
        fecha_inicio IS NULL OR fecha_fin IS NULL OR fecha_fin >= fecha_inicio
    ),
    INDEX idx_servicios_nombre (nombre),
    INDEX idx_servicios_estado (estado, fec_eliminacion)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE productos (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    codigo VARCHAR(60) NULL,
    nombre VARCHAR(150) NOT NULL,
    descripcion TEXT NULL,
    cantidad INT NOT NULL DEFAULT 0,
    unidad_medida VARCHAR(50) NOT NULL DEFAULT 'unidad',
    categoria_unidad VARCHAR(100) NULL,
    costo_produccion DECIMAL(10,2) NOT NULL DEFAULT 0.00,
    precio_venta DECIMAL(10,2) NOT NULL DEFAULT 0.00,
    url_imagen VARCHAR(255) NULL,
    activo BOOLEAN NOT NULL DEFAULT TRUE,
    fec_creacion TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    fec_actualizacion TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    fec_eliminacion TIMESTAMP NULL DEFAULT NULL,
    CONSTRAINT chk_productos_costo CHECK (costo_produccion >= 0),
    CONSTRAINT chk_productos_precio_venta CHECK (precio_venta >= 0),
    CONSTRAINT chk_productos_cantidad CHECK (cantidad >= 0),
    UNIQUE KEY uq_productos_codigo (codigo),
    INDEX idx_productos_nombre (nombre),
    INDEX idx_productos_activo (activo, fec_eliminacion)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE ventas (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    fecha_venta DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    estado VARCHAR(30) NOT NULL DEFAULT 'completada',
    metodo_pago VARCHAR(50) NULL,
    subtotal DECIMAL(12,2) NOT NULL DEFAULT 0.00,
    descuento DECIMAL(12,2) NOT NULL DEFAULT 0.00,
    impuesto DECIMAL(12,2) NOT NULL DEFAULT 0.00,
    total DECIMAL(12,2) NOT NULL DEFAULT 0.00,
    observaciones TEXT NULL,
    fec_creacion TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    fec_actualizacion TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    fec_eliminacion TIMESTAMP NULL DEFAULT NULL,
    CONSTRAINT chk_ventas_subtotal CHECK (subtotal >= 0),
    CONSTRAINT chk_ventas_descuento CHECK (descuento >= 0),
    CONSTRAINT chk_ventas_impuesto CHECK (impuesto >= 0),
    CONSTRAINT chk_ventas_total CHECK (total >= 0),
    INDEX idx_ventas_fecha (fec_eliminacion, fecha_venta),
    INDEX idx_ventas_estado (estado)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE detalle_venta (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    venta_id BIGINT UNSIGNED NOT NULL,
    producto_id BIGINT UNSIGNED NULL,
    servicio_id BIGINT UNSIGNED NULL,
    nombre_item VARCHAR(150) NOT NULL,
    cantidad DECIMAL(12,2) NOT NULL DEFAULT 1.00,
    precio_unitario DECIMAL(10,2) NOT NULL DEFAULT 0.00,
    descuento DECIMAL(12,2) NOT NULL DEFAULT 0.00,
    subtotal DECIMAL(12,2) NOT NULL DEFAULT 0.00,
    fec_creacion TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    fec_actualizacion TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    fec_eliminacion TIMESTAMP NULL DEFAULT NULL,
    CONSTRAINT chk_detalle_cantidad CHECK (cantidad > 0),
    CONSTRAINT chk_detalle_precio CHECK (precio_unitario >= 0),
    CONSTRAINT chk_detalle_descuento CHECK (descuento >= 0),
    CONSTRAINT chk_detalle_subtotal CHECK (subtotal >= 0),
    CONSTRAINT fk_detalle_venta_venta FOREIGN KEY (venta_id)
        REFERENCES ventas(id) ON UPDATE CASCADE ON DELETE RESTRICT,
    CONSTRAINT fk_detalle_venta_producto FOREIGN KEY (producto_id)
        REFERENCES productos(id) ON UPDATE CASCADE ON DELETE RESTRICT,
    CONSTRAINT fk_detalle_venta_servicio FOREIGN KEY (servicio_id)
        REFERENCES servicios(id) ON UPDATE CASCADE ON DELETE RESTRICT,
    INDEX idx_detalle_venta (venta_id, fec_eliminacion),
    INDEX idx_detalle_producto (producto_id),
    INDEX idx_detalle_servicio (servicio_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE movimientos_inventario (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    producto_id BIGINT UNSIGNED NOT NULL,
    venta_id BIGINT UNSIGNED NULL,
    tipo VARCHAR(30) NOT NULL,
    cantidad DECIMAL(12,2) NOT NULL,
    motivo VARCHAR(255) NULL,
    fec_creacion TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    fec_actualizacion TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    fec_eliminacion TIMESTAMP NULL DEFAULT NULL,
    CONSTRAINT chk_movimiento_cantidad CHECK (cantidad > 0),
    CONSTRAINT fk_movimientos_producto FOREIGN KEY (producto_id)
        REFERENCES productos(id) ON UPDATE CASCADE ON DELETE RESTRICT,
    CONSTRAINT fk_movimientos_venta FOREIGN KEY (venta_id)
        REFERENCES ventas(id) ON UPDATE CASCADE ON DELETE RESTRICT,
    INDEX idx_movimientos_producto_fecha (producto_id, fec_creacion),
    INDEX idx_movimientos_venta (venta_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ================= BASE 4/26: db_emp_helados_golositos (Helados Golositos) =================

-- ============================================================
-- BASE DE DATOS OPERATIVA: db_emp_helados_golositos
-- EMPRENDIMIENTO: Helados Golositos
-- ============================================================
CREATE DATABASE IF NOT EXISTS `db_emp_helados_golositos`
    CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE `db_emp_helados_golositos`;

-- CREACION DE USUARIO DE BASE DE DATOS Y ASIGNACION DE PERMISOS
CREATE USER IF NOT EXISTS 'emp_helados_golositos'@'%' IDENTIFIED BY 'DbPass_helados4';
GRANT ALL PRIVILEGES ON `db_emp_helados_golositos`.* TO 'emp_helados_golositos'@'%';
CREATE USER IF NOT EXISTS 'emp_helados_golositos'@'localhost' IDENTIFIED BY 'DbPass_helados4';
GRANT ALL PRIVILEGES ON `db_emp_helados_golositos`.* TO 'emp_helados_golositos'@'localhost';
FLUSH PRIVILEGES;

SET FOREIGN_KEY_CHECKS = 0;
DROP TABLE IF EXISTS detalle_venta;
DROP TABLE IF EXISTS movimientos_inventario;
DROP TABLE IF EXISTS ventas;
DROP TABLE IF EXISTS productos;
DROP TABLE IF EXISTS servicios;
DROP TABLE IF EXISTS auditoria;
SET FOREIGN_KEY_CHECKS = 1;

CREATE TABLE auditoria (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    usuario_id BIGINT UNSIGNED NULL,
    accion VARCHAR(50) NOT NULL,
    tabla_afectada VARCHAR(100) NOT NULL,
    registro_id BIGINT UNSIGNED NULL,
    valores_anteriores JSON NULL,
    valores_nuevos JSON NULL,
    detalle TEXT NULL,
    direccion_ip VARCHAR(45) NULL,
    fec_creacion TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    fec_actualizacion TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    fec_eliminacion TIMESTAMP NULL DEFAULT NULL,
    INDEX idx_auditoria_usuario (usuario_id),
    INDEX idx_auditoria_tabla_registro (tabla_afectada, registro_id),
    INDEX idx_auditoria_fec_creacion (fec_creacion)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE servicios (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(150) NOT NULL,
    descripcion TEXT NULL,
    precio DECIMAL(10,2) NOT NULL DEFAULT 0.00,
    url_imagen VARCHAR(255) NULL,
    estado VARCHAR(30) NOT NULL DEFAULT 'activo',
    fecha_inicio DATE NULL,
    fecha_fin DATE NULL,
    fec_creacion TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    fec_actualizacion TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    fec_eliminacion TIMESTAMP NULL DEFAULT NULL,
    CONSTRAINT chk_servicios_precio CHECK (precio >= 0),
    CONSTRAINT chk_servicios_fechas CHECK (
        fecha_inicio IS NULL OR fecha_fin IS NULL OR fecha_fin >= fecha_inicio
    ),
    INDEX idx_servicios_nombre (nombre),
    INDEX idx_servicios_estado (estado, fec_eliminacion)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE productos (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    codigo VARCHAR(60) NULL,
    nombre VARCHAR(150) NOT NULL,
    descripcion TEXT NULL,
    cantidad INT NOT NULL DEFAULT 0,
    unidad_medida VARCHAR(50) NOT NULL DEFAULT 'unidad',
    categoria_unidad VARCHAR(100) NULL,
    costo_produccion DECIMAL(10,2) NOT NULL DEFAULT 0.00,
    precio_venta DECIMAL(10,2) NOT NULL DEFAULT 0.00,
    url_imagen VARCHAR(255) NULL,
    activo BOOLEAN NOT NULL DEFAULT TRUE,
    fec_creacion TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    fec_actualizacion TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    fec_eliminacion TIMESTAMP NULL DEFAULT NULL,
    CONSTRAINT chk_productos_costo CHECK (costo_produccion >= 0),
    CONSTRAINT chk_productos_precio_venta CHECK (precio_venta >= 0),
    CONSTRAINT chk_productos_cantidad CHECK (cantidad >= 0),
    UNIQUE KEY uq_productos_codigo (codigo),
    INDEX idx_productos_nombre (nombre),
    INDEX idx_productos_activo (activo, fec_eliminacion)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE ventas (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    fecha_venta DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    estado VARCHAR(30) NOT NULL DEFAULT 'completada',
    metodo_pago VARCHAR(50) NULL,
    subtotal DECIMAL(12,2) NOT NULL DEFAULT 0.00,
    descuento DECIMAL(12,2) NOT NULL DEFAULT 0.00,
    impuesto DECIMAL(12,2) NOT NULL DEFAULT 0.00,
    total DECIMAL(12,2) NOT NULL DEFAULT 0.00,
    observaciones TEXT NULL,
    fec_creacion TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    fec_actualizacion TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    fec_eliminacion TIMESTAMP NULL DEFAULT NULL,
    CONSTRAINT chk_ventas_subtotal CHECK (subtotal >= 0),
    CONSTRAINT chk_ventas_descuento CHECK (descuento >= 0),
    CONSTRAINT chk_ventas_impuesto CHECK (impuesto >= 0),
    CONSTRAINT chk_ventas_total CHECK (total >= 0),
    INDEX idx_ventas_fecha (fec_eliminacion, fecha_venta),
    INDEX idx_ventas_estado (estado)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE detalle_venta (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    venta_id BIGINT UNSIGNED NOT NULL,
    producto_id BIGINT UNSIGNED NULL,
    servicio_id BIGINT UNSIGNED NULL,
    nombre_item VARCHAR(150) NOT NULL,
    cantidad DECIMAL(12,2) NOT NULL DEFAULT 1.00,
    precio_unitario DECIMAL(10,2) NOT NULL DEFAULT 0.00,
    descuento DECIMAL(12,2) NOT NULL DEFAULT 0.00,
    subtotal DECIMAL(12,2) NOT NULL DEFAULT 0.00,
    fec_creacion TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    fec_actualizacion TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    fec_eliminacion TIMESTAMP NULL DEFAULT NULL,
    CONSTRAINT chk_detalle_cantidad CHECK (cantidad > 0),
    CONSTRAINT chk_detalle_precio CHECK (precio_unitario >= 0),
    CONSTRAINT chk_detalle_descuento CHECK (descuento >= 0),
    CONSTRAINT chk_detalle_subtotal CHECK (subtotal >= 0),
    CONSTRAINT fk_detalle_venta_venta FOREIGN KEY (venta_id)
        REFERENCES ventas(id) ON UPDATE CASCADE ON DELETE RESTRICT,
    CONSTRAINT fk_detalle_venta_producto FOREIGN KEY (producto_id)
        REFERENCES productos(id) ON UPDATE CASCADE ON DELETE RESTRICT,
    CONSTRAINT fk_detalle_venta_servicio FOREIGN KEY (servicio_id)
        REFERENCES servicios(id) ON UPDATE CASCADE ON DELETE RESTRICT,
    INDEX idx_detalle_venta (venta_id, fec_eliminacion),
    INDEX idx_detalle_producto (producto_id),
    INDEX idx_detalle_servicio (servicio_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE movimientos_inventario (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    producto_id BIGINT UNSIGNED NOT NULL,
    venta_id BIGINT UNSIGNED NULL,
    tipo VARCHAR(30) NOT NULL,
    cantidad DECIMAL(12,2) NOT NULL,
    motivo VARCHAR(255) NULL,
    fec_creacion TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    fec_actualizacion TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    fec_eliminacion TIMESTAMP NULL DEFAULT NULL,
    CONSTRAINT chk_movimiento_cantidad CHECK (cantidad > 0),
    CONSTRAINT fk_movimientos_producto FOREIGN KEY (producto_id)
        REFERENCES productos(id) ON UPDATE CASCADE ON DELETE RESTRICT,
    CONSTRAINT fk_movimientos_venta FOREIGN KEY (venta_id)
        REFERENCES ventas(id) ON UPDATE CASCADE ON DELETE RESTRICT,
    INDEX idx_movimientos_producto_fecha (producto_id, fec_creacion),
    INDEX idx_movimientos_venta (venta_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ================= BASE 5/26: db_emp_heladeria_karito (Heladería Karito) =================

-- ============================================================
-- BASE DE DATOS OPERATIVA: db_emp_heladeria_karito
-- EMPRENDIMIENTO: Heladería Karito
-- ============================================================
CREATE DATABASE IF NOT EXISTS `db_emp_heladeria_karito`
    CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE `db_emp_heladeria_karito`;

-- CREACION DE USUARIO DE BASE DE DATOS Y ASIGNACION DE PERMISOS
CREATE USER IF NOT EXISTS 'emp_heladeria_karito'@'%' IDENTIFIED BY 'DbPass_heladeria5';
GRANT ALL PRIVILEGES ON `db_emp_heladeria_karito`.* TO 'emp_heladeria_karito'@'%';
CREATE USER IF NOT EXISTS 'emp_heladeria_karito'@'localhost' IDENTIFIED BY 'DbPass_heladeria5';
GRANT ALL PRIVILEGES ON `db_emp_heladeria_karito`.* TO 'emp_heladeria_karito'@'localhost';
FLUSH PRIVILEGES;

SET FOREIGN_KEY_CHECKS = 0;
DROP TABLE IF EXISTS detalle_venta;
DROP TABLE IF EXISTS movimientos_inventario;
DROP TABLE IF EXISTS ventas;
DROP TABLE IF EXISTS productos;
DROP TABLE IF EXISTS servicios;
DROP TABLE IF EXISTS auditoria;
SET FOREIGN_KEY_CHECKS = 1;

CREATE TABLE auditoria (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    usuario_id BIGINT UNSIGNED NULL,
    accion VARCHAR(50) NOT NULL,
    tabla_afectada VARCHAR(100) NOT NULL,
    registro_id BIGINT UNSIGNED NULL,
    valores_anteriores JSON NULL,
    valores_nuevos JSON NULL,
    detalle TEXT NULL,
    direccion_ip VARCHAR(45) NULL,
    fec_creacion TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    fec_actualizacion TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    fec_eliminacion TIMESTAMP NULL DEFAULT NULL,
    INDEX idx_auditoria_usuario (usuario_id),
    INDEX idx_auditoria_tabla_registro (tabla_afectada, registro_id),
    INDEX idx_auditoria_fec_creacion (fec_creacion)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE servicios (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(150) NOT NULL,
    descripcion TEXT NULL,
    precio DECIMAL(10,2) NOT NULL DEFAULT 0.00,
    url_imagen VARCHAR(255) NULL,
    estado VARCHAR(30) NOT NULL DEFAULT 'activo',
    fecha_inicio DATE NULL,
    fecha_fin DATE NULL,
    fec_creacion TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    fec_actualizacion TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    fec_eliminacion TIMESTAMP NULL DEFAULT NULL,
    CONSTRAINT chk_servicios_precio CHECK (precio >= 0),
    CONSTRAINT chk_servicios_fechas CHECK (
        fecha_inicio IS NULL OR fecha_fin IS NULL OR fecha_fin >= fecha_inicio
    ),
    INDEX idx_servicios_nombre (nombre),
    INDEX idx_servicios_estado (estado, fec_eliminacion)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE productos (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    codigo VARCHAR(60) NULL,
    nombre VARCHAR(150) NOT NULL,
    descripcion TEXT NULL,
    cantidad INT NOT NULL DEFAULT 0,
    unidad_medida VARCHAR(50) NOT NULL DEFAULT 'unidad',
    categoria_unidad VARCHAR(100) NULL,
    costo_produccion DECIMAL(10,2) NOT NULL DEFAULT 0.00,
    precio_venta DECIMAL(10,2) NOT NULL DEFAULT 0.00,
    url_imagen VARCHAR(255) NULL,
    activo BOOLEAN NOT NULL DEFAULT TRUE,
    fec_creacion TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    fec_actualizacion TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    fec_eliminacion TIMESTAMP NULL DEFAULT NULL,
    CONSTRAINT chk_productos_costo CHECK (costo_produccion >= 0),
    CONSTRAINT chk_productos_precio_venta CHECK (precio_venta >= 0),
    CONSTRAINT chk_productos_cantidad CHECK (cantidad >= 0),
    UNIQUE KEY uq_productos_codigo (codigo),
    INDEX idx_productos_nombre (nombre),
    INDEX idx_productos_activo (activo, fec_eliminacion)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE ventas (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    fecha_venta DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    estado VARCHAR(30) NOT NULL DEFAULT 'completada',
    metodo_pago VARCHAR(50) NULL,
    subtotal DECIMAL(12,2) NOT NULL DEFAULT 0.00,
    descuento DECIMAL(12,2) NOT NULL DEFAULT 0.00,
    impuesto DECIMAL(12,2) NOT NULL DEFAULT 0.00,
    total DECIMAL(12,2) NOT NULL DEFAULT 0.00,
    observaciones TEXT NULL,
    fec_creacion TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    fec_actualizacion TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    fec_eliminacion TIMESTAMP NULL DEFAULT NULL,
    CONSTRAINT chk_ventas_subtotal CHECK (subtotal >= 0),
    CONSTRAINT chk_ventas_descuento CHECK (descuento >= 0),
    CONSTRAINT chk_ventas_impuesto CHECK (impuesto >= 0),
    CONSTRAINT chk_ventas_total CHECK (total >= 0),
    INDEX idx_ventas_fecha (fec_eliminacion, fecha_venta),
    INDEX idx_ventas_estado (estado)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE detalle_venta (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    venta_id BIGINT UNSIGNED NOT NULL,
    producto_id BIGINT UNSIGNED NULL,
    servicio_id BIGINT UNSIGNED NULL,
    nombre_item VARCHAR(150) NOT NULL,
    cantidad DECIMAL(12,2) NOT NULL DEFAULT 1.00,
    precio_unitario DECIMAL(10,2) NOT NULL DEFAULT 0.00,
    descuento DECIMAL(12,2) NOT NULL DEFAULT 0.00,
    subtotal DECIMAL(12,2) NOT NULL DEFAULT 0.00,
    fec_creacion TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    fec_actualizacion TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    fec_eliminacion TIMESTAMP NULL DEFAULT NULL,
    CONSTRAINT chk_detalle_cantidad CHECK (cantidad > 0),
    CONSTRAINT chk_detalle_precio CHECK (precio_unitario >= 0),
    CONSTRAINT chk_detalle_descuento CHECK (descuento >= 0),
    CONSTRAINT chk_detalle_subtotal CHECK (subtotal >= 0),
    CONSTRAINT fk_detalle_venta_venta FOREIGN KEY (venta_id)
        REFERENCES ventas(id) ON UPDATE CASCADE ON DELETE RESTRICT,
    CONSTRAINT fk_detalle_venta_producto FOREIGN KEY (producto_id)
        REFERENCES productos(id) ON UPDATE CASCADE ON DELETE RESTRICT,
    CONSTRAINT fk_detalle_venta_servicio FOREIGN KEY (servicio_id)
        REFERENCES servicios(id) ON UPDATE CASCADE ON DELETE RESTRICT,
    INDEX idx_detalle_venta (venta_id, fec_eliminacion),
    INDEX idx_detalle_producto (producto_id),
    INDEX idx_detalle_servicio (servicio_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE movimientos_inventario (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    producto_id BIGINT UNSIGNED NOT NULL,
    venta_id BIGINT UNSIGNED NULL,
    tipo VARCHAR(30) NOT NULL,
    cantidad DECIMAL(12,2) NOT NULL,
    motivo VARCHAR(255) NULL,
    fec_creacion TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    fec_actualizacion TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    fec_eliminacion TIMESTAMP NULL DEFAULT NULL,
    CONSTRAINT chk_movimiento_cantidad CHECK (cantidad > 0),
    CONSTRAINT fk_movimientos_producto FOREIGN KEY (producto_id)
        REFERENCES productos(id) ON UPDATE CASCADE ON DELETE RESTRICT,
    CONSTRAINT fk_movimientos_venta FOREIGN KEY (venta_id)
        REFERENCES ventas(id) ON UPDATE CASCADE ON DELETE RESTRICT,
    INDEX idx_movimientos_producto_fecha (producto_id, fec_creacion),
    INDEX idx_movimientos_venta (venta_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ================= BASE 6/26: db_emp_conos_kelvin (Conos Kelvin) =================

-- ============================================================
-- BASE DE DATOS OPERATIVA: db_emp_conos_kelvin
-- EMPRENDIMIENTO: Conos Kelvin
-- ============================================================
CREATE DATABASE IF NOT EXISTS `db_emp_conos_kelvin`
    CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE `db_emp_conos_kelvin`;

-- CREACION DE USUARIO DE BASE DE DATOS Y ASIGNACION DE PERMISOS
CREATE USER IF NOT EXISTS 'emp_conos_kelvin'@'%' IDENTIFIED BY 'DbPass_conos6';
GRANT ALL PRIVILEGES ON `db_emp_conos_kelvin`.* TO 'emp_conos_kelvin'@'%';
CREATE USER IF NOT EXISTS 'emp_conos_kelvin'@'localhost' IDENTIFIED BY 'DbPass_conos6';
GRANT ALL PRIVILEGES ON `db_emp_conos_kelvin`.* TO 'emp_conos_kelvin'@'localhost';
FLUSH PRIVILEGES;

SET FOREIGN_KEY_CHECKS = 0;
DROP TABLE IF EXISTS detalle_venta;
DROP TABLE IF EXISTS movimientos_inventario;
DROP TABLE IF EXISTS ventas;
DROP TABLE IF EXISTS productos;
DROP TABLE IF EXISTS servicios;
DROP TABLE IF EXISTS auditoria;
SET FOREIGN_KEY_CHECKS = 1;

CREATE TABLE auditoria (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    usuario_id BIGINT UNSIGNED NULL,
    accion VARCHAR(50) NOT NULL,
    tabla_afectada VARCHAR(100) NOT NULL,
    registro_id BIGINT UNSIGNED NULL,
    valores_anteriores JSON NULL,
    valores_nuevos JSON NULL,
    detalle TEXT NULL,
    direccion_ip VARCHAR(45) NULL,
    fec_creacion TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    fec_actualizacion TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    fec_eliminacion TIMESTAMP NULL DEFAULT NULL,
    INDEX idx_auditoria_usuario (usuario_id),
    INDEX idx_auditoria_tabla_registro (tabla_afectada, registro_id),
    INDEX idx_auditoria_fec_creacion (fec_creacion)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE servicios (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(150) NOT NULL,
    descripcion TEXT NULL,
    precio DECIMAL(10,2) NOT NULL DEFAULT 0.00,
    url_imagen VARCHAR(255) NULL,
    estado VARCHAR(30) NOT NULL DEFAULT 'activo',
    fecha_inicio DATE NULL,
    fecha_fin DATE NULL,
    fec_creacion TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    fec_actualizacion TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    fec_eliminacion TIMESTAMP NULL DEFAULT NULL,
    CONSTRAINT chk_servicios_precio CHECK (precio >= 0),
    CONSTRAINT chk_servicios_fechas CHECK (
        fecha_inicio IS NULL OR fecha_fin IS NULL OR fecha_fin >= fecha_inicio
    ),
    INDEX idx_servicios_nombre (nombre),
    INDEX idx_servicios_estado (estado, fec_eliminacion)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE productos (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    codigo VARCHAR(60) NULL,
    nombre VARCHAR(150) NOT NULL,
    descripcion TEXT NULL,
    cantidad INT NOT NULL DEFAULT 0,
    unidad_medida VARCHAR(50) NOT NULL DEFAULT 'unidad',
    categoria_unidad VARCHAR(100) NULL,
    costo_produccion DECIMAL(10,2) NOT NULL DEFAULT 0.00,
    precio_venta DECIMAL(10,2) NOT NULL DEFAULT 0.00,
    url_imagen VARCHAR(255) NULL,
    activo BOOLEAN NOT NULL DEFAULT TRUE,
    fec_creacion TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    fec_actualizacion TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    fec_eliminacion TIMESTAMP NULL DEFAULT NULL,
    CONSTRAINT chk_productos_costo CHECK (costo_produccion >= 0),
    CONSTRAINT chk_productos_precio_venta CHECK (precio_venta >= 0),
    CONSTRAINT chk_productos_cantidad CHECK (cantidad >= 0),
    UNIQUE KEY uq_productos_codigo (codigo),
    INDEX idx_productos_nombre (nombre),
    INDEX idx_productos_activo (activo, fec_eliminacion)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE ventas (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    fecha_venta DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    estado VARCHAR(30) NOT NULL DEFAULT 'completada',
    metodo_pago VARCHAR(50) NULL,
    subtotal DECIMAL(12,2) NOT NULL DEFAULT 0.00,
    descuento DECIMAL(12,2) NOT NULL DEFAULT 0.00,
    impuesto DECIMAL(12,2) NOT NULL DEFAULT 0.00,
    total DECIMAL(12,2) NOT NULL DEFAULT 0.00,
    observaciones TEXT NULL,
    fec_creacion TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    fec_actualizacion TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    fec_eliminacion TIMESTAMP NULL DEFAULT NULL,
    CONSTRAINT chk_ventas_subtotal CHECK (subtotal >= 0),
    CONSTRAINT chk_ventas_descuento CHECK (descuento >= 0),
    CONSTRAINT chk_ventas_impuesto CHECK (impuesto >= 0),
    CONSTRAINT chk_ventas_total CHECK (total >= 0),
    INDEX idx_ventas_fecha (fec_eliminacion, fecha_venta),
    INDEX idx_ventas_estado (estado)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE detalle_venta (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    venta_id BIGINT UNSIGNED NOT NULL,
    producto_id BIGINT UNSIGNED NULL,
    servicio_id BIGINT UNSIGNED NULL,
    nombre_item VARCHAR(150) NOT NULL,
    cantidad DECIMAL(12,2) NOT NULL DEFAULT 1.00,
    precio_unitario DECIMAL(10,2) NOT NULL DEFAULT 0.00,
    descuento DECIMAL(12,2) NOT NULL DEFAULT 0.00,
    subtotal DECIMAL(12,2) NOT NULL DEFAULT 0.00,
    fec_creacion TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    fec_actualizacion TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    fec_eliminacion TIMESTAMP NULL DEFAULT NULL,
    CONSTRAINT chk_detalle_cantidad CHECK (cantidad > 0),
    CONSTRAINT chk_detalle_precio CHECK (precio_unitario >= 0),
    CONSTRAINT chk_detalle_descuento CHECK (descuento >= 0),
    CONSTRAINT chk_detalle_subtotal CHECK (subtotal >= 0),
    CONSTRAINT fk_detalle_venta_venta FOREIGN KEY (venta_id)
        REFERENCES ventas(id) ON UPDATE CASCADE ON DELETE RESTRICT,
    CONSTRAINT fk_detalle_venta_producto FOREIGN KEY (producto_id)
        REFERENCES productos(id) ON UPDATE CASCADE ON DELETE RESTRICT,
    CONSTRAINT fk_detalle_venta_servicio FOREIGN KEY (servicio_id)
        REFERENCES servicios(id) ON UPDATE CASCADE ON DELETE RESTRICT,
    INDEX idx_detalle_venta (venta_id, fec_eliminacion),
    INDEX idx_detalle_producto (producto_id),
    INDEX idx_detalle_servicio (servicio_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE movimientos_inventario (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    producto_id BIGINT UNSIGNED NOT NULL,
    venta_id BIGINT UNSIGNED NULL,
    tipo VARCHAR(30) NOT NULL,
    cantidad DECIMAL(12,2) NOT NULL,
    motivo VARCHAR(255) NULL,
    fec_creacion TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    fec_actualizacion TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    fec_eliminacion TIMESTAMP NULL DEFAULT NULL,
    CONSTRAINT chk_movimiento_cantidad CHECK (cantidad > 0),
    CONSTRAINT fk_movimientos_producto FOREIGN KEY (producto_id)
        REFERENCES productos(id) ON UPDATE CASCADE ON DELETE RESTRICT,
    CONSTRAINT fk_movimientos_venta FOREIGN KEY (venta_id)
        REFERENCES ventas(id) ON UPDATE CASCADE ON DELETE RESTRICT,
    INDEX idx_movimientos_producto_fecha (producto_id, fec_creacion),
    INDEX idx_movimientos_venta (venta_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ================= BASE 7/26: db_emp_turrones_don_goyo (Turrones- Don Goyo) =================

-- ============================================================
-- BASE DE DATOS OPERATIVA: db_emp_turrones_don_goyo
-- EMPRENDIMIENTO: Turrones- Don Goyo
-- ============================================================
CREATE DATABASE IF NOT EXISTS `db_emp_turrones_don_goyo`
    CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE `db_emp_turrones_don_goyo`;

-- CREACION DE USUARIO DE BASE DE DATOS Y ASIGNACION DE PERMISOS
CREATE USER IF NOT EXISTS 'emp_turrones_don_goyo'@'%' IDENTIFIED BY 'DbPass_turrones7';
GRANT ALL PRIVILEGES ON `db_emp_turrones_don_goyo`.* TO 'emp_turrones_don_goyo'@'%';
CREATE USER IF NOT EXISTS 'emp_turrones_don_goyo'@'localhost' IDENTIFIED BY 'DbPass_turrones7';
GRANT ALL PRIVILEGES ON `db_emp_turrones_don_goyo`.* TO 'emp_turrones_don_goyo'@'localhost';
FLUSH PRIVILEGES;

SET FOREIGN_KEY_CHECKS = 0;
DROP TABLE IF EXISTS detalle_venta;
DROP TABLE IF EXISTS movimientos_inventario;
DROP TABLE IF EXISTS ventas;
DROP TABLE IF EXISTS productos;
DROP TABLE IF EXISTS servicios;
DROP TABLE IF EXISTS auditoria;
SET FOREIGN_KEY_CHECKS = 1;

CREATE TABLE auditoria (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    usuario_id BIGINT UNSIGNED NULL,
    accion VARCHAR(50) NOT NULL,
    tabla_afectada VARCHAR(100) NOT NULL,
    registro_id BIGINT UNSIGNED NULL,
    valores_anteriores JSON NULL,
    valores_nuevos JSON NULL,
    detalle TEXT NULL,
    direccion_ip VARCHAR(45) NULL,
    fec_creacion TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    fec_actualizacion TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    fec_eliminacion TIMESTAMP NULL DEFAULT NULL,
    INDEX idx_auditoria_usuario (usuario_id),
    INDEX idx_auditoria_tabla_registro (tabla_afectada, registro_id),
    INDEX idx_auditoria_fec_creacion (fec_creacion)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE servicios (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(150) NOT NULL,
    descripcion TEXT NULL,
    precio DECIMAL(10,2) NOT NULL DEFAULT 0.00,
    url_imagen VARCHAR(255) NULL,
    estado VARCHAR(30) NOT NULL DEFAULT 'activo',
    fecha_inicio DATE NULL,
    fecha_fin DATE NULL,
    fec_creacion TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    fec_actualizacion TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    fec_eliminacion TIMESTAMP NULL DEFAULT NULL,
    CONSTRAINT chk_servicios_precio CHECK (precio >= 0),
    CONSTRAINT chk_servicios_fechas CHECK (
        fecha_inicio IS NULL OR fecha_fin IS NULL OR fecha_fin >= fecha_inicio
    ),
    INDEX idx_servicios_nombre (nombre),
    INDEX idx_servicios_estado (estado, fec_eliminacion)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE productos (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    codigo VARCHAR(60) NULL,
    nombre VARCHAR(150) NOT NULL,
    descripcion TEXT NULL,
    cantidad INT NOT NULL DEFAULT 0,
    unidad_medida VARCHAR(50) NOT NULL DEFAULT 'unidad',
    categoria_unidad VARCHAR(100) NULL,
    costo_produccion DECIMAL(10,2) NOT NULL DEFAULT 0.00,
    precio_venta DECIMAL(10,2) NOT NULL DEFAULT 0.00,
    url_imagen VARCHAR(255) NULL,
    activo BOOLEAN NOT NULL DEFAULT TRUE,
    fec_creacion TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    fec_actualizacion TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    fec_eliminacion TIMESTAMP NULL DEFAULT NULL,
    CONSTRAINT chk_productos_costo CHECK (costo_produccion >= 0),
    CONSTRAINT chk_productos_precio_venta CHECK (precio_venta >= 0),
    CONSTRAINT chk_productos_cantidad CHECK (cantidad >= 0),
    UNIQUE KEY uq_productos_codigo (codigo),
    INDEX idx_productos_nombre (nombre),
    INDEX idx_productos_activo (activo, fec_eliminacion)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE ventas (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    fecha_venta DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    estado VARCHAR(30) NOT NULL DEFAULT 'completada',
    metodo_pago VARCHAR(50) NULL,
    subtotal DECIMAL(12,2) NOT NULL DEFAULT 0.00,
    descuento DECIMAL(12,2) NOT NULL DEFAULT 0.00,
    impuesto DECIMAL(12,2) NOT NULL DEFAULT 0.00,
    total DECIMAL(12,2) NOT NULL DEFAULT 0.00,
    observaciones TEXT NULL,
    fec_creacion TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    fec_actualizacion TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    fec_eliminacion TIMESTAMP NULL DEFAULT NULL,
    CONSTRAINT chk_ventas_subtotal CHECK (subtotal >= 0),
    CONSTRAINT chk_ventas_descuento CHECK (descuento >= 0),
    CONSTRAINT chk_ventas_impuesto CHECK (impuesto >= 0),
    CONSTRAINT chk_ventas_total CHECK (total >= 0),
    INDEX idx_ventas_fecha (fec_eliminacion, fecha_venta),
    INDEX idx_ventas_estado (estado)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE detalle_venta (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    venta_id BIGINT UNSIGNED NOT NULL,
    producto_id BIGINT UNSIGNED NULL,
    servicio_id BIGINT UNSIGNED NULL,
    nombre_item VARCHAR(150) NOT NULL,
    cantidad DECIMAL(12,2) NOT NULL DEFAULT 1.00,
    precio_unitario DECIMAL(10,2) NOT NULL DEFAULT 0.00,
    descuento DECIMAL(12,2) NOT NULL DEFAULT 0.00,
    subtotal DECIMAL(12,2) NOT NULL DEFAULT 0.00,
    fec_creacion TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    fec_actualizacion TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    fec_eliminacion TIMESTAMP NULL DEFAULT NULL,
    CONSTRAINT chk_detalle_cantidad CHECK (cantidad > 0),
    CONSTRAINT chk_detalle_precio CHECK (precio_unitario >= 0),
    CONSTRAINT chk_detalle_descuento CHECK (descuento >= 0),
    CONSTRAINT chk_detalle_subtotal CHECK (subtotal >= 0),
    CONSTRAINT fk_detalle_venta_venta FOREIGN KEY (venta_id)
        REFERENCES ventas(id) ON UPDATE CASCADE ON DELETE RESTRICT,
    CONSTRAINT fk_detalle_venta_producto FOREIGN KEY (producto_id)
        REFERENCES productos(id) ON UPDATE CASCADE ON DELETE RESTRICT,
    CONSTRAINT fk_detalle_venta_servicio FOREIGN KEY (servicio_id)
        REFERENCES servicios(id) ON UPDATE CASCADE ON DELETE RESTRICT,
    INDEX idx_detalle_venta (venta_id, fec_eliminacion),
    INDEX idx_detalle_producto (producto_id),
    INDEX idx_detalle_servicio (servicio_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE movimientos_inventario (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    producto_id BIGINT UNSIGNED NOT NULL,
    venta_id BIGINT UNSIGNED NULL,
    tipo VARCHAR(30) NOT NULL,
    cantidad DECIMAL(12,2) NOT NULL,
    motivo VARCHAR(255) NULL,
    fec_creacion TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    fec_actualizacion TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    fec_eliminacion TIMESTAMP NULL DEFAULT NULL,
    CONSTRAINT chk_movimiento_cantidad CHECK (cantidad > 0),
    CONSTRAINT fk_movimientos_producto FOREIGN KEY (producto_id)
        REFERENCES productos(id) ON UPDATE CASCADE ON DELETE RESTRICT,
    CONSTRAINT fk_movimientos_venta FOREIGN KEY (venta_id)
        REFERENCES ventas(id) ON UPDATE CASCADE ON DELETE RESTRICT,
    INDEX idx_movimientos_producto_fecha (producto_id, fec_creacion),
    INDEX idx_movimientos_venta (venta_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ================= BASE 8/26: db_emp_razu_corp (Razu - Corp) =================

-- ============================================================
-- BASE DE DATOS OPERATIVA: db_emp_razu_corp
-- EMPRENDIMIENTO: Razu - Corp
-- ============================================================
CREATE DATABASE IF NOT EXISTS `db_emp_razu_corp`
    CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE `db_emp_razu_corp`;

-- CREACION DE USUARIO DE BASE DE DATOS Y ASIGNACION DE PERMISOS
CREATE USER IF NOT EXISTS 'emp_razu_corp'@'%' IDENTIFIED BY 'DbPass_razu8';
GRANT ALL PRIVILEGES ON `db_emp_razu_corp`.* TO 'emp_razu_corp'@'%';
CREATE USER IF NOT EXISTS 'emp_razu_corp'@'localhost' IDENTIFIED BY 'DbPass_razu8';
GRANT ALL PRIVILEGES ON `db_emp_razu_corp`.* TO 'emp_razu_corp'@'localhost';
FLUSH PRIVILEGES;

SET FOREIGN_KEY_CHECKS = 0;
DROP TABLE IF EXISTS detalle_venta;
DROP TABLE IF EXISTS movimientos_inventario;
DROP TABLE IF EXISTS ventas;
DROP TABLE IF EXISTS productos;
DROP TABLE IF EXISTS servicios;
DROP TABLE IF EXISTS auditoria;
SET FOREIGN_KEY_CHECKS = 1;

CREATE TABLE auditoria (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    usuario_id BIGINT UNSIGNED NULL,
    accion VARCHAR(50) NOT NULL,
    tabla_afectada VARCHAR(100) NOT NULL,
    registro_id BIGINT UNSIGNED NULL,
    valores_anteriores JSON NULL,
    valores_nuevos JSON NULL,
    detalle TEXT NULL,
    direccion_ip VARCHAR(45) NULL,
    fec_creacion TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    fec_actualizacion TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    fec_eliminacion TIMESTAMP NULL DEFAULT NULL,
    INDEX idx_auditoria_usuario (usuario_id),
    INDEX idx_auditoria_tabla_registro (tabla_afectada, registro_id),
    INDEX idx_auditoria_fec_creacion (fec_creacion)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE servicios (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(150) NOT NULL,
    descripcion TEXT NULL,
    precio DECIMAL(10,2) NOT NULL DEFAULT 0.00,
    url_imagen VARCHAR(255) NULL,
    estado VARCHAR(30) NOT NULL DEFAULT 'activo',
    fecha_inicio DATE NULL,
    fecha_fin DATE NULL,
    fec_creacion TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    fec_actualizacion TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    fec_eliminacion TIMESTAMP NULL DEFAULT NULL,
    CONSTRAINT chk_servicios_precio CHECK (precio >= 0),
    CONSTRAINT chk_servicios_fechas CHECK (
        fecha_inicio IS NULL OR fecha_fin IS NULL OR fecha_fin >= fecha_inicio
    ),
    INDEX idx_servicios_nombre (nombre),
    INDEX idx_servicios_estado (estado, fec_eliminacion)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE productos (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    codigo VARCHAR(60) NULL,
    nombre VARCHAR(150) NOT NULL,
    descripcion TEXT NULL,
    cantidad INT NOT NULL DEFAULT 0,
    unidad_medida VARCHAR(50) NOT NULL DEFAULT 'unidad',
    categoria_unidad VARCHAR(100) NULL,
    costo_produccion DECIMAL(10,2) NOT NULL DEFAULT 0.00,
    precio_venta DECIMAL(10,2) NOT NULL DEFAULT 0.00,
    url_imagen VARCHAR(255) NULL,
    activo BOOLEAN NOT NULL DEFAULT TRUE,
    fec_creacion TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    fec_actualizacion TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    fec_eliminacion TIMESTAMP NULL DEFAULT NULL,
    CONSTRAINT chk_productos_costo CHECK (costo_produccion >= 0),
    CONSTRAINT chk_productos_precio_venta CHECK (precio_venta >= 0),
    CONSTRAINT chk_productos_cantidad CHECK (cantidad >= 0),
    UNIQUE KEY uq_productos_codigo (codigo),
    INDEX idx_productos_nombre (nombre),
    INDEX idx_productos_activo (activo, fec_eliminacion)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE ventas (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    fecha_venta DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    estado VARCHAR(30) NOT NULL DEFAULT 'completada',
    metodo_pago VARCHAR(50) NULL,
    subtotal DECIMAL(12,2) NOT NULL DEFAULT 0.00,
    descuento DECIMAL(12,2) NOT NULL DEFAULT 0.00,
    impuesto DECIMAL(12,2) NOT NULL DEFAULT 0.00,
    total DECIMAL(12,2) NOT NULL DEFAULT 0.00,
    observaciones TEXT NULL,
    fec_creacion TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    fec_actualizacion TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    fec_eliminacion TIMESTAMP NULL DEFAULT NULL,
    CONSTRAINT chk_ventas_subtotal CHECK (subtotal >= 0),
    CONSTRAINT chk_ventas_descuento CHECK (descuento >= 0),
    CONSTRAINT chk_ventas_impuesto CHECK (impuesto >= 0),
    CONSTRAINT chk_ventas_total CHECK (total >= 0),
    INDEX idx_ventas_fecha (fec_eliminacion, fecha_venta),
    INDEX idx_ventas_estado (estado)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE detalle_venta (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    venta_id BIGINT UNSIGNED NOT NULL,
    producto_id BIGINT UNSIGNED NULL,
    servicio_id BIGINT UNSIGNED NULL,
    nombre_item VARCHAR(150) NOT NULL,
    cantidad DECIMAL(12,2) NOT NULL DEFAULT 1.00,
    precio_unitario DECIMAL(10,2) NOT NULL DEFAULT 0.00,
    descuento DECIMAL(12,2) NOT NULL DEFAULT 0.00,
    subtotal DECIMAL(12,2) NOT NULL DEFAULT 0.00,
    fec_creacion TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    fec_actualizacion TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    fec_eliminacion TIMESTAMP NULL DEFAULT NULL,
    CONSTRAINT chk_detalle_cantidad CHECK (cantidad > 0),
    CONSTRAINT chk_detalle_precio CHECK (precio_unitario >= 0),
    CONSTRAINT chk_detalle_descuento CHECK (descuento >= 0),
    CONSTRAINT chk_detalle_subtotal CHECK (subtotal >= 0),
    CONSTRAINT fk_detalle_venta_venta FOREIGN KEY (venta_id)
        REFERENCES ventas(id) ON UPDATE CASCADE ON DELETE RESTRICT,
    CONSTRAINT fk_detalle_venta_producto FOREIGN KEY (producto_id)
        REFERENCES productos(id) ON UPDATE CASCADE ON DELETE RESTRICT,
    CONSTRAINT fk_detalle_venta_servicio FOREIGN KEY (servicio_id)
        REFERENCES servicios(id) ON UPDATE CASCADE ON DELETE RESTRICT,
    INDEX idx_detalle_venta (venta_id, fec_eliminacion),
    INDEX idx_detalle_producto (producto_id),
    INDEX idx_detalle_servicio (servicio_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE movimientos_inventario (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    producto_id BIGINT UNSIGNED NOT NULL,
    venta_id BIGINT UNSIGNED NULL,
    tipo VARCHAR(30) NOT NULL,
    cantidad DECIMAL(12,2) NOT NULL,
    motivo VARCHAR(255) NULL,
    fec_creacion TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    fec_actualizacion TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    fec_eliminacion TIMESTAMP NULL DEFAULT NULL,
    CONSTRAINT chk_movimiento_cantidad CHECK (cantidad > 0),
    CONSTRAINT fk_movimientos_producto FOREIGN KEY (producto_id)
        REFERENCES productos(id) ON UPDATE CASCADE ON DELETE RESTRICT,
    CONSTRAINT fk_movimientos_venta FOREIGN KEY (venta_id)
        REFERENCES ventas(id) ON UPDATE CASCADE ON DELETE RESTRICT,
    INDEX idx_movimientos_producto_fecha (producto_id, fec_creacion),
    INDEX idx_movimientos_venta (venta_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ================= BASE 9/26: db_emp_bodega_ga (Bodega G&A "Dulce Mora") =================

-- ============================================================
-- BASE DE DATOS OPERATIVA: db_emp_bodega_ga
-- EMPRENDIMIENTO: Bodega G&A "Dulce Mora"
-- ============================================================
CREATE DATABASE IF NOT EXISTS `db_emp_bodega_ga`
    CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE `db_emp_bodega_ga`;

-- CREACION DE USUARIO DE BASE DE DATOS Y ASIGNACION DE PERMISOS
CREATE USER IF NOT EXISTS 'emp_bodega_ga'@'%' IDENTIFIED BY 'DbPass_bodega9';
GRANT ALL PRIVILEGES ON `db_emp_bodega_ga`.* TO 'emp_bodega_ga'@'%';
CREATE USER IF NOT EXISTS 'emp_bodega_ga'@'localhost' IDENTIFIED BY 'DbPass_bodega9';
GRANT ALL PRIVILEGES ON `db_emp_bodega_ga`.* TO 'emp_bodega_ga'@'localhost';
FLUSH PRIVILEGES;

SET FOREIGN_KEY_CHECKS = 0;
DROP TABLE IF EXISTS detalle_venta;
DROP TABLE IF EXISTS movimientos_inventario;
DROP TABLE IF EXISTS ventas;
DROP TABLE IF EXISTS productos;
DROP TABLE IF EXISTS servicios;
DROP TABLE IF EXISTS auditoria;
SET FOREIGN_KEY_CHECKS = 1;

CREATE TABLE auditoria (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    usuario_id BIGINT UNSIGNED NULL,
    accion VARCHAR(50) NOT NULL,
    tabla_afectada VARCHAR(100) NOT NULL,
    registro_id BIGINT UNSIGNED NULL,
    valores_anteriores JSON NULL,
    valores_nuevos JSON NULL,
    detalle TEXT NULL,
    direccion_ip VARCHAR(45) NULL,
    fec_creacion TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    fec_actualizacion TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    fec_eliminacion TIMESTAMP NULL DEFAULT NULL,
    INDEX idx_auditoria_usuario (usuario_id),
    INDEX idx_auditoria_tabla_registro (tabla_afectada, registro_id),
    INDEX idx_auditoria_fec_creacion (fec_creacion)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE servicios (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(150) NOT NULL,
    descripcion TEXT NULL,
    precio DECIMAL(10,2) NOT NULL DEFAULT 0.00,
    url_imagen VARCHAR(255) NULL,
    estado VARCHAR(30) NOT NULL DEFAULT 'activo',
    fecha_inicio DATE NULL,
    fecha_fin DATE NULL,
    fec_creacion TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    fec_actualizacion TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    fec_eliminacion TIMESTAMP NULL DEFAULT NULL,
    CONSTRAINT chk_servicios_precio CHECK (precio >= 0),
    CONSTRAINT chk_servicios_fechas CHECK (
        fecha_inicio IS NULL OR fecha_fin IS NULL OR fecha_fin >= fecha_inicio
    ),
    INDEX idx_servicios_nombre (nombre),
    INDEX idx_servicios_estado (estado, fec_eliminacion)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE productos (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    codigo VARCHAR(60) NULL,
    nombre VARCHAR(150) NOT NULL,
    descripcion TEXT NULL,
    cantidad INT NOT NULL DEFAULT 0,
    unidad_medida VARCHAR(50) NOT NULL DEFAULT 'unidad',
    categoria_unidad VARCHAR(100) NULL,
    costo_produccion DECIMAL(10,2) NOT NULL DEFAULT 0.00,
    precio_venta DECIMAL(10,2) NOT NULL DEFAULT 0.00,
    url_imagen VARCHAR(255) NULL,
    activo BOOLEAN NOT NULL DEFAULT TRUE,
    fec_creacion TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    fec_actualizacion TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    fec_eliminacion TIMESTAMP NULL DEFAULT NULL,
    CONSTRAINT chk_productos_costo CHECK (costo_produccion >= 0),
    CONSTRAINT chk_productos_precio_venta CHECK (precio_venta >= 0),
    CONSTRAINT chk_productos_cantidad CHECK (cantidad >= 0),
    UNIQUE KEY uq_productos_codigo (codigo),
    INDEX idx_productos_nombre (nombre),
    INDEX idx_productos_activo (activo, fec_eliminacion)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE ventas (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    fecha_venta DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    estado VARCHAR(30) NOT NULL DEFAULT 'completada',
    metodo_pago VARCHAR(50) NULL,
    subtotal DECIMAL(12,2) NOT NULL DEFAULT 0.00,
    descuento DECIMAL(12,2) NOT NULL DEFAULT 0.00,
    impuesto DECIMAL(12,2) NOT NULL DEFAULT 0.00,
    total DECIMAL(12,2) NOT NULL DEFAULT 0.00,
    observaciones TEXT NULL,
    fec_creacion TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    fec_actualizacion TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    fec_eliminacion TIMESTAMP NULL DEFAULT NULL,
    CONSTRAINT chk_ventas_subtotal CHECK (subtotal >= 0),
    CONSTRAINT chk_ventas_descuento CHECK (descuento >= 0),
    CONSTRAINT chk_ventas_impuesto CHECK (impuesto >= 0),
    CONSTRAINT chk_ventas_total CHECK (total >= 0),
    INDEX idx_ventas_fecha (fec_eliminacion, fecha_venta),
    INDEX idx_ventas_estado (estado)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE detalle_venta (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    venta_id BIGINT UNSIGNED NOT NULL,
    producto_id BIGINT UNSIGNED NULL,
    servicio_id BIGINT UNSIGNED NULL,
    nombre_item VARCHAR(150) NOT NULL,
    cantidad DECIMAL(12,2) NOT NULL DEFAULT 1.00,
    precio_unitario DECIMAL(10,2) NOT NULL DEFAULT 0.00,
    descuento DECIMAL(12,2) NOT NULL DEFAULT 0.00,
    subtotal DECIMAL(12,2) NOT NULL DEFAULT 0.00,
    fec_creacion TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    fec_actualizacion TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    fec_eliminacion TIMESTAMP NULL DEFAULT NULL,
    CONSTRAINT chk_detalle_cantidad CHECK (cantidad > 0),
    CONSTRAINT chk_detalle_precio CHECK (precio_unitario >= 0),
    CONSTRAINT chk_detalle_descuento CHECK (descuento >= 0),
    CONSTRAINT chk_detalle_subtotal CHECK (subtotal >= 0),
    CONSTRAINT fk_detalle_venta_venta FOREIGN KEY (venta_id)
        REFERENCES ventas(id) ON UPDATE CASCADE ON DELETE RESTRICT,
    CONSTRAINT fk_detalle_venta_producto FOREIGN KEY (producto_id)
        REFERENCES productos(id) ON UPDATE CASCADE ON DELETE RESTRICT,
    CONSTRAINT fk_detalle_venta_servicio FOREIGN KEY (servicio_id)
        REFERENCES servicios(id) ON UPDATE CASCADE ON DELETE RESTRICT,
    INDEX idx_detalle_venta (venta_id, fec_eliminacion),
    INDEX idx_detalle_producto (producto_id),
    INDEX idx_detalle_servicio (servicio_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE movimientos_inventario (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    producto_id BIGINT UNSIGNED NOT NULL,
    venta_id BIGINT UNSIGNED NULL,
    tipo VARCHAR(30) NOT NULL,
    cantidad DECIMAL(12,2) NOT NULL,
    motivo VARCHAR(255) NULL,
    fec_creacion TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    fec_actualizacion TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    fec_eliminacion TIMESTAMP NULL DEFAULT NULL,
    CONSTRAINT chk_movimiento_cantidad CHECK (cantidad > 0),
    CONSTRAINT fk_movimientos_producto FOREIGN KEY (producto_id)
        REFERENCES productos(id) ON UPDATE CASCADE ON DELETE RESTRICT,
    CONSTRAINT fk_movimientos_venta FOREIGN KEY (venta_id)
        REFERENCES ventas(id) ON UPDATE CASCADE ON DELETE RESTRICT,
    INDEX idx_movimientos_producto_fecha (producto_id, fec_creacion),
    INDEX idx_movimientos_venta (venta_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ================= BASE 10/26: db_emp_sirackagro (SirackAgro Industria) =================

-- ============================================================
-- BASE DE DATOS OPERATIVA: db_emp_sirackagro
-- EMPRENDIMIENTO: SirackAgro Industria
-- ============================================================
CREATE DATABASE IF NOT EXISTS `db_emp_sirackagro`
    CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE `db_emp_sirackagro`;

-- CREACION DE USUARIO DE BASE DE DATOS Y ASIGNACION DE PERMISOS
CREATE USER IF NOT EXISTS 'emp_sirackagro'@'%' IDENTIFIED BY 'DbPass_sirack10';
GRANT ALL PRIVILEGES ON `db_emp_sirackagro`.* TO 'emp_sirackagro'@'%';
CREATE USER IF NOT EXISTS 'emp_sirackagro'@'localhost' IDENTIFIED BY 'DbPass_sirack10';
GRANT ALL PRIVILEGES ON `db_emp_sirackagro`.* TO 'emp_sirackagro'@'localhost';
FLUSH PRIVILEGES;

SET FOREIGN_KEY_CHECKS = 0;
DROP TABLE IF EXISTS detalle_venta;
DROP TABLE IF EXISTS movimientos_inventario;
DROP TABLE IF EXISTS ventas;
DROP TABLE IF EXISTS productos;
DROP TABLE IF EXISTS servicios;
DROP TABLE IF EXISTS auditoria;
SET FOREIGN_KEY_CHECKS = 1;

CREATE TABLE auditoria (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    usuario_id BIGINT UNSIGNED NULL,
    accion VARCHAR(50) NOT NULL,
    tabla_afectada VARCHAR(100) NOT NULL,
    registro_id BIGINT UNSIGNED NULL,
    valores_anteriores JSON NULL,
    valores_nuevos JSON NULL,
    detalle TEXT NULL,
    direccion_ip VARCHAR(45) NULL,
    fec_creacion TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    fec_actualizacion TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    fec_eliminacion TIMESTAMP NULL DEFAULT NULL,
    INDEX idx_auditoria_usuario (usuario_id),
    INDEX idx_auditoria_tabla_registro (tabla_afectada, registro_id),
    INDEX idx_auditoria_fec_creacion (fec_creacion)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE servicios (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(150) NOT NULL,
    descripcion TEXT NULL,
    precio DECIMAL(10,2) NOT NULL DEFAULT 0.00,
    url_imagen VARCHAR(255) NULL,
    estado VARCHAR(30) NOT NULL DEFAULT 'activo',
    fecha_inicio DATE NULL,
    fecha_fin DATE NULL,
    fec_creacion TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    fec_actualizacion TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    fec_eliminacion TIMESTAMP NULL DEFAULT NULL,
    CONSTRAINT chk_servicios_precio CHECK (precio >= 0),
    CONSTRAINT chk_servicios_fechas CHECK (
        fecha_inicio IS NULL OR fecha_fin IS NULL OR fecha_fin >= fecha_inicio
    ),
    INDEX idx_servicios_nombre (nombre),
    INDEX idx_servicios_estado (estado, fec_eliminacion)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE productos (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    codigo VARCHAR(60) NULL,
    nombre VARCHAR(150) NOT NULL,
    descripcion TEXT NULL,
    cantidad INT NOT NULL DEFAULT 0,
    unidad_medida VARCHAR(50) NOT NULL DEFAULT 'unidad',
    categoria_unidad VARCHAR(100) NULL,
    costo_produccion DECIMAL(10,2) NOT NULL DEFAULT 0.00,
    precio_venta DECIMAL(10,2) NOT NULL DEFAULT 0.00,
    url_imagen VARCHAR(255) NULL,
    activo BOOLEAN NOT NULL DEFAULT TRUE,
    fec_creacion TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    fec_actualizacion TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    fec_eliminacion TIMESTAMP NULL DEFAULT NULL,
    CONSTRAINT chk_productos_costo CHECK (costo_produccion >= 0),
    CONSTRAINT chk_productos_precio_venta CHECK (precio_venta >= 0),
    CONSTRAINT chk_productos_cantidad CHECK (cantidad >= 0),
    UNIQUE KEY uq_productos_codigo (codigo),
    INDEX idx_productos_nombre (nombre),
    INDEX idx_productos_activo (activo, fec_eliminacion)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE ventas (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    fecha_venta DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    estado VARCHAR(30) NOT NULL DEFAULT 'completada',
    metodo_pago VARCHAR(50) NULL,
    subtotal DECIMAL(12,2) NOT NULL DEFAULT 0.00,
    descuento DECIMAL(12,2) NOT NULL DEFAULT 0.00,
    impuesto DECIMAL(12,2) NOT NULL DEFAULT 0.00,
    total DECIMAL(12,2) NOT NULL DEFAULT 0.00,
    observaciones TEXT NULL,
    fec_creacion TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    fec_actualizacion TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    fec_eliminacion TIMESTAMP NULL DEFAULT NULL,
    CONSTRAINT chk_ventas_subtotal CHECK (subtotal >= 0),
    CONSTRAINT chk_ventas_descuento CHECK (descuento >= 0),
    CONSTRAINT chk_ventas_impuesto CHECK (impuesto >= 0),
    CONSTRAINT chk_ventas_total CHECK (total >= 0),
    INDEX idx_ventas_fecha (fec_eliminacion, fecha_venta),
    INDEX idx_ventas_estado (estado)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE detalle_venta (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    venta_id BIGINT UNSIGNED NOT NULL,
    producto_id BIGINT UNSIGNED NULL,
    servicio_id BIGINT UNSIGNED NULL,
    nombre_item VARCHAR(150) NOT NULL,
    cantidad DECIMAL(12,2) NOT NULL DEFAULT 1.00,
    precio_unitario DECIMAL(10,2) NOT NULL DEFAULT 0.00,
    descuento DECIMAL(12,2) NOT NULL DEFAULT 0.00,
    subtotal DECIMAL(12,2) NOT NULL DEFAULT 0.00,
    fec_creacion TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    fec_actualizacion TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    fec_eliminacion TIMESTAMP NULL DEFAULT NULL,
    CONSTRAINT chk_detalle_cantidad CHECK (cantidad > 0),
    CONSTRAINT chk_detalle_precio CHECK (precio_unitario >= 0),
    CONSTRAINT chk_detalle_descuento CHECK (descuento >= 0),
    CONSTRAINT chk_detalle_subtotal CHECK (subtotal >= 0),
    CONSTRAINT fk_detalle_venta_venta FOREIGN KEY (venta_id)
        REFERENCES ventas(id) ON UPDATE CASCADE ON DELETE RESTRICT,
    CONSTRAINT fk_detalle_venta_producto FOREIGN KEY (producto_id)
        REFERENCES productos(id) ON UPDATE CASCADE ON DELETE RESTRICT,
    CONSTRAINT fk_detalle_venta_servicio FOREIGN KEY (servicio_id)
        REFERENCES servicios(id) ON UPDATE CASCADE ON DELETE RESTRICT,
    INDEX idx_detalle_venta (venta_id, fec_eliminacion),
    INDEX idx_detalle_producto (producto_id),
    INDEX idx_detalle_servicio (servicio_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE movimientos_inventario (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    producto_id BIGINT UNSIGNED NOT NULL,
    venta_id BIGINT UNSIGNED NULL,
    tipo VARCHAR(30) NOT NULL,
    cantidad DECIMAL(12,2) NOT NULL,
    motivo VARCHAR(255) NULL,
    fec_creacion TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    fec_actualizacion TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    fec_eliminacion TIMESTAMP NULL DEFAULT NULL,
    CONSTRAINT chk_movimiento_cantidad CHECK (cantidad > 0),
    CONSTRAINT fk_movimientos_producto FOREIGN KEY (producto_id)
        REFERENCES productos(id) ON UPDATE CASCADE ON DELETE RESTRICT,
    CONSTRAINT fk_movimientos_venta FOREIGN KEY (venta_id)
        REFERENCES ventas(id) ON UPDATE CASCADE ON DELETE RESTRICT,
    INDEX idx_movimientos_producto_fecha (producto_id, fec_creacion),
    INDEX idx_movimientos_venta (venta_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ================= BASE 11/26: db_emp_vinos_san_juan (Vinos San Juan) =================

-- ============================================================
-- BASE DE DATOS OPERATIVA: db_emp_vinos_san_juan
-- EMPRENDIMIENTO: Vinos San Juan
-- ============================================================
CREATE DATABASE IF NOT EXISTS `db_emp_vinos_san_juan`
    CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE `db_emp_vinos_san_juan`;

-- CREACION DE USUARIO DE BASE DE DATOS Y ASIGNACION DE PERMISOS
CREATE USER IF NOT EXISTS 'emp_vinos_san_juan'@'%' IDENTIFIED BY 'DbPass_vinos11';
GRANT ALL PRIVILEGES ON `db_emp_vinos_san_juan`.* TO 'emp_vinos_san_juan'@'%';
CREATE USER IF NOT EXISTS 'emp_vinos_san_juan'@'localhost' IDENTIFIED BY 'DbPass_vinos11';
GRANT ALL PRIVILEGES ON `db_emp_vinos_san_juan`.* TO 'emp_vinos_san_juan'@'localhost';
FLUSH PRIVILEGES;

SET FOREIGN_KEY_CHECKS = 0;
DROP TABLE IF EXISTS detalle_venta;
DROP TABLE IF EXISTS movimientos_inventario;
DROP TABLE IF EXISTS ventas;
DROP TABLE IF EXISTS productos;
DROP TABLE IF EXISTS servicios;
DROP TABLE IF EXISTS auditoria;
SET FOREIGN_KEY_CHECKS = 1;

CREATE TABLE auditoria (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    usuario_id BIGINT UNSIGNED NULL,
    accion VARCHAR(50) NOT NULL,
    tabla_afectada VARCHAR(100) NOT NULL,
    registro_id BIGINT UNSIGNED NULL,
    valores_anteriores JSON NULL,
    valores_nuevos JSON NULL,
    detalle TEXT NULL,
    direccion_ip VARCHAR(45) NULL,
    fec_creacion TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    fec_actualizacion TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    fec_eliminacion TIMESTAMP NULL DEFAULT NULL,
    INDEX idx_auditoria_usuario (usuario_id),
    INDEX idx_auditoria_tabla_registro (tabla_afectada, registro_id),
    INDEX idx_auditoria_fec_creacion (fec_creacion)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE servicios (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(150) NOT NULL,
    descripcion TEXT NULL,
    precio DECIMAL(10,2) NOT NULL DEFAULT 0.00,
    url_imagen VARCHAR(255) NULL,
    estado VARCHAR(30) NOT NULL DEFAULT 'activo',
    fecha_inicio DATE NULL,
    fecha_fin DATE NULL,
    fec_creacion TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    fec_actualizacion TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    fec_eliminacion TIMESTAMP NULL DEFAULT NULL,
    CONSTRAINT chk_servicios_precio CHECK (precio >= 0),
    CONSTRAINT chk_servicios_fechas CHECK (
        fecha_inicio IS NULL OR fecha_fin IS NULL OR fecha_fin >= fecha_inicio
    ),
    INDEX idx_servicios_nombre (nombre),
    INDEX idx_servicios_estado (estado, fec_eliminacion)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE productos (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    codigo VARCHAR(60) NULL,
    nombre VARCHAR(150) NOT NULL,
    descripcion TEXT NULL,
    cantidad INT NOT NULL DEFAULT 0,
    unidad_medida VARCHAR(50) NOT NULL DEFAULT 'unidad',
    categoria_unidad VARCHAR(100) NULL,
    costo_produccion DECIMAL(10,2) NOT NULL DEFAULT 0.00,
    precio_venta DECIMAL(10,2) NOT NULL DEFAULT 0.00,
    url_imagen VARCHAR(255) NULL,
    activo BOOLEAN NOT NULL DEFAULT TRUE,
    fec_creacion TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    fec_actualizacion TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    fec_eliminacion TIMESTAMP NULL DEFAULT NULL,
    CONSTRAINT chk_productos_costo CHECK (costo_produccion >= 0),
    CONSTRAINT chk_productos_precio_venta CHECK (precio_venta >= 0),
    CONSTRAINT chk_productos_cantidad CHECK (cantidad >= 0),
    UNIQUE KEY uq_productos_codigo (codigo),
    INDEX idx_productos_nombre (nombre),
    INDEX idx_productos_activo (activo, fec_eliminacion)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE ventas (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    fecha_venta DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    estado VARCHAR(30) NOT NULL DEFAULT 'completada',
    metodo_pago VARCHAR(50) NULL,
    subtotal DECIMAL(12,2) NOT NULL DEFAULT 0.00,
    descuento DECIMAL(12,2) NOT NULL DEFAULT 0.00,
    impuesto DECIMAL(12,2) NOT NULL DEFAULT 0.00,
    total DECIMAL(12,2) NOT NULL DEFAULT 0.00,
    observaciones TEXT NULL,
    fec_creacion TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    fec_actualizacion TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    fec_eliminacion TIMESTAMP NULL DEFAULT NULL,
    CONSTRAINT chk_ventas_subtotal CHECK (subtotal >= 0),
    CONSTRAINT chk_ventas_descuento CHECK (descuento >= 0),
    CONSTRAINT chk_ventas_impuesto CHECK (impuesto >= 0),
    CONSTRAINT chk_ventas_total CHECK (total >= 0),
    INDEX idx_ventas_fecha (fec_eliminacion, fecha_venta),
    INDEX idx_ventas_estado (estado)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE detalle_venta (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    venta_id BIGINT UNSIGNED NOT NULL,
    producto_id BIGINT UNSIGNED NULL,
    servicio_id BIGINT UNSIGNED NULL,
    nombre_item VARCHAR(150) NOT NULL,
    cantidad DECIMAL(12,2) NOT NULL DEFAULT 1.00,
    precio_unitario DECIMAL(10,2) NOT NULL DEFAULT 0.00,
    descuento DECIMAL(12,2) NOT NULL DEFAULT 0.00,
    subtotal DECIMAL(12,2) NOT NULL DEFAULT 0.00,
    fec_creacion TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    fec_actualizacion TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    fec_eliminacion TIMESTAMP NULL DEFAULT NULL,
    CONSTRAINT chk_detalle_cantidad CHECK (cantidad > 0),
    CONSTRAINT chk_detalle_precio CHECK (precio_unitario >= 0),
    CONSTRAINT chk_detalle_descuento CHECK (descuento >= 0),
    CONSTRAINT chk_detalle_subtotal CHECK (subtotal >= 0),
    CONSTRAINT fk_detalle_venta_venta FOREIGN KEY (venta_id)
        REFERENCES ventas(id) ON UPDATE CASCADE ON DELETE RESTRICT,
    CONSTRAINT fk_detalle_venta_producto FOREIGN KEY (producto_id)
        REFERENCES productos(id) ON UPDATE CASCADE ON DELETE RESTRICT,
    CONSTRAINT fk_detalle_venta_servicio FOREIGN KEY (servicio_id)
        REFERENCES servicios(id) ON UPDATE CASCADE ON DELETE RESTRICT,
    INDEX idx_detalle_venta (venta_id, fec_eliminacion),
    INDEX idx_detalle_producto (producto_id),
    INDEX idx_detalle_servicio (servicio_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE movimientos_inventario (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    producto_id BIGINT UNSIGNED NOT NULL,
    venta_id BIGINT UNSIGNED NULL,
    tipo VARCHAR(30) NOT NULL,
    cantidad DECIMAL(12,2) NOT NULL,
    motivo VARCHAR(255) NULL,
    fec_creacion TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    fec_actualizacion TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    fec_eliminacion TIMESTAMP NULL DEFAULT NULL,
    CONSTRAINT chk_movimiento_cantidad CHECK (cantidad > 0),
    CONSTRAINT fk_movimientos_producto FOREIGN KEY (producto_id)
        REFERENCES productos(id) ON UPDATE CASCADE ON DELETE RESTRICT,
    CONSTRAINT fk_movimientos_venta FOREIGN KEY (venta_id)
        REFERENCES ventas(id) ON UPDATE CASCADE ON DELETE RESTRICT,
    INDEX idx_movimientos_producto_fecha (producto_id, fec_creacion),
    INDEX idx_movimientos_venta (venta_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ================= BASE 12/26: db_emp_sachaluna (SachaLuna) =================

-- ============================================================
-- BASE DE DATOS OPERATIVA: db_emp_sachaluna
-- EMPRENDIMIENTO: SachaLuna
-- ============================================================
CREATE DATABASE IF NOT EXISTS `db_emp_sachaluna`
    CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE `db_emp_sachaluna`;

-- CREACION DE USUARIO DE BASE DE DATOS Y ASIGNACION DE PERMISOS
CREATE USER IF NOT EXISTS 'emp_sachaluna'@'%' IDENTIFIED BY 'DbPass_sacha12';
GRANT ALL PRIVILEGES ON `db_emp_sachaluna`.* TO 'emp_sachaluna'@'%';
CREATE USER IF NOT EXISTS 'emp_sachaluna'@'localhost' IDENTIFIED BY 'DbPass_sacha12';
GRANT ALL PRIVILEGES ON `db_emp_sachaluna`.* TO 'emp_sachaluna'@'localhost';
FLUSH PRIVILEGES;

SET FOREIGN_KEY_CHECKS = 0;
DROP TABLE IF EXISTS detalle_venta;
DROP TABLE IF EXISTS movimientos_inventario;
DROP TABLE IF EXISTS ventas;
DROP TABLE IF EXISTS productos;
DROP TABLE IF EXISTS servicios;
DROP TABLE IF EXISTS auditoria;
SET FOREIGN_KEY_CHECKS = 1;

CREATE TABLE auditoria (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    usuario_id BIGINT UNSIGNED NULL,
    accion VARCHAR(50) NOT NULL,
    tabla_afectada VARCHAR(100) NOT NULL,
    registro_id BIGINT UNSIGNED NULL,
    valores_anteriores JSON NULL,
    valores_nuevos JSON NULL,
    detalle TEXT NULL,
    direccion_ip VARCHAR(45) NULL,
    fec_creacion TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    fec_actualizacion TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    fec_eliminacion TIMESTAMP NULL DEFAULT NULL,
    INDEX idx_auditoria_usuario (usuario_id),
    INDEX idx_auditoria_tabla_registro (tabla_afectada, registro_id),
    INDEX idx_auditoria_fec_creacion (fec_creacion)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE servicios (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(150) NOT NULL,
    descripcion TEXT NULL,
    precio DECIMAL(10,2) NOT NULL DEFAULT 0.00,
    url_imagen VARCHAR(255) NULL,
    estado VARCHAR(30) NOT NULL DEFAULT 'activo',
    fecha_inicio DATE NULL,
    fecha_fin DATE NULL,
    fec_creacion TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    fec_actualizacion TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    fec_eliminacion TIMESTAMP NULL DEFAULT NULL,
    CONSTRAINT chk_servicios_precio CHECK (precio >= 0),
    CONSTRAINT chk_servicios_fechas CHECK (
        fecha_inicio IS NULL OR fecha_fin IS NULL OR fecha_fin >= fecha_inicio
    ),
    INDEX idx_servicios_nombre (nombre),
    INDEX idx_servicios_estado (estado, fec_eliminacion)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE productos (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    codigo VARCHAR(60) NULL,
    nombre VARCHAR(150) NOT NULL,
    descripcion TEXT NULL,
    cantidad INT NOT NULL DEFAULT 0,
    unidad_medida VARCHAR(50) NOT NULL DEFAULT 'unidad',
    categoria_unidad VARCHAR(100) NULL,
    costo_produccion DECIMAL(10,2) NOT NULL DEFAULT 0.00,
    precio_venta DECIMAL(10,2) NOT NULL DEFAULT 0.00,
    url_imagen VARCHAR(255) NULL,
    activo BOOLEAN NOT NULL DEFAULT TRUE,
    fec_creacion TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    fec_actualizacion TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    fec_eliminacion TIMESTAMP NULL DEFAULT NULL,
    CONSTRAINT chk_productos_costo CHECK (costo_produccion >= 0),
    CONSTRAINT chk_productos_precio_venta CHECK (precio_venta >= 0),
    CONSTRAINT chk_productos_cantidad CHECK (cantidad >= 0),
    UNIQUE KEY uq_productos_codigo (codigo),
    INDEX idx_productos_nombre (nombre),
    INDEX idx_productos_activo (activo, fec_eliminacion)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE ventas (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    fecha_venta DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    estado VARCHAR(30) NOT NULL DEFAULT 'completada',
    metodo_pago VARCHAR(50) NULL,
    subtotal DECIMAL(12,2) NOT NULL DEFAULT 0.00,
    descuento DECIMAL(12,2) NOT NULL DEFAULT 0.00,
    impuesto DECIMAL(12,2) NOT NULL DEFAULT 0.00,
    total DECIMAL(12,2) NOT NULL DEFAULT 0.00,
    observaciones TEXT NULL,
    fec_creacion TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    fec_actualizacion TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    fec_eliminacion TIMESTAMP NULL DEFAULT NULL,
    CONSTRAINT chk_ventas_subtotal CHECK (subtotal >= 0),
    CONSTRAINT chk_ventas_descuento CHECK (descuento >= 0),
    CONSTRAINT chk_ventas_impuesto CHECK (impuesto >= 0),
    CONSTRAINT chk_ventas_total CHECK (total >= 0),
    INDEX idx_ventas_fecha (fec_eliminacion, fecha_venta),
    INDEX idx_ventas_estado (estado)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE detalle_venta (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    venta_id BIGINT UNSIGNED NOT NULL,
    producto_id BIGINT UNSIGNED NULL,
    servicio_id BIGINT UNSIGNED NULL,
    nombre_item VARCHAR(150) NOT NULL,
    cantidad DECIMAL(12,2) NOT NULL DEFAULT 1.00,
    precio_unitario DECIMAL(10,2) NOT NULL DEFAULT 0.00,
    descuento DECIMAL(12,2) NOT NULL DEFAULT 0.00,
    subtotal DECIMAL(12,2) NOT NULL DEFAULT 0.00,
    fec_creacion TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    fec_actualizacion TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    fec_eliminacion TIMESTAMP NULL DEFAULT NULL,
    CONSTRAINT chk_detalle_cantidad CHECK (cantidad > 0),
    CONSTRAINT chk_detalle_precio CHECK (precio_unitario >= 0),
    CONSTRAINT chk_detalle_descuento CHECK (descuento >= 0),
    CONSTRAINT chk_detalle_subtotal CHECK (subtotal >= 0),
    CONSTRAINT fk_detalle_venta_venta FOREIGN KEY (venta_id)
        REFERENCES ventas(id) ON UPDATE CASCADE ON DELETE RESTRICT,
    CONSTRAINT fk_detalle_venta_producto FOREIGN KEY (producto_id)
        REFERENCES productos(id) ON UPDATE CASCADE ON DELETE RESTRICT,
    CONSTRAINT fk_detalle_venta_servicio FOREIGN KEY (servicio_id)
        REFERENCES servicios(id) ON UPDATE CASCADE ON DELETE RESTRICT,
    INDEX idx_detalle_venta (venta_id, fec_eliminacion),
    INDEX idx_detalle_producto (producto_id),
    INDEX idx_detalle_servicio (servicio_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE movimientos_inventario (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    producto_id BIGINT UNSIGNED NOT NULL,
    venta_id BIGINT UNSIGNED NULL,
    tipo VARCHAR(30) NOT NULL,
    cantidad DECIMAL(12,2) NOT NULL,
    motivo VARCHAR(255) NULL,
    fec_creacion TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    fec_actualizacion TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    fec_eliminacion TIMESTAMP NULL DEFAULT NULL,
    CONSTRAINT chk_movimiento_cantidad CHECK (cantidad > 0),
    CONSTRAINT fk_movimientos_producto FOREIGN KEY (producto_id)
        REFERENCES productos(id) ON UPDATE CASCADE ON DELETE RESTRICT,
    CONSTRAINT fk_movimientos_venta FOREIGN KEY (venta_id)
        REFERENCES ventas(id) ON UPDATE CASCADE ON DELETE RESTRICT,
    INDEX idx_movimientos_producto_fecha (producto_id, fec_creacion),
    INDEX idx_movimientos_venta (venta_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ================= BASE 13/26: db_emp_granja_ainhoa (Granja Ainhoa) =================

-- ============================================================
-- BASE DE DATOS OPERATIVA: db_emp_granja_ainhoa
-- EMPRENDIMIENTO: Granja Ainhoa
-- ============================================================
CREATE DATABASE IF NOT EXISTS `db_emp_granja_ainhoa`
    CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE `db_emp_granja_ainhoa`;

-- CREACION DE USUARIO DE BASE DE DATOS Y ASIGNACION DE PERMISOS
CREATE USER IF NOT EXISTS 'emp_granja_ainhoa'@'%' IDENTIFIED BY 'DbPass_granja13';
GRANT ALL PRIVILEGES ON `db_emp_granja_ainhoa`.* TO 'emp_granja_ainhoa'@'%';
CREATE USER IF NOT EXISTS 'emp_granja_ainhoa'@'localhost' IDENTIFIED BY 'DbPass_granja13';
GRANT ALL PRIVILEGES ON `db_emp_granja_ainhoa`.* TO 'emp_granja_ainhoa'@'localhost';
FLUSH PRIVILEGES;

SET FOREIGN_KEY_CHECKS = 0;
DROP TABLE IF EXISTS detalle_venta;
DROP TABLE IF EXISTS movimientos_inventario;
DROP TABLE IF EXISTS ventas;
DROP TABLE IF EXISTS productos;
DROP TABLE IF EXISTS servicios;
DROP TABLE IF EXISTS auditoria;
SET FOREIGN_KEY_CHECKS = 1;

CREATE TABLE auditoria (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    usuario_id BIGINT UNSIGNED NULL,
    accion VARCHAR(50) NOT NULL,
    tabla_afectada VARCHAR(100) NOT NULL,
    registro_id BIGINT UNSIGNED NULL,
    valores_anteriores JSON NULL,
    valores_nuevos JSON NULL,
    detalle TEXT NULL,
    direccion_ip VARCHAR(45) NULL,
    fec_creacion TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    fec_actualizacion TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    fec_eliminacion TIMESTAMP NULL DEFAULT NULL,
    INDEX idx_auditoria_usuario (usuario_id),
    INDEX idx_auditoria_tabla_registro (tabla_afectada, registro_id),
    INDEX idx_auditoria_fec_creacion (fec_creacion)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE servicios (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(150) NOT NULL,
    descripcion TEXT NULL,
    precio DECIMAL(10,2) NOT NULL DEFAULT 0.00,
    url_imagen VARCHAR(255) NULL,
    estado VARCHAR(30) NOT NULL DEFAULT 'activo',
    fecha_inicio DATE NULL,
    fecha_fin DATE NULL,
    fec_creacion TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    fec_actualizacion TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    fec_eliminacion TIMESTAMP NULL DEFAULT NULL,
    CONSTRAINT chk_servicios_precio CHECK (precio >= 0),
    CONSTRAINT chk_servicios_fechas CHECK (
        fecha_inicio IS NULL OR fecha_fin IS NULL OR fecha_fin >= fecha_inicio
    ),
    INDEX idx_servicios_nombre (nombre),
    INDEX idx_servicios_estado (estado, fec_eliminacion)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE productos (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    codigo VARCHAR(60) NULL,
    nombre VARCHAR(150) NOT NULL,
    descripcion TEXT NULL,
    cantidad INT NOT NULL DEFAULT 0,
    unidad_medida VARCHAR(50) NOT NULL DEFAULT 'unidad',
    categoria_unidad VARCHAR(100) NULL,
    costo_produccion DECIMAL(10,2) NOT NULL DEFAULT 0.00,
    precio_venta DECIMAL(10,2) NOT NULL DEFAULT 0.00,
    url_imagen VARCHAR(255) NULL,
    activo BOOLEAN NOT NULL DEFAULT TRUE,
    fec_creacion TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    fec_actualizacion TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    fec_eliminacion TIMESTAMP NULL DEFAULT NULL,
    CONSTRAINT chk_productos_costo CHECK (costo_produccion >= 0),
    CONSTRAINT chk_productos_precio_venta CHECK (precio_venta >= 0),
    CONSTRAINT chk_productos_cantidad CHECK (cantidad >= 0),
    UNIQUE KEY uq_productos_codigo (codigo),
    INDEX idx_productos_nombre (nombre),
    INDEX idx_productos_activo (activo, fec_eliminacion)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE ventas (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    fecha_venta DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    estado VARCHAR(30) NOT NULL DEFAULT 'completada',
    metodo_pago VARCHAR(50) NULL,
    subtotal DECIMAL(12,2) NOT NULL DEFAULT 0.00,
    descuento DECIMAL(12,2) NOT NULL DEFAULT 0.00,
    impuesto DECIMAL(12,2) NOT NULL DEFAULT 0.00,
    total DECIMAL(12,2) NOT NULL DEFAULT 0.00,
    observaciones TEXT NULL,
    fec_creacion TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    fec_actualizacion TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    fec_eliminacion TIMESTAMP NULL DEFAULT NULL,
    CONSTRAINT chk_ventas_subtotal CHECK (subtotal >= 0),
    CONSTRAINT chk_ventas_descuento CHECK (descuento >= 0),
    CONSTRAINT chk_ventas_impuesto CHECK (impuesto >= 0),
    CONSTRAINT chk_ventas_total CHECK (total >= 0),
    INDEX idx_ventas_fecha (fec_eliminacion, fecha_venta),
    INDEX idx_ventas_estado (estado)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE detalle_venta (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    venta_id BIGINT UNSIGNED NOT NULL,
    producto_id BIGINT UNSIGNED NULL,
    servicio_id BIGINT UNSIGNED NULL,
    nombre_item VARCHAR(150) NOT NULL,
    cantidad DECIMAL(12,2) NOT NULL DEFAULT 1.00,
    precio_unitario DECIMAL(10,2) NOT NULL DEFAULT 0.00,
    descuento DECIMAL(12,2) NOT NULL DEFAULT 0.00,
    subtotal DECIMAL(12,2) NOT NULL DEFAULT 0.00,
    fec_creacion TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    fec_actualizacion TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    fec_eliminacion TIMESTAMP NULL DEFAULT NULL,
    CONSTRAINT chk_detalle_cantidad CHECK (cantidad > 0),
    CONSTRAINT chk_detalle_precio CHECK (precio_unitario >= 0),
    CONSTRAINT chk_detalle_descuento CHECK (descuento >= 0),
    CONSTRAINT chk_detalle_subtotal CHECK (subtotal >= 0),
    CONSTRAINT fk_detalle_venta_venta FOREIGN KEY (venta_id)
        REFERENCES ventas(id) ON UPDATE CASCADE ON DELETE RESTRICT,
    CONSTRAINT fk_detalle_venta_producto FOREIGN KEY (producto_id)
        REFERENCES productos(id) ON UPDATE CASCADE ON DELETE RESTRICT,
    CONSTRAINT fk_detalle_venta_servicio FOREIGN KEY (servicio_id)
        REFERENCES servicios(id) ON UPDATE CASCADE ON DELETE RESTRICT,
    INDEX idx_detalle_venta (venta_id, fec_eliminacion),
    INDEX idx_detalle_producto (producto_id),
    INDEX idx_detalle_servicio (servicio_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE movimientos_inventario (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    producto_id BIGINT UNSIGNED NOT NULL,
    venta_id BIGINT UNSIGNED NULL,
    tipo VARCHAR(30) NOT NULL,
    cantidad DECIMAL(12,2) NOT NULL,
    motivo VARCHAR(255) NULL,
    fec_creacion TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    fec_actualizacion TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    fec_eliminacion TIMESTAMP NULL DEFAULT NULL,
    CONSTRAINT chk_movimiento_cantidad CHECK (cantidad > 0),
    CONSTRAINT fk_movimientos_producto FOREIGN KEY (producto_id)
        REFERENCES productos(id) ON UPDATE CASCADE ON DELETE RESTRICT,
    CONSTRAINT fk_movimientos_venta FOREIGN KEY (venta_id)
        REFERENCES ventas(id) ON UPDATE CASCADE ON DELETE RESTRICT,
    INDEX idx_movimientos_producto_fecha (producto_id, fec_creacion),
    INDEX idx_movimientos_venta (venta_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ================= BASE 14/26: db_emp_vinos_la_florida (Vinos La Florida) =================

-- ============================================================
-- BASE DE DATOS OPERATIVA: db_emp_vinos_la_florida
-- EMPRENDIMIENTO: Vinos La Florida
-- ============================================================
CREATE DATABASE IF NOT EXISTS `db_emp_vinos_la_florida`
    CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE `db_emp_vinos_la_florida`;

-- CREACION DE USUARIO DE BASE DE DATOS Y ASIGNACION DE PERMISOS
CREATE USER IF NOT EXISTS 'emp_vinos_la_florida'@'%' IDENTIFIED BY 'DbPass_vinos14';
GRANT ALL PRIVILEGES ON `db_emp_vinos_la_florida`.* TO 'emp_vinos_la_florida'@'%';
CREATE USER IF NOT EXISTS 'emp_vinos_la_florida'@'localhost' IDENTIFIED BY 'DbPass_vinos14';
GRANT ALL PRIVILEGES ON `db_emp_vinos_la_florida`.* TO 'emp_vinos_la_florida'@'localhost';
FLUSH PRIVILEGES;

SET FOREIGN_KEY_CHECKS = 0;
DROP TABLE IF EXISTS detalle_venta;
DROP TABLE IF EXISTS movimientos_inventario;
DROP TABLE IF EXISTS ventas;
DROP TABLE IF EXISTS productos;
DROP TABLE IF EXISTS servicios;
DROP TABLE IF EXISTS auditoria;
SET FOREIGN_KEY_CHECKS = 1;

CREATE TABLE auditoria (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    usuario_id BIGINT UNSIGNED NULL,
    accion VARCHAR(50) NOT NULL,
    tabla_afectada VARCHAR(100) NOT NULL,
    registro_id BIGINT UNSIGNED NULL,
    valores_anteriores JSON NULL,
    valores_nuevos JSON NULL,
    detalle TEXT NULL,
    direccion_ip VARCHAR(45) NULL,
    fec_creacion TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    fec_actualizacion TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    fec_eliminacion TIMESTAMP NULL DEFAULT NULL,
    INDEX idx_auditoria_usuario (usuario_id),
    INDEX idx_auditoria_tabla_registro (tabla_afectada, registro_id),
    INDEX idx_auditoria_fec_creacion (fec_creacion)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE servicios (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(150) NOT NULL,
    descripcion TEXT NULL,
    precio DECIMAL(10,2) NOT NULL DEFAULT 0.00,
    url_imagen VARCHAR(255) NULL,
    estado VARCHAR(30) NOT NULL DEFAULT 'activo',
    fecha_inicio DATE NULL,
    fecha_fin DATE NULL,
    fec_creacion TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    fec_actualizacion TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    fec_eliminacion TIMESTAMP NULL DEFAULT NULL,
    CONSTRAINT chk_servicios_precio CHECK (precio >= 0),
    CONSTRAINT chk_servicios_fechas CHECK (
        fecha_inicio IS NULL OR fecha_fin IS NULL OR fecha_fin >= fecha_inicio
    ),
    INDEX idx_servicios_nombre (nombre),
    INDEX idx_servicios_estado (estado, fec_eliminacion)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE productos (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    codigo VARCHAR(60) NULL,
    nombre VARCHAR(150) NOT NULL,
    descripcion TEXT NULL,
    cantidad INT NOT NULL DEFAULT 0,
    unidad_medida VARCHAR(50) NOT NULL DEFAULT 'unidad',
    categoria_unidad VARCHAR(100) NULL,
    costo_produccion DECIMAL(10,2) NOT NULL DEFAULT 0.00,
    precio_venta DECIMAL(10,2) NOT NULL DEFAULT 0.00,
    url_imagen VARCHAR(255) NULL,
    activo BOOLEAN NOT NULL DEFAULT TRUE,
    fec_creacion TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    fec_actualizacion TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    fec_eliminacion TIMESTAMP NULL DEFAULT NULL,
    CONSTRAINT chk_productos_costo CHECK (costo_produccion >= 0),
    CONSTRAINT chk_productos_precio_venta CHECK (precio_venta >= 0),
    CONSTRAINT chk_productos_cantidad CHECK (cantidad >= 0),
    UNIQUE KEY uq_productos_codigo (codigo),
    INDEX idx_productos_nombre (nombre),
    INDEX idx_productos_activo (activo, fec_eliminacion)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE ventas (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    fecha_venta DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    estado VARCHAR(30) NOT NULL DEFAULT 'completada',
    metodo_pago VARCHAR(50) NULL,
    subtotal DECIMAL(12,2) NOT NULL DEFAULT 0.00,
    descuento DECIMAL(12,2) NOT NULL DEFAULT 0.00,
    impuesto DECIMAL(12,2) NOT NULL DEFAULT 0.00,
    total DECIMAL(12,2) NOT NULL DEFAULT 0.00,
    observaciones TEXT NULL,
    fec_creacion TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    fec_actualizacion TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    fec_eliminacion TIMESTAMP NULL DEFAULT NULL,
    CONSTRAINT chk_ventas_subtotal CHECK (subtotal >= 0),
    CONSTRAINT chk_ventas_descuento CHECK (descuento >= 0),
    CONSTRAINT chk_ventas_impuesto CHECK (impuesto >= 0),
    CONSTRAINT chk_ventas_total CHECK (total >= 0),
    INDEX idx_ventas_fecha (fec_eliminacion, fecha_venta),
    INDEX idx_ventas_estado (estado)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE detalle_venta (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    venta_id BIGINT UNSIGNED NOT NULL,
    producto_id BIGINT UNSIGNED NULL,
    servicio_id BIGINT UNSIGNED NULL,
    nombre_item VARCHAR(150) NOT NULL,
    cantidad DECIMAL(12,2) NOT NULL DEFAULT 1.00,
    precio_unitario DECIMAL(10,2) NOT NULL DEFAULT 0.00,
    descuento DECIMAL(12,2) NOT NULL DEFAULT 0.00,
    subtotal DECIMAL(12,2) NOT NULL DEFAULT 0.00,
    fec_creacion TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    fec_actualizacion TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    fec_eliminacion TIMESTAMP NULL DEFAULT NULL,
    CONSTRAINT chk_detalle_cantidad CHECK (cantidad > 0),
    CONSTRAINT chk_detalle_precio CHECK (precio_unitario >= 0),
    CONSTRAINT chk_detalle_descuento CHECK (descuento >= 0),
    CONSTRAINT chk_detalle_subtotal CHECK (subtotal >= 0),
    CONSTRAINT fk_detalle_venta_venta FOREIGN KEY (venta_id)
        REFERENCES ventas(id) ON UPDATE CASCADE ON DELETE RESTRICT,
    CONSTRAINT fk_detalle_venta_producto FOREIGN KEY (producto_id)
        REFERENCES productos(id) ON UPDATE CASCADE ON DELETE RESTRICT,
    CONSTRAINT fk_detalle_venta_servicio FOREIGN KEY (servicio_id)
        REFERENCES servicios(id) ON UPDATE CASCADE ON DELETE RESTRICT,
    INDEX idx_detalle_venta (venta_id, fec_eliminacion),
    INDEX idx_detalle_producto (producto_id),
    INDEX idx_detalle_servicio (servicio_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE movimientos_inventario (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    producto_id BIGINT UNSIGNED NOT NULL,
    venta_id BIGINT UNSIGNED NULL,
    tipo VARCHAR(30) NOT NULL,
    cantidad DECIMAL(12,2) NOT NULL,
    motivo VARCHAR(255) NULL,
    fec_creacion TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    fec_actualizacion TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    fec_eliminacion TIMESTAMP NULL DEFAULT NULL,
    CONSTRAINT chk_movimiento_cantidad CHECK (cantidad > 0),
    CONSTRAINT fk_movimientos_producto FOREIGN KEY (producto_id)
        REFERENCES productos(id) ON UPDATE CASCADE ON DELETE RESTRICT,
    CONSTRAINT fk_movimientos_venta FOREIGN KEY (venta_id)
        REFERENCES ventas(id) ON UPDATE CASCADE ON DELETE RESTRICT,
    INDEX idx_movimientos_producto_fecha (producto_id, fec_creacion),
    INDEX idx_movimientos_venta (venta_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ================= BASE 15/26: db_emp_vinos_mm (Vinos M&M) =================

-- ============================================================
-- BASE DE DATOS OPERATIVA: db_emp_vinos_mm
-- EMPRENDIMIENTO: Vinos M&M
-- ============================================================
CREATE DATABASE IF NOT EXISTS `db_emp_vinos_mm`
    CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE `db_emp_vinos_mm`;

-- CREACION DE USUARIO DE BASE DE DATOS Y ASIGNACION DE PERMISOS
CREATE USER IF NOT EXISTS 'emp_vinos_mm'@'%' IDENTIFIED BY 'DbPass_vinos15';
GRANT ALL PRIVILEGES ON `db_emp_vinos_mm`.* TO 'emp_vinos_mm'@'%';
CREATE USER IF NOT EXISTS 'emp_vinos_mm'@'localhost' IDENTIFIED BY 'DbPass_vinos15';
GRANT ALL PRIVILEGES ON `db_emp_vinos_mm`.* TO 'emp_vinos_mm'@'localhost';
FLUSH PRIVILEGES;

SET FOREIGN_KEY_CHECKS = 0;
DROP TABLE IF EXISTS detalle_venta;
DROP TABLE IF EXISTS movimientos_inventario;
DROP TABLE IF EXISTS ventas;
DROP TABLE IF EXISTS productos;
DROP TABLE IF EXISTS servicios;
DROP TABLE IF EXISTS auditoria;
SET FOREIGN_KEY_CHECKS = 1;

CREATE TABLE auditoria (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    usuario_id BIGINT UNSIGNED NULL,
    accion VARCHAR(50) NOT NULL,
    tabla_afectada VARCHAR(100) NOT NULL,
    registro_id BIGINT UNSIGNED NULL,
    valores_anteriores JSON NULL,
    valores_nuevos JSON NULL,
    detalle TEXT NULL,
    direccion_ip VARCHAR(45) NULL,
    fec_creacion TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    fec_actualizacion TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    fec_eliminacion TIMESTAMP NULL DEFAULT NULL,
    INDEX idx_auditoria_usuario (usuario_id),
    INDEX idx_auditoria_tabla_registro (tabla_afectada, registro_id),
    INDEX idx_auditoria_fec_creacion (fec_creacion)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE servicios (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(150) NOT NULL,
    descripcion TEXT NULL,
    precio DECIMAL(10,2) NOT NULL DEFAULT 0.00,
    url_imagen VARCHAR(255) NULL,
    estado VARCHAR(30) NOT NULL DEFAULT 'activo',
    fecha_inicio DATE NULL,
    fecha_fin DATE NULL,
    fec_creacion TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    fec_actualizacion TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    fec_eliminacion TIMESTAMP NULL DEFAULT NULL,
    CONSTRAINT chk_servicios_precio CHECK (precio >= 0),
    CONSTRAINT chk_servicios_fechas CHECK (
        fecha_inicio IS NULL OR fecha_fin IS NULL OR fecha_fin >= fecha_inicio
    ),
    INDEX idx_servicios_nombre (nombre),
    INDEX idx_servicios_estado (estado, fec_eliminacion)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE productos (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    codigo VARCHAR(60) NULL,
    nombre VARCHAR(150) NOT NULL,
    descripcion TEXT NULL,
    cantidad INT NOT NULL DEFAULT 0,
    unidad_medida VARCHAR(50) NOT NULL DEFAULT 'unidad',
    categoria_unidad VARCHAR(100) NULL,
    costo_produccion DECIMAL(10,2) NOT NULL DEFAULT 0.00,
    precio_venta DECIMAL(10,2) NOT NULL DEFAULT 0.00,
    url_imagen VARCHAR(255) NULL,
    activo BOOLEAN NOT NULL DEFAULT TRUE,
    fec_creacion TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    fec_actualizacion TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    fec_eliminacion TIMESTAMP NULL DEFAULT NULL,
    CONSTRAINT chk_productos_costo CHECK (costo_produccion >= 0),
    CONSTRAINT chk_productos_precio_venta CHECK (precio_venta >= 0),
    CONSTRAINT chk_productos_cantidad CHECK (cantidad >= 0),
    UNIQUE KEY uq_productos_codigo (codigo),
    INDEX idx_productos_nombre (nombre),
    INDEX idx_productos_activo (activo, fec_eliminacion)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE ventas (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    fecha_venta DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    estado VARCHAR(30) NOT NULL DEFAULT 'completada',
    metodo_pago VARCHAR(50) NULL,
    subtotal DECIMAL(12,2) NOT NULL DEFAULT 0.00,
    descuento DECIMAL(12,2) NOT NULL DEFAULT 0.00,
    impuesto DECIMAL(12,2) NOT NULL DEFAULT 0.00,
    total DECIMAL(12,2) NOT NULL DEFAULT 0.00,
    observaciones TEXT NULL,
    fec_creacion TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    fec_actualizacion TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    fec_eliminacion TIMESTAMP NULL DEFAULT NULL,
    CONSTRAINT chk_ventas_subtotal CHECK (subtotal >= 0),
    CONSTRAINT chk_ventas_descuento CHECK (descuento >= 0),
    CONSTRAINT chk_ventas_impuesto CHECK (impuesto >= 0),
    CONSTRAINT chk_ventas_total CHECK (total >= 0),
    INDEX idx_ventas_fecha (fec_eliminacion, fecha_venta),
    INDEX idx_ventas_estado (estado)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE detalle_venta (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    venta_id BIGINT UNSIGNED NOT NULL,
    producto_id BIGINT UNSIGNED NULL,
    servicio_id BIGINT UNSIGNED NULL,
    nombre_item VARCHAR(150) NOT NULL,
    cantidad DECIMAL(12,2) NOT NULL DEFAULT 1.00,
    precio_unitario DECIMAL(10,2) NOT NULL DEFAULT 0.00,
    descuento DECIMAL(12,2) NOT NULL DEFAULT 0.00,
    subtotal DECIMAL(12,2) NOT NULL DEFAULT 0.00,
    fec_creacion TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    fec_actualizacion TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    fec_eliminacion TIMESTAMP NULL DEFAULT NULL,
    CONSTRAINT chk_detalle_cantidad CHECK (cantidad > 0),
    CONSTRAINT chk_detalle_precio CHECK (precio_unitario >= 0),
    CONSTRAINT chk_detalle_descuento CHECK (descuento >= 0),
    CONSTRAINT chk_detalle_subtotal CHECK (subtotal >= 0),
    CONSTRAINT fk_detalle_venta_venta FOREIGN KEY (venta_id)
        REFERENCES ventas(id) ON UPDATE CASCADE ON DELETE RESTRICT,
    CONSTRAINT fk_detalle_venta_producto FOREIGN KEY (producto_id)
        REFERENCES productos(id) ON UPDATE CASCADE ON DELETE RESTRICT,
    CONSTRAINT fk_detalle_venta_servicio FOREIGN KEY (servicio_id)
        REFERENCES servicios(id) ON UPDATE CASCADE ON DELETE RESTRICT,
    INDEX idx_detalle_venta (venta_id, fec_eliminacion),
    INDEX idx_detalle_producto (producto_id),
    INDEX idx_detalle_servicio (servicio_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE movimientos_inventario (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    producto_id BIGINT UNSIGNED NOT NULL,
    venta_id BIGINT UNSIGNED NULL,
    tipo VARCHAR(30) NOT NULL,
    cantidad DECIMAL(12,2) NOT NULL,
    motivo VARCHAR(255) NULL,
    fec_creacion TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    fec_actualizacion TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    fec_eliminacion TIMESTAMP NULL DEFAULT NULL,
    CONSTRAINT chk_movimiento_cantidad CHECK (cantidad > 0),
    CONSTRAINT fk_movimientos_producto FOREIGN KEY (producto_id)
        REFERENCES productos(id) ON UPDATE CASCADE ON DELETE RESTRICT,
    CONSTRAINT fk_movimientos_venta FOREIGN KEY (venta_id)
        REFERENCES ventas(id) ON UPDATE CASCADE ON DELETE RESTRICT,
    INDEX idx_movimientos_producto_fecha (producto_id, fec_creacion),
    INDEX idx_movimientos_venta (venta_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ================= BASE 16/26: db_emp_barros_nicole (Barros Nicole) =================

-- ============================================================
-- BASE DE DATOS OPERATIVA: db_emp_barros_nicole
-- EMPRENDIMIENTO: Barros Nicole
-- ============================================================
CREATE DATABASE IF NOT EXISTS `db_emp_barros_nicole`
    CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE `db_emp_barros_nicole`;

-- CREACION DE USUARIO DE BASE DE DATOS Y ASIGNACION DE PERMISOS
CREATE USER IF NOT EXISTS 'emp_barros_nicole'@'%' IDENTIFIED BY 'DbPass_barros16';
GRANT ALL PRIVILEGES ON `db_emp_barros_nicole`.* TO 'emp_barros_nicole'@'%';
CREATE USER IF NOT EXISTS 'emp_barros_nicole'@'localhost' IDENTIFIED BY 'DbPass_barros16';
GRANT ALL PRIVILEGES ON `db_emp_barros_nicole`.* TO 'emp_barros_nicole'@'localhost';
FLUSH PRIVILEGES;

SET FOREIGN_KEY_CHECKS = 0;
DROP TABLE IF EXISTS detalle_venta;
DROP TABLE IF EXISTS movimientos_inventario;
DROP TABLE IF EXISTS ventas;
DROP TABLE IF EXISTS productos;
DROP TABLE IF EXISTS servicios;
DROP TABLE IF EXISTS auditoria;
SET FOREIGN_KEY_CHECKS = 1;

CREATE TABLE auditoria (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    usuario_id BIGINT UNSIGNED NULL,
    accion VARCHAR(50) NOT NULL,
    tabla_afectada VARCHAR(100) NOT NULL,
    registro_id BIGINT UNSIGNED NULL,
    valores_anteriores JSON NULL,
    valores_nuevos JSON NULL,
    detalle TEXT NULL,
    direccion_ip VARCHAR(45) NULL,
    fec_creacion TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    fec_actualizacion TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    fec_eliminacion TIMESTAMP NULL DEFAULT NULL,
    INDEX idx_auditoria_usuario (usuario_id),
    INDEX idx_auditoria_tabla_registro (tabla_afectada, registro_id),
    INDEX idx_auditoria_fec_creacion (fec_creacion)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE servicios (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(150) NOT NULL,
    descripcion TEXT NULL,
    precio DECIMAL(10,2) NOT NULL DEFAULT 0.00,
    url_imagen VARCHAR(255) NULL,
    estado VARCHAR(30) NOT NULL DEFAULT 'activo',
    fecha_inicio DATE NULL,
    fecha_fin DATE NULL,
    fec_creacion TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    fec_actualizacion TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    fec_eliminacion TIMESTAMP NULL DEFAULT NULL,
    CONSTRAINT chk_servicios_precio CHECK (precio >= 0),
    CONSTRAINT chk_servicios_fechas CHECK (
        fecha_inicio IS NULL OR fecha_fin IS NULL OR fecha_fin >= fecha_inicio
    ),
    INDEX idx_servicios_nombre (nombre),
    INDEX idx_servicios_estado (estado, fec_eliminacion)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE productos (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    codigo VARCHAR(60) NULL,
    nombre VARCHAR(150) NOT NULL,
    descripcion TEXT NULL,
    cantidad INT NOT NULL DEFAULT 0,
    unidad_medida VARCHAR(50) NOT NULL DEFAULT 'unidad',
    categoria_unidad VARCHAR(100) NULL,
    costo_produccion DECIMAL(10,2) NOT NULL DEFAULT 0.00,
    precio_venta DECIMAL(10,2) NOT NULL DEFAULT 0.00,
    url_imagen VARCHAR(255) NULL,
    activo BOOLEAN NOT NULL DEFAULT TRUE,
    fec_creacion TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    fec_actualizacion TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    fec_eliminacion TIMESTAMP NULL DEFAULT NULL,
    CONSTRAINT chk_productos_costo CHECK (costo_produccion >= 0),
    CONSTRAINT chk_productos_precio_venta CHECK (precio_venta >= 0),
    CONSTRAINT chk_productos_cantidad CHECK (cantidad >= 0),
    UNIQUE KEY uq_productos_codigo (codigo),
    INDEX idx_productos_nombre (nombre),
    INDEX idx_productos_activo (activo, fec_eliminacion)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE ventas (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    fecha_venta DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    estado VARCHAR(30) NOT NULL DEFAULT 'completada',
    metodo_pago VARCHAR(50) NULL,
    subtotal DECIMAL(12,2) NOT NULL DEFAULT 0.00,
    descuento DECIMAL(12,2) NOT NULL DEFAULT 0.00,
    impuesto DECIMAL(12,2) NOT NULL DEFAULT 0.00,
    total DECIMAL(12,2) NOT NULL DEFAULT 0.00,
    observaciones TEXT NULL,
    fec_creacion TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    fec_actualizacion TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    fec_eliminacion TIMESTAMP NULL DEFAULT NULL,
    CONSTRAINT chk_ventas_subtotal CHECK (subtotal >= 0),
    CONSTRAINT chk_ventas_descuento CHECK (descuento >= 0),
    CONSTRAINT chk_ventas_impuesto CHECK (impuesto >= 0),
    CONSTRAINT chk_ventas_total CHECK (total >= 0),
    INDEX idx_ventas_fecha (fec_eliminacion, fecha_venta),
    INDEX idx_ventas_estado (estado)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE detalle_venta (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    venta_id BIGINT UNSIGNED NOT NULL,
    producto_id BIGINT UNSIGNED NULL,
    servicio_id BIGINT UNSIGNED NULL,
    nombre_item VARCHAR(150) NOT NULL,
    cantidad DECIMAL(12,2) NOT NULL DEFAULT 1.00,
    precio_unitario DECIMAL(10,2) NOT NULL DEFAULT 0.00,
    descuento DECIMAL(12,2) NOT NULL DEFAULT 0.00,
    subtotal DECIMAL(12,2) NOT NULL DEFAULT 0.00,
    fec_creacion TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    fec_actualizacion TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    fec_eliminacion TIMESTAMP NULL DEFAULT NULL,
    CONSTRAINT chk_detalle_cantidad CHECK (cantidad > 0),
    CONSTRAINT chk_detalle_precio CHECK (precio_unitario >= 0),
    CONSTRAINT chk_detalle_descuento CHECK (descuento >= 0),
    CONSTRAINT chk_detalle_subtotal CHECK (subtotal >= 0),
    CONSTRAINT fk_detalle_venta_venta FOREIGN KEY (venta_id)
        REFERENCES ventas(id) ON UPDATE CASCADE ON DELETE RESTRICT,
    CONSTRAINT fk_detalle_venta_producto FOREIGN KEY (producto_id)
        REFERENCES productos(id) ON UPDATE CASCADE ON DELETE RESTRICT,
    CONSTRAINT fk_detalle_venta_servicio FOREIGN KEY (servicio_id)
        REFERENCES servicios(id) ON UPDATE CASCADE ON DELETE RESTRICT,
    INDEX idx_detalle_venta (venta_id, fec_eliminacion),
    INDEX idx_detalle_producto (producto_id),
    INDEX idx_detalle_servicio (servicio_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE movimientos_inventario (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    producto_id BIGINT UNSIGNED NOT NULL,
    venta_id BIGINT UNSIGNED NULL,
    tipo VARCHAR(30) NOT NULL,
    cantidad DECIMAL(12,2) NOT NULL,
    motivo VARCHAR(255) NULL,
    fec_creacion TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    fec_actualizacion TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    fec_eliminacion TIMESTAMP NULL DEFAULT NULL,
    CONSTRAINT chk_movimiento_cantidad CHECK (cantidad > 0),
    CONSTRAINT fk_movimientos_producto FOREIGN KEY (producto_id)
        REFERENCES productos(id) ON UPDATE CASCADE ON DELETE RESTRICT,
    CONSTRAINT fk_movimientos_venta FOREIGN KEY (venta_id)
        REFERENCES ventas(id) ON UPDATE CASCADE ON DELETE RESTRICT,
    INDEX idx_movimientos_producto_fecha (producto_id, fec_creacion),
    INDEX idx_movimientos_venta (venta_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ================= BASE 17/26: db_emp_vinos_mopocita (Vinos Mopocita) =================

-- ============================================================
-- BASE DE DATOS OPERATIVA: db_emp_vinos_mopocita
-- EMPRENDIMIENTO: Vinos Mopocita
-- ============================================================
CREATE DATABASE IF NOT EXISTS `db_emp_vinos_mopocita`
    CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE `db_emp_vinos_mopocita`;

-- CREACION DE USUARIO DE BASE DE DATOS Y ASIGNACION DE PERMISOS
CREATE USER IF NOT EXISTS 'emp_vinos_mopocita'@'%' IDENTIFIED BY 'DbPass_vinos17';
GRANT ALL PRIVILEGES ON `db_emp_vinos_mopocita`.* TO 'emp_vinos_mopocita'@'%';
CREATE USER IF NOT EXISTS 'emp_vinos_mopocita'@'localhost' IDENTIFIED BY 'DbPass_vinos17';
GRANT ALL PRIVILEGES ON `db_emp_vinos_mopocita`.* TO 'emp_vinos_mopocita'@'localhost';
FLUSH PRIVILEGES;

SET FOREIGN_KEY_CHECKS = 0;
DROP TABLE IF EXISTS detalle_venta;
DROP TABLE IF EXISTS movimientos_inventario;
DROP TABLE IF EXISTS ventas;
DROP TABLE IF EXISTS productos;
DROP TABLE IF EXISTS servicios;
DROP TABLE IF EXISTS auditoria;
SET FOREIGN_KEY_CHECKS = 1;

CREATE TABLE auditoria (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    usuario_id BIGINT UNSIGNED NULL,
    accion VARCHAR(50) NOT NULL,
    tabla_afectada VARCHAR(100) NOT NULL,
    registro_id BIGINT UNSIGNED NULL,
    valores_anteriores JSON NULL,
    valores_nuevos JSON NULL,
    detalle TEXT NULL,
    direccion_ip VARCHAR(45) NULL,
    fec_creacion TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    fec_actualizacion TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    fec_eliminacion TIMESTAMP NULL DEFAULT NULL,
    INDEX idx_auditoria_usuario (usuario_id),
    INDEX idx_auditoria_tabla_registro (tabla_afectada, registro_id),
    INDEX idx_auditoria_fec_creacion (fec_creacion)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE servicios (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(150) NOT NULL,
    descripcion TEXT NULL,
    precio DECIMAL(10,2) NOT NULL DEFAULT 0.00,
    url_imagen VARCHAR(255) NULL,
    estado VARCHAR(30) NOT NULL DEFAULT 'activo',
    fecha_inicio DATE NULL,
    fecha_fin DATE NULL,
    fec_creacion TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    fec_actualizacion TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    fec_eliminacion TIMESTAMP NULL DEFAULT NULL,
    CONSTRAINT chk_servicios_precio CHECK (precio >= 0),
    CONSTRAINT chk_servicios_fechas CHECK (
        fecha_inicio IS NULL OR fecha_fin IS NULL OR fecha_fin >= fecha_inicio
    ),
    INDEX idx_servicios_nombre (nombre),
    INDEX idx_servicios_estado (estado, fec_eliminacion)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE productos (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    codigo VARCHAR(60) NULL,
    nombre VARCHAR(150) NOT NULL,
    descripcion TEXT NULL,
    cantidad INT NOT NULL DEFAULT 0,
    unidad_medida VARCHAR(50) NOT NULL DEFAULT 'unidad',
    categoria_unidad VARCHAR(100) NULL,
    costo_produccion DECIMAL(10,2) NOT NULL DEFAULT 0.00,
    precio_venta DECIMAL(10,2) NOT NULL DEFAULT 0.00,
    url_imagen VARCHAR(255) NULL,
    activo BOOLEAN NOT NULL DEFAULT TRUE,
    fec_creacion TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    fec_actualizacion TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    fec_eliminacion TIMESTAMP NULL DEFAULT NULL,
    CONSTRAINT chk_productos_costo CHECK (costo_produccion >= 0),
    CONSTRAINT chk_productos_precio_venta CHECK (precio_venta >= 0),
    CONSTRAINT chk_productos_cantidad CHECK (cantidad >= 0),
    UNIQUE KEY uq_productos_codigo (codigo),
    INDEX idx_productos_nombre (nombre),
    INDEX idx_productos_activo (activo, fec_eliminacion)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE ventas (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    fecha_venta DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    estado VARCHAR(30) NOT NULL DEFAULT 'completada',
    metodo_pago VARCHAR(50) NULL,
    subtotal DECIMAL(12,2) NOT NULL DEFAULT 0.00,
    descuento DECIMAL(12,2) NOT NULL DEFAULT 0.00,
    impuesto DECIMAL(12,2) NOT NULL DEFAULT 0.00,
    total DECIMAL(12,2) NOT NULL DEFAULT 0.00,
    observaciones TEXT NULL,
    fec_creacion TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    fec_actualizacion TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    fec_eliminacion TIMESTAMP NULL DEFAULT NULL,
    CONSTRAINT chk_ventas_subtotal CHECK (subtotal >= 0),
    CONSTRAINT chk_ventas_descuento CHECK (descuento >= 0),
    CONSTRAINT chk_ventas_impuesto CHECK (impuesto >= 0),
    CONSTRAINT chk_ventas_total CHECK (total >= 0),
    INDEX idx_ventas_fecha (fec_eliminacion, fecha_venta),
    INDEX idx_ventas_estado (estado)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE detalle_venta (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    venta_id BIGINT UNSIGNED NOT NULL,
    producto_id BIGINT UNSIGNED NULL,
    servicio_id BIGINT UNSIGNED NULL,
    nombre_item VARCHAR(150) NOT NULL,
    cantidad DECIMAL(12,2) NOT NULL DEFAULT 1.00,
    precio_unitario DECIMAL(10,2) NOT NULL DEFAULT 0.00,
    descuento DECIMAL(12,2) NOT NULL DEFAULT 0.00,
    subtotal DECIMAL(12,2) NOT NULL DEFAULT 0.00,
    fec_creacion TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    fec_actualizacion TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    fec_eliminacion TIMESTAMP NULL DEFAULT NULL,
    CONSTRAINT chk_detalle_cantidad CHECK (cantidad > 0),
    CONSTRAINT chk_detalle_precio CHECK (precio_unitario >= 0),
    CONSTRAINT chk_detalle_descuento CHECK (descuento >= 0),
    CONSTRAINT chk_detalle_subtotal CHECK (subtotal >= 0),
    CONSTRAINT fk_detalle_venta_venta FOREIGN KEY (venta_id)
        REFERENCES ventas(id) ON UPDATE CASCADE ON DELETE RESTRICT,
    CONSTRAINT fk_detalle_venta_producto FOREIGN KEY (producto_id)
        REFERENCES productos(id) ON UPDATE CASCADE ON DELETE RESTRICT,
    CONSTRAINT fk_detalle_venta_servicio FOREIGN KEY (servicio_id)
        REFERENCES servicios(id) ON UPDATE CASCADE ON DELETE RESTRICT,
    INDEX idx_detalle_venta (venta_id, fec_eliminacion),
    INDEX idx_detalle_producto (producto_id),
    INDEX idx_detalle_servicio (servicio_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE movimientos_inventario (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    producto_id BIGINT UNSIGNED NOT NULL,
    venta_id BIGINT UNSIGNED NULL,
    tipo VARCHAR(30) NOT NULL,
    cantidad DECIMAL(12,2) NOT NULL,
    motivo VARCHAR(255) NULL,
    fec_creacion TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    fec_actualizacion TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    fec_eliminacion TIMESTAMP NULL DEFAULT NULL,
    CONSTRAINT chk_movimiento_cantidad CHECK (cantidad > 0),
    CONSTRAINT fk_movimientos_producto FOREIGN KEY (producto_id)
        REFERENCES productos(id) ON UPDATE CASCADE ON DELETE RESTRICT,
    CONSTRAINT fk_movimientos_venta FOREIGN KEY (venta_id)
        REFERENCES ventas(id) ON UPDATE CASCADE ON DELETE RESTRICT,
    INDEX idx_movimientos_producto_fecha (producto_id, fec_creacion),
    INDEX idx_movimientos_venta (venta_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ================= BASE 18/26: db_emp_vinos_don_bolo (Vinos y Miel de Abeja Don Bolo) =================

-- ============================================================
-- BASE DE DATOS OPERATIVA: db_emp_vinos_don_bolo
-- EMPRENDIMIENTO: Vinos y Miel de Abeja Don Bolo
-- ============================================================
CREATE DATABASE IF NOT EXISTS `db_emp_vinos_don_bolo`
    CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE `db_emp_vinos_don_bolo`;

-- CREACION DE USUARIO DE BASE DE DATOS Y ASIGNACION DE PERMISOS
CREATE USER IF NOT EXISTS 'emp_vinos_don_bolo'@'%' IDENTIFIED BY 'DbPass_vinos18';
GRANT ALL PRIVILEGES ON `db_emp_vinos_don_bolo`.* TO 'emp_vinos_don_bolo'@'%';
CREATE USER IF NOT EXISTS 'emp_vinos_don_bolo'@'localhost' IDENTIFIED BY 'DbPass_vinos18';
GRANT ALL PRIVILEGES ON `db_emp_vinos_don_bolo`.* TO 'emp_vinos_don_bolo'@'localhost';
FLUSH PRIVILEGES;

SET FOREIGN_KEY_CHECKS = 0;
DROP TABLE IF EXISTS detalle_venta;
DROP TABLE IF EXISTS movimientos_inventario;
DROP TABLE IF EXISTS ventas;
DROP TABLE IF EXISTS productos;
DROP TABLE IF EXISTS servicios;
DROP TABLE IF EXISTS auditoria;
SET FOREIGN_KEY_CHECKS = 1;

CREATE TABLE auditoria (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    usuario_id BIGINT UNSIGNED NULL,
    accion VARCHAR(50) NOT NULL,
    tabla_afectada VARCHAR(100) NOT NULL,
    registro_id BIGINT UNSIGNED NULL,
    valores_anteriores JSON NULL,
    valores_nuevos JSON NULL,
    detalle TEXT NULL,
    direccion_ip VARCHAR(45) NULL,
    fec_creacion TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    fec_actualizacion TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    fec_eliminacion TIMESTAMP NULL DEFAULT NULL,
    INDEX idx_auditoria_usuario (usuario_id),
    INDEX idx_auditoria_tabla_registro (tabla_afectada, registro_id),
    INDEX idx_auditoria_fec_creacion (fec_creacion)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE servicios (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(150) NOT NULL,
    descripcion TEXT NULL,
    precio DECIMAL(10,2) NOT NULL DEFAULT 0.00,
    url_imagen VARCHAR(255) NULL,
    estado VARCHAR(30) NOT NULL DEFAULT 'activo',
    fecha_inicio DATE NULL,
    fecha_fin DATE NULL,
    fec_creacion TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    fec_actualizacion TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    fec_eliminacion TIMESTAMP NULL DEFAULT NULL,
    CONSTRAINT chk_servicios_precio CHECK (precio >= 0),
    CONSTRAINT chk_servicios_fechas CHECK (
        fecha_inicio IS NULL OR fecha_fin IS NULL OR fecha_fin >= fecha_inicio
    ),
    INDEX idx_servicios_nombre (nombre),
    INDEX idx_servicios_estado (estado, fec_eliminacion)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE productos (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    codigo VARCHAR(60) NULL,
    nombre VARCHAR(150) NOT NULL,
    descripcion TEXT NULL,
    cantidad INT NOT NULL DEFAULT 0,
    unidad_medida VARCHAR(50) NOT NULL DEFAULT 'unidad',
    categoria_unidad VARCHAR(100) NULL,
    costo_produccion DECIMAL(10,2) NOT NULL DEFAULT 0.00,
    precio_venta DECIMAL(10,2) NOT NULL DEFAULT 0.00,
    url_imagen VARCHAR(255) NULL,
    activo BOOLEAN NOT NULL DEFAULT TRUE,
    fec_creacion TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    fec_actualizacion TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    fec_eliminacion TIMESTAMP NULL DEFAULT NULL,
    CONSTRAINT chk_productos_costo CHECK (costo_produccion >= 0),
    CONSTRAINT chk_productos_precio_venta CHECK (precio_venta >= 0),
    CONSTRAINT chk_productos_cantidad CHECK (cantidad >= 0),
    UNIQUE KEY uq_productos_codigo (codigo),
    INDEX idx_productos_nombre (nombre),
    INDEX idx_productos_activo (activo, fec_eliminacion)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE ventas (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    fecha_venta DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    estado VARCHAR(30) NOT NULL DEFAULT 'completada',
    metodo_pago VARCHAR(50) NULL,
    subtotal DECIMAL(12,2) NOT NULL DEFAULT 0.00,
    descuento DECIMAL(12,2) NOT NULL DEFAULT 0.00,
    impuesto DECIMAL(12,2) NOT NULL DEFAULT 0.00,
    total DECIMAL(12,2) NOT NULL DEFAULT 0.00,
    observaciones TEXT NULL,
    fec_creacion TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    fec_actualizacion TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    fec_eliminacion TIMESTAMP NULL DEFAULT NULL,
    CONSTRAINT chk_ventas_subtotal CHECK (subtotal >= 0),
    CONSTRAINT chk_ventas_descuento CHECK (descuento >= 0),
    CONSTRAINT chk_ventas_impuesto CHECK (impuesto >= 0),
    CONSTRAINT chk_ventas_total CHECK (total >= 0),
    INDEX idx_ventas_fecha (fec_eliminacion, fecha_venta),
    INDEX idx_ventas_estado (estado)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE detalle_venta (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    venta_id BIGINT UNSIGNED NOT NULL,
    producto_id BIGINT UNSIGNED NULL,
    servicio_id BIGINT UNSIGNED NULL,
    nombre_item VARCHAR(150) NOT NULL,
    cantidad DECIMAL(12,2) NOT NULL DEFAULT 1.00,
    precio_unitario DECIMAL(10,2) NOT NULL DEFAULT 0.00,
    descuento DECIMAL(12,2) NOT NULL DEFAULT 0.00,
    subtotal DECIMAL(12,2) NOT NULL DEFAULT 0.00,
    fec_creacion TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    fec_actualizacion TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    fec_eliminacion TIMESTAMP NULL DEFAULT NULL,
    CONSTRAINT chk_detalle_cantidad CHECK (cantidad > 0),
    CONSTRAINT chk_detalle_precio CHECK (precio_unitario >= 0),
    CONSTRAINT chk_detalle_descuento CHECK (descuento >= 0),
    CONSTRAINT chk_detalle_subtotal CHECK (subtotal >= 0),
    CONSTRAINT fk_detalle_venta_venta FOREIGN KEY (venta_id)
        REFERENCES ventas(id) ON UPDATE CASCADE ON DELETE RESTRICT,
    CONSTRAINT fk_detalle_venta_producto FOREIGN KEY (producto_id)
        REFERENCES productos(id) ON UPDATE CASCADE ON DELETE RESTRICT,
    CONSTRAINT fk_detalle_venta_servicio FOREIGN KEY (servicio_id)
        REFERENCES servicios(id) ON UPDATE CASCADE ON DELETE RESTRICT,
    INDEX idx_detalle_venta (venta_id, fec_eliminacion),
    INDEX idx_detalle_producto (producto_id),
    INDEX idx_detalle_servicio (servicio_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE movimientos_inventario (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    producto_id BIGINT UNSIGNED NOT NULL,
    venta_id BIGINT UNSIGNED NULL,
    tipo VARCHAR(30) NOT NULL,
    cantidad DECIMAL(12,2) NOT NULL,
    motivo VARCHAR(255) NULL,
    fec_creacion TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    fec_actualizacion TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    fec_eliminacion TIMESTAMP NULL DEFAULT NULL,
    CONSTRAINT chk_movimiento_cantidad CHECK (cantidad > 0),
    CONSTRAINT fk_movimientos_producto FOREIGN KEY (producto_id)
        REFERENCES productos(id) ON UPDATE CASCADE ON DELETE RESTRICT,
    CONSTRAINT fk_movimientos_venta FOREIGN KEY (venta_id)
        REFERENCES ventas(id) ON UPDATE CASCADE ON DELETE RESTRICT,
    INDEX idx_movimientos_producto_fecha (producto_id, fec_creacion),
    INDEX idx_movimientos_venta (venta_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ================= BASE 19/26: db_emp_granja_san_jose (Granja Ecológica San José) =================

-- ============================================================
-- BASE DE DATOS OPERATIVA: db_emp_granja_san_jose
-- EMPRENDIMIENTO: Granja Ecológica San José
-- ============================================================
CREATE DATABASE IF NOT EXISTS `db_emp_granja_san_jose`
    CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE `db_emp_granja_san_jose`;

-- CREACION DE USUARIO DE BASE DE DATOS Y ASIGNACION DE PERMISOS
CREATE USER IF NOT EXISTS 'emp_granja_san_jose'@'%' IDENTIFIED BY 'DbPass_granja19';
GRANT ALL PRIVILEGES ON `db_emp_granja_san_jose`.* TO 'emp_granja_san_jose'@'%';
CREATE USER IF NOT EXISTS 'emp_granja_san_jose'@'localhost' IDENTIFIED BY 'DbPass_granja19';
GRANT ALL PRIVILEGES ON `db_emp_granja_san_jose`.* TO 'emp_granja_san_jose'@'localhost';
FLUSH PRIVILEGES;

SET FOREIGN_KEY_CHECKS = 0;
DROP TABLE IF EXISTS detalle_venta;
DROP TABLE IF EXISTS movimientos_inventario;
DROP TABLE IF EXISTS ventas;
DROP TABLE IF EXISTS productos;
DROP TABLE IF EXISTS servicios;
DROP TABLE IF EXISTS auditoria;
SET FOREIGN_KEY_CHECKS = 1;

CREATE TABLE auditoria (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    usuario_id BIGINT UNSIGNED NULL,
    accion VARCHAR(50) NOT NULL,
    tabla_afectada VARCHAR(100) NOT NULL,
    registro_id BIGINT UNSIGNED NULL,
    valores_anteriores JSON NULL,
    valores_nuevos JSON NULL,
    detalle TEXT NULL,
    direccion_ip VARCHAR(45) NULL,
    fec_creacion TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    fec_actualizacion TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    fec_eliminacion TIMESTAMP NULL DEFAULT NULL,
    INDEX idx_auditoria_usuario (usuario_id),
    INDEX idx_auditoria_tabla_registro (tabla_afectada, registro_id),
    INDEX idx_auditoria_fec_creacion (fec_creacion)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE servicios (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(150) NOT NULL,
    descripcion TEXT NULL,
    precio DECIMAL(10,2) NOT NULL DEFAULT 0.00,
    url_imagen VARCHAR(255) NULL,
    estado VARCHAR(30) NOT NULL DEFAULT 'activo',
    fecha_inicio DATE NULL,
    fecha_fin DATE NULL,
    fec_creacion TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    fec_actualizacion TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    fec_eliminacion TIMESTAMP NULL DEFAULT NULL,
    CONSTRAINT chk_servicios_precio CHECK (precio >= 0),
    CONSTRAINT chk_servicios_fechas CHECK (
        fecha_inicio IS NULL OR fecha_fin IS NULL OR fecha_fin >= fecha_inicio
    ),
    INDEX idx_servicios_nombre (nombre),
    INDEX idx_servicios_estado (estado, fec_eliminacion)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE productos (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    codigo VARCHAR(60) NULL,
    nombre VARCHAR(150) NOT NULL,
    descripcion TEXT NULL,
    cantidad INT NOT NULL DEFAULT 0,
    unidad_medida VARCHAR(50) NOT NULL DEFAULT 'unidad',
    categoria_unidad VARCHAR(100) NULL,
    costo_produccion DECIMAL(10,2) NOT NULL DEFAULT 0.00,
    precio_venta DECIMAL(10,2) NOT NULL DEFAULT 0.00,
    url_imagen VARCHAR(255) NULL,
    activo BOOLEAN NOT NULL DEFAULT TRUE,
    fec_creacion TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    fec_actualizacion TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    fec_eliminacion TIMESTAMP NULL DEFAULT NULL,
    CONSTRAINT chk_productos_costo CHECK (costo_produccion >= 0),
    CONSTRAINT chk_productos_precio_venta CHECK (precio_venta >= 0),
    CONSTRAINT chk_productos_cantidad CHECK (cantidad >= 0),
    UNIQUE KEY uq_productos_codigo (codigo),
    INDEX idx_productos_nombre (nombre),
    INDEX idx_productos_activo (activo, fec_eliminacion)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE ventas (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    fecha_venta DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    estado VARCHAR(30) NOT NULL DEFAULT 'completada',
    metodo_pago VARCHAR(50) NULL,
    subtotal DECIMAL(12,2) NOT NULL DEFAULT 0.00,
    descuento DECIMAL(12,2) NOT NULL DEFAULT 0.00,
    impuesto DECIMAL(12,2) NOT NULL DEFAULT 0.00,
    total DECIMAL(12,2) NOT NULL DEFAULT 0.00,
    observaciones TEXT NULL,
    fec_creacion TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    fec_actualizacion TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    fec_eliminacion TIMESTAMP NULL DEFAULT NULL,
    CONSTRAINT chk_ventas_subtotal CHECK (subtotal >= 0),
    CONSTRAINT chk_ventas_descuento CHECK (descuento >= 0),
    CONSTRAINT chk_ventas_impuesto CHECK (impuesto >= 0),
    CONSTRAINT chk_ventas_total CHECK (total >= 0),
    INDEX idx_ventas_fecha (fec_eliminacion, fecha_venta),
    INDEX idx_ventas_estado (estado)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE detalle_venta (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    venta_id BIGINT UNSIGNED NOT NULL,
    producto_id BIGINT UNSIGNED NULL,
    servicio_id BIGINT UNSIGNED NULL,
    nombre_item VARCHAR(150) NOT NULL,
    cantidad DECIMAL(12,2) NOT NULL DEFAULT 1.00,
    precio_unitario DECIMAL(10,2) NOT NULL DEFAULT 0.00,
    descuento DECIMAL(12,2) NOT NULL DEFAULT 0.00,
    subtotal DECIMAL(12,2) NOT NULL DEFAULT 0.00,
    fec_creacion TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    fec_actualizacion TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    fec_eliminacion TIMESTAMP NULL DEFAULT NULL,
    CONSTRAINT chk_detalle_cantidad CHECK (cantidad > 0),
    CONSTRAINT chk_detalle_precio CHECK (precio_unitario >= 0),
    CONSTRAINT chk_detalle_descuento CHECK (descuento >= 0),
    CONSTRAINT chk_detalle_subtotal CHECK (subtotal >= 0),
    CONSTRAINT fk_detalle_venta_venta FOREIGN KEY (venta_id)
        REFERENCES ventas(id) ON UPDATE CASCADE ON DELETE RESTRICT,
    CONSTRAINT fk_detalle_venta_producto FOREIGN KEY (producto_id)
        REFERENCES productos(id) ON UPDATE CASCADE ON DELETE RESTRICT,
    CONSTRAINT fk_detalle_venta_servicio FOREIGN KEY (servicio_id)
        REFERENCES servicios(id) ON UPDATE CASCADE ON DELETE RESTRICT,
    INDEX idx_detalle_venta (venta_id, fec_eliminacion),
    INDEX idx_detalle_producto (producto_id),
    INDEX idx_detalle_servicio (servicio_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE movimientos_inventario (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    producto_id BIGINT UNSIGNED NOT NULL,
    venta_id BIGINT UNSIGNED NULL,
    tipo VARCHAR(30) NOT NULL,
    cantidad DECIMAL(12,2) NOT NULL,
    motivo VARCHAR(255) NULL,
    fec_creacion TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    fec_actualizacion TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    fec_eliminacion TIMESTAMP NULL DEFAULT NULL,
    CONSTRAINT chk_movimiento_cantidad CHECK (cantidad > 0),
    CONSTRAINT fk_movimientos_producto FOREIGN KEY (producto_id)
        REFERENCES productos(id) ON UPDATE CASCADE ON DELETE RESTRICT,
    CONSTRAINT fk_movimientos_venta FOREIGN KEY (venta_id)
        REFERENCES ventas(id) ON UPDATE CASCADE ON DELETE RESTRICT,
    INDEX idx_movimientos_producto_fecha (producto_id, fec_creacion),
    INDEX idx_movimientos_venta (venta_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ================= BASE 20/26: db_emp_museo_santa_lucia (Museo Santa Lucía) =================

-- ============================================================
-- BASE DE DATOS OPERATIVA: db_emp_museo_santa_lucia
-- EMPRENDIMIENTO: Museo Santa Lucía
-- ============================================================
CREATE DATABASE IF NOT EXISTS `db_emp_museo_santa_lucia`
    CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE `db_emp_museo_santa_lucia`;

-- CREACION DE USUARIO DE BASE DE DATOS Y ASIGNACION DE PERMISOS
CREATE USER IF NOT EXISTS 'emp_museo_santa_lucia'@'%' IDENTIFIED BY 'DbPass_museo20';
GRANT ALL PRIVILEGES ON `db_emp_museo_santa_lucia`.* TO 'emp_museo_santa_lucia'@'%';
CREATE USER IF NOT EXISTS 'emp_museo_santa_lucia'@'localhost' IDENTIFIED BY 'DbPass_museo20';
GRANT ALL PRIVILEGES ON `db_emp_museo_santa_lucia`.* TO 'emp_museo_santa_lucia'@'localhost';
FLUSH PRIVILEGES;

SET FOREIGN_KEY_CHECKS = 0;
DROP TABLE IF EXISTS detalle_venta;
DROP TABLE IF EXISTS movimientos_inventario;
DROP TABLE IF EXISTS ventas;
DROP TABLE IF EXISTS productos;
DROP TABLE IF EXISTS servicios;
DROP TABLE IF EXISTS auditoria;
SET FOREIGN_KEY_CHECKS = 1;

CREATE TABLE auditoria (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    usuario_id BIGINT UNSIGNED NULL,
    accion VARCHAR(50) NOT NULL,
    tabla_afectada VARCHAR(100) NOT NULL,
    registro_id BIGINT UNSIGNED NULL,
    valores_anteriores JSON NULL,
    valores_nuevos JSON NULL,
    detalle TEXT NULL,
    direccion_ip VARCHAR(45) NULL,
    fec_creacion TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    fec_actualizacion TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    fec_eliminacion TIMESTAMP NULL DEFAULT NULL,
    INDEX idx_auditoria_usuario (usuario_id),
    INDEX idx_auditoria_tabla_registro (tabla_afectada, registro_id),
    INDEX idx_auditoria_fec_creacion (fec_creacion)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE servicios (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(150) NOT NULL,
    descripcion TEXT NULL,
    precio DECIMAL(10,2) NOT NULL DEFAULT 0.00,
    url_imagen VARCHAR(255) NULL,
    estado VARCHAR(30) NOT NULL DEFAULT 'activo',
    fecha_inicio DATE NULL,
    fecha_fin DATE NULL,
    fec_creacion TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    fec_actualizacion TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    fec_eliminacion TIMESTAMP NULL DEFAULT NULL,
    CONSTRAINT chk_servicios_precio CHECK (precio >= 0),
    CONSTRAINT chk_servicios_fechas CHECK (
        fecha_inicio IS NULL OR fecha_fin IS NULL OR fecha_fin >= fecha_inicio
    ),
    INDEX idx_servicios_nombre (nombre),
    INDEX idx_servicios_estado (estado, fec_eliminacion)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE productos (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    codigo VARCHAR(60) NULL,
    nombre VARCHAR(150) NOT NULL,
    descripcion TEXT NULL,
    cantidad INT NOT NULL DEFAULT 0,
    unidad_medida VARCHAR(50) NOT NULL DEFAULT 'unidad',
    categoria_unidad VARCHAR(100) NULL,
    costo_produccion DECIMAL(10,2) NOT NULL DEFAULT 0.00,
    precio_venta DECIMAL(10,2) NOT NULL DEFAULT 0.00,
    url_imagen VARCHAR(255) NULL,
    activo BOOLEAN NOT NULL DEFAULT TRUE,
    fec_creacion TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    fec_actualizacion TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    fec_eliminacion TIMESTAMP NULL DEFAULT NULL,
    CONSTRAINT chk_productos_costo CHECK (costo_produccion >= 0),
    CONSTRAINT chk_productos_precio_venta CHECK (precio_venta >= 0),
    CONSTRAINT chk_productos_cantidad CHECK (cantidad >= 0),
    UNIQUE KEY uq_productos_codigo (codigo),
    INDEX idx_productos_nombre (nombre),
    INDEX idx_productos_activo (activo, fec_eliminacion)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE ventas (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    fecha_venta DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    estado VARCHAR(30) NOT NULL DEFAULT 'completada',
    metodo_pago VARCHAR(50) NULL,
    subtotal DECIMAL(12,2) NOT NULL DEFAULT 0.00,
    descuento DECIMAL(12,2) NOT NULL DEFAULT 0.00,
    impuesto DECIMAL(12,2) NOT NULL DEFAULT 0.00,
    total DECIMAL(12,2) NOT NULL DEFAULT 0.00,
    observaciones TEXT NULL,
    fec_creacion TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    fec_actualizacion TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    fec_eliminacion TIMESTAMP NULL DEFAULT NULL,
    CONSTRAINT chk_ventas_subtotal CHECK (subtotal >= 0),
    CONSTRAINT chk_ventas_descuento CHECK (descuento >= 0),
    CONSTRAINT chk_ventas_impuesto CHECK (impuesto >= 0),
    CONSTRAINT chk_ventas_total CHECK (total >= 0),
    INDEX idx_ventas_fecha (fec_eliminacion, fecha_venta),
    INDEX idx_ventas_estado (estado)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE detalle_venta (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    venta_id BIGINT UNSIGNED NOT NULL,
    producto_id BIGINT UNSIGNED NULL,
    servicio_id BIGINT UNSIGNED NULL,
    nombre_item VARCHAR(150) NOT NULL,
    cantidad DECIMAL(12,2) NOT NULL DEFAULT 1.00,
    precio_unitario DECIMAL(10,2) NOT NULL DEFAULT 0.00,
    descuento DECIMAL(12,2) NOT NULL DEFAULT 0.00,
    subtotal DECIMAL(12,2) NOT NULL DEFAULT 0.00,
    fec_creacion TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    fec_actualizacion TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    fec_eliminacion TIMESTAMP NULL DEFAULT NULL,
    CONSTRAINT chk_detalle_cantidad CHECK (cantidad > 0),
    CONSTRAINT chk_detalle_precio CHECK (precio_unitario >= 0),
    CONSTRAINT chk_detalle_descuento CHECK (descuento >= 0),
    CONSTRAINT chk_detalle_subtotal CHECK (subtotal >= 0),
    CONSTRAINT fk_detalle_venta_venta FOREIGN KEY (venta_id)
        REFERENCES ventas(id) ON UPDATE CASCADE ON DELETE RESTRICT,
    CONSTRAINT fk_detalle_venta_producto FOREIGN KEY (producto_id)
        REFERENCES productos(id) ON UPDATE CASCADE ON DELETE RESTRICT,
    CONSTRAINT fk_detalle_venta_servicio FOREIGN KEY (servicio_id)
        REFERENCES servicios(id) ON UPDATE CASCADE ON DELETE RESTRICT,
    INDEX idx_detalle_venta (venta_id, fec_eliminacion),
    INDEX idx_detalle_producto (producto_id),
    INDEX idx_detalle_servicio (servicio_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE movimientos_inventario (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    producto_id BIGINT UNSIGNED NOT NULL,
    venta_id BIGINT UNSIGNED NULL,
    tipo VARCHAR(30) NOT NULL,
    cantidad DECIMAL(12,2) NOT NULL,
    motivo VARCHAR(255) NULL,
    fec_creacion TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    fec_actualizacion TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    fec_eliminacion TIMESTAMP NULL DEFAULT NULL,
    CONSTRAINT chk_movimiento_cantidad CHECK (cantidad > 0),
    CONSTRAINT fk_movimientos_producto FOREIGN KEY (producto_id)
        REFERENCES productos(id) ON UPDATE CASCADE ON DELETE RESTRICT,
    CONSTRAINT fk_movimientos_venta FOREIGN KEY (venta_id)
        REFERENCES ventas(id) ON UPDATE CASCADE ON DELETE RESTRICT,
    INDEX idx_movimientos_producto_fecha (producto_id, fec_creacion),
    INDEX idx_movimientos_venta (venta_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ================= BASE 21/26: db_emp_granja_san_martin (Granja San Martin) =================

-- ============================================================
-- BASE DE DATOS OPERATIVA: db_emp_granja_san_martin
-- EMPRENDIMIENTO: Granja San Martin
-- ============================================================
CREATE DATABASE IF NOT EXISTS `db_emp_granja_san_martin`
    CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE `db_emp_granja_san_martin`;

-- CREACION DE USUARIO DE BASE DE DATOS Y ASIGNACION DE PERMISOS
CREATE USER IF NOT EXISTS 'emp_granja_san_martin'@'%' IDENTIFIED BY 'DbPass_granja21';
GRANT ALL PRIVILEGES ON `db_emp_granja_san_martin`.* TO 'emp_granja_san_martin'@'%';
CREATE USER IF NOT EXISTS 'emp_granja_san_martin'@'localhost' IDENTIFIED BY 'DbPass_granja21';
GRANT ALL PRIVILEGES ON `db_emp_granja_san_martin`.* TO 'emp_granja_san_martin'@'localhost';
FLUSH PRIVILEGES;

SET FOREIGN_KEY_CHECKS = 0;
DROP TABLE IF EXISTS detalle_venta;
DROP TABLE IF EXISTS movimientos_inventario;
DROP TABLE IF EXISTS ventas;
DROP TABLE IF EXISTS productos;
DROP TABLE IF EXISTS servicios;
DROP TABLE IF EXISTS auditoria;
SET FOREIGN_KEY_CHECKS = 1;

CREATE TABLE auditoria (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    usuario_id BIGINT UNSIGNED NULL,
    accion VARCHAR(50) NOT NULL,
    tabla_afectada VARCHAR(100) NOT NULL,
    registro_id BIGINT UNSIGNED NULL,
    valores_anteriores JSON NULL,
    valores_nuevos JSON NULL,
    detalle TEXT NULL,
    direccion_ip VARCHAR(45) NULL,
    fec_creacion TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    fec_actualizacion TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    fec_eliminacion TIMESTAMP NULL DEFAULT NULL,
    INDEX idx_auditoria_usuario (usuario_id),
    INDEX idx_auditoria_tabla_registro (tabla_afectada, registro_id),
    INDEX idx_auditoria_fec_creacion (fec_creacion)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE servicios (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(150) NOT NULL,
    descripcion TEXT NULL,
    precio DECIMAL(10,2) NOT NULL DEFAULT 0.00,
    url_imagen VARCHAR(255) NULL,
    estado VARCHAR(30) NOT NULL DEFAULT 'activo',
    fecha_inicio DATE NULL,
    fecha_fin DATE NULL,
    fec_creacion TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    fec_actualizacion TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    fec_eliminacion TIMESTAMP NULL DEFAULT NULL,
    CONSTRAINT chk_servicios_precio CHECK (precio >= 0),
    CONSTRAINT chk_servicios_fechas CHECK (
        fecha_inicio IS NULL OR fecha_fin IS NULL OR fecha_fin >= fecha_inicio
    ),
    INDEX idx_servicios_nombre (nombre),
    INDEX idx_servicios_estado (estado, fec_eliminacion)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE productos (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    codigo VARCHAR(60) NULL,
    nombre VARCHAR(150) NOT NULL,
    descripcion TEXT NULL,
    cantidad INT NOT NULL DEFAULT 0,
    unidad_medida VARCHAR(50) NOT NULL DEFAULT 'unidad',
    categoria_unidad VARCHAR(100) NULL,
    costo_produccion DECIMAL(10,2) NOT NULL DEFAULT 0.00,
    precio_venta DECIMAL(10,2) NOT NULL DEFAULT 0.00,
    url_imagen VARCHAR(255) NULL,
    activo BOOLEAN NOT NULL DEFAULT TRUE,
    fec_creacion TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    fec_actualizacion TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    fec_eliminacion TIMESTAMP NULL DEFAULT NULL,
    CONSTRAINT chk_productos_costo CHECK (costo_produccion >= 0),
    CONSTRAINT chk_productos_precio_venta CHECK (precio_venta >= 0),
    CONSTRAINT chk_productos_cantidad CHECK (cantidad >= 0),
    UNIQUE KEY uq_productos_codigo (codigo),
    INDEX idx_productos_nombre (nombre),
    INDEX idx_productos_activo (activo, fec_eliminacion)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE ventas (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    fecha_venta DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    estado VARCHAR(30) NOT NULL DEFAULT 'completada',
    metodo_pago VARCHAR(50) NULL,
    subtotal DECIMAL(12,2) NOT NULL DEFAULT 0.00,
    descuento DECIMAL(12,2) NOT NULL DEFAULT 0.00,
    impuesto DECIMAL(12,2) NOT NULL DEFAULT 0.00,
    total DECIMAL(12,2) NOT NULL DEFAULT 0.00,
    observaciones TEXT NULL,
    fec_creacion TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    fec_actualizacion TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    fec_eliminacion TIMESTAMP NULL DEFAULT NULL,
    CONSTRAINT chk_ventas_subtotal CHECK (subtotal >= 0),
    CONSTRAINT chk_ventas_descuento CHECK (descuento >= 0),
    CONSTRAINT chk_ventas_impuesto CHECK (impuesto >= 0),
    CONSTRAINT chk_ventas_total CHECK (total >= 0),
    INDEX idx_ventas_fecha (fec_eliminacion, fecha_venta),
    INDEX idx_ventas_estado (estado)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE detalle_venta (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    venta_id BIGINT UNSIGNED NOT NULL,
    producto_id BIGINT UNSIGNED NULL,
    servicio_id BIGINT UNSIGNED NULL,
    nombre_item VARCHAR(150) NOT NULL,
    cantidad DECIMAL(12,2) NOT NULL DEFAULT 1.00,
    precio_unitario DECIMAL(10,2) NOT NULL DEFAULT 0.00,
    descuento DECIMAL(12,2) NOT NULL DEFAULT 0.00,
    subtotal DECIMAL(12,2) NOT NULL DEFAULT 0.00,
    fec_creacion TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    fec_actualizacion TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    fec_eliminacion TIMESTAMP NULL DEFAULT NULL,
    CONSTRAINT chk_detalle_cantidad CHECK (cantidad > 0),
    CONSTRAINT chk_detalle_precio CHECK (precio_unitario >= 0),
    CONSTRAINT chk_detalle_descuento CHECK (descuento >= 0),
    CONSTRAINT chk_detalle_subtotal CHECK (subtotal >= 0),
    CONSTRAINT fk_detalle_venta_venta FOREIGN KEY (venta_id)
        REFERENCES ventas(id) ON UPDATE CASCADE ON DELETE RESTRICT,
    CONSTRAINT fk_detalle_venta_producto FOREIGN KEY (producto_id)
        REFERENCES productos(id) ON UPDATE CASCADE ON DELETE RESTRICT,
    CONSTRAINT fk_detalle_venta_servicio FOREIGN KEY (servicio_id)
        REFERENCES servicios(id) ON UPDATE CASCADE ON DELETE RESTRICT,
    INDEX idx_detalle_venta (venta_id, fec_eliminacion),
    INDEX idx_detalle_producto (producto_id),
    INDEX idx_detalle_servicio (servicio_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE movimientos_inventario (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    producto_id BIGINT UNSIGNED NOT NULL,
    venta_id BIGINT UNSIGNED NULL,
    tipo VARCHAR(30) NOT NULL,
    cantidad DECIMAL(12,2) NOT NULL,
    motivo VARCHAR(255) NULL,
    fec_creacion TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    fec_actualizacion TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    fec_eliminacion TIMESTAMP NULL DEFAULT NULL,
    CONSTRAINT chk_movimiento_cantidad CHECK (cantidad > 0),
    CONSTRAINT fk_movimientos_producto FOREIGN KEY (producto_id)
        REFERENCES productos(id) ON UPDATE CASCADE ON DELETE RESTRICT,
    CONSTRAINT fk_movimientos_venta FOREIGN KEY (venta_id)
        REFERENCES ventas(id) ON UPDATE CASCADE ON DELETE RESTRICT,
    INDEX idx_movimientos_producto_fecha (producto_id, fec_creacion),
    INDEX idx_movimientos_venta (venta_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ================= BASE 22/26: db_emp_la_guadalupana (Quinta "La Guadalupana") =================

-- ============================================================
-- BASE DE DATOS OPERATIVA: db_emp_la_guadalupana
-- EMPRENDIMIENTO: Quinta "La Guadalupana"
-- ============================================================
CREATE DATABASE IF NOT EXISTS `db_emp_la_guadalupana`
    CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE `db_emp_la_guadalupana`;

-- CREACION DE USUARIO DE BASE DE DATOS Y ASIGNACION DE PERMISOS
CREATE USER IF NOT EXISTS 'emp_la_guadalupana'@'%' IDENTIFIED BY 'DbPass_quinta22';
GRANT ALL PRIVILEGES ON `db_emp_la_guadalupana`.* TO 'emp_la_guadalupana'@'%';
CREATE USER IF NOT EXISTS 'emp_la_guadalupana'@'localhost' IDENTIFIED BY 'DbPass_quinta22';
GRANT ALL PRIVILEGES ON `db_emp_la_guadalupana`.* TO 'emp_la_guadalupana'@'localhost';
FLUSH PRIVILEGES;

SET FOREIGN_KEY_CHECKS = 0;
DROP TABLE IF EXISTS detalle_venta;
DROP TABLE IF EXISTS movimientos_inventario;
DROP TABLE IF EXISTS ventas;
DROP TABLE IF EXISTS productos;
DROP TABLE IF EXISTS servicios;
DROP TABLE IF EXISTS auditoria;
SET FOREIGN_KEY_CHECKS = 1;

CREATE TABLE auditoria (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    usuario_id BIGINT UNSIGNED NULL,
    accion VARCHAR(50) NOT NULL,
    tabla_afectada VARCHAR(100) NOT NULL,
    registro_id BIGINT UNSIGNED NULL,
    valores_anteriores JSON NULL,
    valores_nuevos JSON NULL,
    detalle TEXT NULL,
    direccion_ip VARCHAR(45) NULL,
    fec_creacion TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    fec_actualizacion TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    fec_eliminacion TIMESTAMP NULL DEFAULT NULL,
    INDEX idx_auditoria_usuario (usuario_id),
    INDEX idx_auditoria_tabla_registro (tabla_afectada, registro_id),
    INDEX idx_auditoria_fec_creacion (fec_creacion)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE servicios (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(150) NOT NULL,
    descripcion TEXT NULL,
    precio DECIMAL(10,2) NOT NULL DEFAULT 0.00,
    url_imagen VARCHAR(255) NULL,
    estado VARCHAR(30) NOT NULL DEFAULT 'activo',
    fecha_inicio DATE NULL,
    fecha_fin DATE NULL,
    fec_creacion TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    fec_actualizacion TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    fec_eliminacion TIMESTAMP NULL DEFAULT NULL,
    CONSTRAINT chk_servicios_precio CHECK (precio >= 0),
    CONSTRAINT chk_servicios_fechas CHECK (
        fecha_inicio IS NULL OR fecha_fin IS NULL OR fecha_fin >= fecha_inicio
    ),
    INDEX idx_servicios_nombre (nombre),
    INDEX idx_servicios_estado (estado, fec_eliminacion)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE productos (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    codigo VARCHAR(60) NULL,
    nombre VARCHAR(150) NOT NULL,
    descripcion TEXT NULL,
    cantidad INT NOT NULL DEFAULT 0,
    unidad_medida VARCHAR(50) NOT NULL DEFAULT 'unidad',
    categoria_unidad VARCHAR(100) NULL,
    costo_produccion DECIMAL(10,2) NOT NULL DEFAULT 0.00,
    precio_venta DECIMAL(10,2) NOT NULL DEFAULT 0.00,
    url_imagen VARCHAR(255) NULL,
    activo BOOLEAN NOT NULL DEFAULT TRUE,
    fec_creacion TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    fec_actualizacion TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    fec_eliminacion TIMESTAMP NULL DEFAULT NULL,
    CONSTRAINT chk_productos_costo CHECK (costo_produccion >= 0),
    CONSTRAINT chk_productos_precio_venta CHECK (precio_venta >= 0),
    CONSTRAINT chk_productos_cantidad CHECK (cantidad >= 0),
    UNIQUE KEY uq_productos_codigo (codigo),
    INDEX idx_productos_nombre (nombre),
    INDEX idx_productos_activo (activo, fec_eliminacion)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE ventas (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    fecha_venta DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    estado VARCHAR(30) NOT NULL DEFAULT 'completada',
    metodo_pago VARCHAR(50) NULL,
    subtotal DECIMAL(12,2) NOT NULL DEFAULT 0.00,
    descuento DECIMAL(12,2) NOT NULL DEFAULT 0.00,
    impuesto DECIMAL(12,2) NOT NULL DEFAULT 0.00,
    total DECIMAL(12,2) NOT NULL DEFAULT 0.00,
    observaciones TEXT NULL,
    fec_creacion TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    fec_actualizacion TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    fec_eliminacion TIMESTAMP NULL DEFAULT NULL,
    CONSTRAINT chk_ventas_subtotal CHECK (subtotal >= 0),
    CONSTRAINT chk_ventas_descuento CHECK (descuento >= 0),
    CONSTRAINT chk_ventas_impuesto CHECK (impuesto >= 0),
    CONSTRAINT chk_ventas_total CHECK (total >= 0),
    INDEX idx_ventas_fecha (fec_eliminacion, fecha_venta),
    INDEX idx_ventas_estado (estado)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE detalle_venta (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    venta_id BIGINT UNSIGNED NOT NULL,
    producto_id BIGINT UNSIGNED NULL,
    servicio_id BIGINT UNSIGNED NULL,
    nombre_item VARCHAR(150) NOT NULL,
    cantidad DECIMAL(12,2) NOT NULL DEFAULT 1.00,
    precio_unitario DECIMAL(10,2) NOT NULL DEFAULT 0.00,
    descuento DECIMAL(12,2) NOT NULL DEFAULT 0.00,
    subtotal DECIMAL(12,2) NOT NULL DEFAULT 0.00,
    fec_creacion TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    fec_actualizacion TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    fec_eliminacion TIMESTAMP NULL DEFAULT NULL,
    CONSTRAINT chk_detalle_cantidad CHECK (cantidad > 0),
    CONSTRAINT chk_detalle_precio CHECK (precio_unitario >= 0),
    CONSTRAINT chk_detalle_descuento CHECK (descuento >= 0),
    CONSTRAINT chk_detalle_subtotal CHECK (subtotal >= 0),
    CONSTRAINT fk_detalle_venta_venta FOREIGN KEY (venta_id)
        REFERENCES ventas(id) ON UPDATE CASCADE ON DELETE RESTRICT,
    CONSTRAINT fk_detalle_venta_producto FOREIGN KEY (producto_id)
        REFERENCES productos(id) ON UPDATE CASCADE ON DELETE RESTRICT,
    CONSTRAINT fk_detalle_venta_servicio FOREIGN KEY (servicio_id)
        REFERENCES servicios(id) ON UPDATE CASCADE ON DELETE RESTRICT,
    INDEX idx_detalle_venta (venta_id, fec_eliminacion),
    INDEX idx_detalle_producto (producto_id),
    INDEX idx_detalle_servicio (servicio_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE movimientos_inventario (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    producto_id BIGINT UNSIGNED NOT NULL,
    venta_id BIGINT UNSIGNED NULL,
    tipo VARCHAR(30) NOT NULL,
    cantidad DECIMAL(12,2) NOT NULL,
    motivo VARCHAR(255) NULL,
    fec_creacion TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    fec_actualizacion TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    fec_eliminacion TIMESTAMP NULL DEFAULT NULL,
    CONSTRAINT chk_movimiento_cantidad CHECK (cantidad > 0),
    CONSTRAINT fk_movimientos_producto FOREIGN KEY (producto_id)
        REFERENCES productos(id) ON UPDATE CASCADE ON DELETE RESTRICT,
    CONSTRAINT fk_movimientos_venta FOREIGN KEY (venta_id)
        REFERENCES ventas(id) ON UPDATE CASCADE ON DELETE RESTRICT,
    INDEX idx_movimientos_producto_fecha (producto_id, fec_creacion),
    INDEX idx_movimientos_venta (venta_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ================= BASE 23/26: db_emp_san_miguel (San Miguel) =================

-- ============================================================
-- BASE DE DATOS OPERATIVA: db_emp_san_miguel
-- EMPRENDIMIENTO: San Miguel
-- ============================================================
CREATE DATABASE IF NOT EXISTS `db_emp_san_miguel`
    CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE `db_emp_san_miguel`;

-- CREACION DE USUARIO DE BASE DE DATOS Y ASIGNACION DE PERMISOS
CREATE USER IF NOT EXISTS 'emp_san_miguel'@'%' IDENTIFIED BY 'DbPass_sanmiguel23';
GRANT ALL PRIVILEGES ON `db_emp_san_miguel`.* TO 'emp_san_miguel'@'%';
CREATE USER IF NOT EXISTS 'emp_san_miguel'@'localhost' IDENTIFIED BY 'DbPass_sanmiguel23';
GRANT ALL PRIVILEGES ON `db_emp_san_miguel`.* TO 'emp_san_miguel'@'localhost';
FLUSH PRIVILEGES;

SET FOREIGN_KEY_CHECKS = 0;
DROP TABLE IF EXISTS detalle_venta;
DROP TABLE IF EXISTS movimientos_inventario;
DROP TABLE IF EXISTS ventas;
DROP TABLE IF EXISTS productos;
DROP TABLE IF EXISTS servicios;
DROP TABLE IF EXISTS auditoria;
SET FOREIGN_KEY_CHECKS = 1;

CREATE TABLE auditoria (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    usuario_id BIGINT UNSIGNED NULL,
    accion VARCHAR(50) NOT NULL,
    tabla_afectada VARCHAR(100) NOT NULL,
    registro_id BIGINT UNSIGNED NULL,
    valores_anteriores JSON NULL,
    valores_nuevos JSON NULL,
    detalle TEXT NULL,
    direccion_ip VARCHAR(45) NULL,
    fec_creacion TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    fec_actualizacion TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    fec_eliminacion TIMESTAMP NULL DEFAULT NULL,
    INDEX idx_auditoria_usuario (usuario_id),
    INDEX idx_auditoria_tabla_registro (tabla_afectada, registro_id),
    INDEX idx_auditoria_fec_creacion (fec_creacion)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE servicios (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(150) NOT NULL,
    descripcion TEXT NULL,
    precio DECIMAL(10,2) NOT NULL DEFAULT 0.00,
    url_imagen VARCHAR(255) NULL,
    estado VARCHAR(30) NOT NULL DEFAULT 'activo',
    fecha_inicio DATE NULL,
    fecha_fin DATE NULL,
    fec_creacion TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    fec_actualizacion TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    fec_eliminacion TIMESTAMP NULL DEFAULT NULL,
    CONSTRAINT chk_servicios_precio CHECK (precio >= 0),
    CONSTRAINT chk_servicios_fechas CHECK (
        fecha_inicio IS NULL OR fecha_fin IS NULL OR fecha_fin >= fecha_inicio
    ),
    INDEX idx_servicios_nombre (nombre),
    INDEX idx_servicios_estado (estado, fec_eliminacion)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE productos (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    codigo VARCHAR(60) NULL,
    nombre VARCHAR(150) NOT NULL,
    descripcion TEXT NULL,
    cantidad INT NOT NULL DEFAULT 0,
    unidad_medida VARCHAR(50) NOT NULL DEFAULT 'unidad',
    categoria_unidad VARCHAR(100) NULL,
    costo_produccion DECIMAL(10,2) NOT NULL DEFAULT 0.00,
    precio_venta DECIMAL(10,2) NOT NULL DEFAULT 0.00,
    url_imagen VARCHAR(255) NULL,
    activo BOOLEAN NOT NULL DEFAULT TRUE,
    fec_creacion TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    fec_actualizacion TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    fec_eliminacion TIMESTAMP NULL DEFAULT NULL,
    CONSTRAINT chk_productos_costo CHECK (costo_produccion >= 0),
    CONSTRAINT chk_productos_precio_venta CHECK (precio_venta >= 0),
    CONSTRAINT chk_productos_cantidad CHECK (cantidad >= 0),
    UNIQUE KEY uq_productos_codigo (codigo),
    INDEX idx_productos_nombre (nombre),
    INDEX idx_productos_activo (activo, fec_eliminacion)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE ventas (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    fecha_venta DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    estado VARCHAR(30) NOT NULL DEFAULT 'completada',
    metodo_pago VARCHAR(50) NULL,
    subtotal DECIMAL(12,2) NOT NULL DEFAULT 0.00,
    descuento DECIMAL(12,2) NOT NULL DEFAULT 0.00,
    impuesto DECIMAL(12,2) NOT NULL DEFAULT 0.00,
    total DECIMAL(12,2) NOT NULL DEFAULT 0.00,
    observaciones TEXT NULL,
    fec_creacion TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    fec_actualizacion TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    fec_eliminacion TIMESTAMP NULL DEFAULT NULL,
    CONSTRAINT chk_ventas_subtotal CHECK (subtotal >= 0),
    CONSTRAINT chk_ventas_descuento CHECK (descuento >= 0),
    CONSTRAINT chk_ventas_impuesto CHECK (impuesto >= 0),
    CONSTRAINT chk_ventas_total CHECK (total >= 0),
    INDEX idx_ventas_fecha (fec_eliminacion, fecha_venta),
    INDEX idx_ventas_estado (estado)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE detalle_venta (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    venta_id BIGINT UNSIGNED NOT NULL,
    producto_id BIGINT UNSIGNED NULL,
    servicio_id BIGINT UNSIGNED NULL,
    nombre_item VARCHAR(150) NOT NULL,
    cantidad DECIMAL(12,2) NOT NULL DEFAULT 1.00,
    precio_unitario DECIMAL(10,2) NOT NULL DEFAULT 0.00,
    descuento DECIMAL(12,2) NOT NULL DEFAULT 0.00,
    subtotal DECIMAL(12,2) NOT NULL DEFAULT 0.00,
    fec_creacion TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    fec_actualizacion TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    fec_eliminacion TIMESTAMP NULL DEFAULT NULL,
    CONSTRAINT chk_detalle_cantidad CHECK (cantidad > 0),
    CONSTRAINT chk_detalle_precio CHECK (precio_unitario >= 0),
    CONSTRAINT chk_detalle_descuento CHECK (descuento >= 0),
    CONSTRAINT chk_detalle_subtotal CHECK (subtotal >= 0),
    CONSTRAINT fk_detalle_venta_venta FOREIGN KEY (venta_id)
        REFERENCES ventas(id) ON UPDATE CASCADE ON DELETE RESTRICT,
    CONSTRAINT fk_detalle_venta_producto FOREIGN KEY (producto_id)
        REFERENCES productos(id) ON UPDATE CASCADE ON DELETE RESTRICT,
    CONSTRAINT fk_detalle_venta_servicio FOREIGN KEY (servicio_id)
        REFERENCES servicios(id) ON UPDATE CASCADE ON DELETE RESTRICT,
    INDEX idx_detalle_venta (venta_id, fec_eliminacion),
    INDEX idx_detalle_producto (producto_id),
    INDEX idx_detalle_servicio (servicio_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE movimientos_inventario (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    producto_id BIGINT UNSIGNED NOT NULL,
    venta_id BIGINT UNSIGNED NULL,
    tipo VARCHAR(30) NOT NULL,
    cantidad DECIMAL(12,2) NOT NULL,
    motivo VARCHAR(255) NULL,
    fec_creacion TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    fec_actualizacion TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    fec_eliminacion TIMESTAMP NULL DEFAULT NULL,
    CONSTRAINT chk_movimiento_cantidad CHECK (cantidad > 0),
    CONSTRAINT fk_movimientos_producto FOREIGN KEY (producto_id)
        REFERENCES productos(id) ON UPDATE CASCADE ON DELETE RESTRICT,
    CONSTRAINT fk_movimientos_venta FOREIGN KEY (venta_id)
        REFERENCES ventas(id) ON UPDATE CASCADE ON DELETE RESTRICT,
    INDEX idx_movimientos_producto_fecha (producto_id, fec_creacion),
    INDEX idx_movimientos_venta (venta_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ================= BASE 24/26: db_emp_union_hermandad (Asociación de productores agropecuarios "Unión y Hermandad") =================

-- ============================================================
-- BASE DE DATOS OPERATIVA: db_emp_union_hermandad
-- EMPRENDIMIENTO: Asociación de productores agropecuarios "Unión y Hermandad"
-- ============================================================
CREATE DATABASE IF NOT EXISTS `db_emp_union_hermandad`
    CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE `db_emp_union_hermandad`;

-- CREACION DE USUARIO DE BASE DE DATOS Y ASIGNACION DE PERMISOS
CREATE USER IF NOT EXISTS 'emp_union_hermandad'@'%' IDENTIFIED BY 'DbPass_union24';
GRANT ALL PRIVILEGES ON `db_emp_union_hermandad`.* TO 'emp_union_hermandad'@'%';
CREATE USER IF NOT EXISTS 'emp_union_hermandad'@'localhost' IDENTIFIED BY 'DbPass_union24';
GRANT ALL PRIVILEGES ON `db_emp_union_hermandad`.* TO 'emp_union_hermandad'@'localhost';
FLUSH PRIVILEGES;

SET FOREIGN_KEY_CHECKS = 0;
DROP TABLE IF EXISTS detalle_venta;
DROP TABLE IF EXISTS movimientos_inventario;
DROP TABLE IF EXISTS ventas;
DROP TABLE IF EXISTS productos;
DROP TABLE IF EXISTS servicios;
DROP TABLE IF EXISTS auditoria;
SET FOREIGN_KEY_CHECKS = 1;

CREATE TABLE auditoria (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    usuario_id BIGINT UNSIGNED NULL,
    accion VARCHAR(50) NOT NULL,
    tabla_afectada VARCHAR(100) NOT NULL,
    registro_id BIGINT UNSIGNED NULL,
    valores_anteriores JSON NULL,
    valores_nuevos JSON NULL,
    detalle TEXT NULL,
    direccion_ip VARCHAR(45) NULL,
    fec_creacion TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    fec_actualizacion TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    fec_eliminacion TIMESTAMP NULL DEFAULT NULL,
    INDEX idx_auditoria_usuario (usuario_id),
    INDEX idx_auditoria_tabla_registro (tabla_afectada, registro_id),
    INDEX idx_auditoria_fec_creacion (fec_creacion)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE servicios (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(150) NOT NULL,
    descripcion TEXT NULL,
    precio DECIMAL(10,2) NOT NULL DEFAULT 0.00,
    url_imagen VARCHAR(255) NULL,
    estado VARCHAR(30) NOT NULL DEFAULT 'activo',
    fecha_inicio DATE NULL,
    fecha_fin DATE NULL,
    fec_creacion TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    fec_actualizacion TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    fec_eliminacion TIMESTAMP NULL DEFAULT NULL,
    CONSTRAINT chk_servicios_precio CHECK (precio >= 0),
    CONSTRAINT chk_servicios_fechas CHECK (
        fecha_inicio IS NULL OR fecha_fin IS NULL OR fecha_fin >= fecha_inicio
    ),
    INDEX idx_servicios_nombre (nombre),
    INDEX idx_servicios_estado (estado, fec_eliminacion)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE productos (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    codigo VARCHAR(60) NULL,
    nombre VARCHAR(150) NOT NULL,
    descripcion TEXT NULL,
    cantidad INT NOT NULL DEFAULT 0,
    unidad_medida VARCHAR(50) NOT NULL DEFAULT 'unidad',
    categoria_unidad VARCHAR(100) NULL,
    costo_produccion DECIMAL(10,2) NOT NULL DEFAULT 0.00,
    precio_venta DECIMAL(10,2) NOT NULL DEFAULT 0.00,
    url_imagen VARCHAR(255) NULL,
    activo BOOLEAN NOT NULL DEFAULT TRUE,
    fec_creacion TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    fec_actualizacion TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    fec_eliminacion TIMESTAMP NULL DEFAULT NULL,
    CONSTRAINT chk_productos_costo CHECK (costo_produccion >= 0),
    CONSTRAINT chk_productos_precio_venta CHECK (precio_venta >= 0),
    CONSTRAINT chk_productos_cantidad CHECK (cantidad >= 0),
    UNIQUE KEY uq_productos_codigo (codigo),
    INDEX idx_productos_nombre (nombre),
    INDEX idx_productos_activo (activo, fec_eliminacion)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE ventas (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    fecha_venta DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    estado VARCHAR(30) NOT NULL DEFAULT 'completada',
    metodo_pago VARCHAR(50) NULL,
    subtotal DECIMAL(12,2) NOT NULL DEFAULT 0.00,
    descuento DECIMAL(12,2) NOT NULL DEFAULT 0.00,
    impuesto DECIMAL(12,2) NOT NULL DEFAULT 0.00,
    total DECIMAL(12,2) NOT NULL DEFAULT 0.00,
    observaciones TEXT NULL,
    fec_creacion TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    fec_actualizacion TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    fec_eliminacion TIMESTAMP NULL DEFAULT NULL,
    CONSTRAINT chk_ventas_subtotal CHECK (subtotal >= 0),
    CONSTRAINT chk_ventas_descuento CHECK (descuento >= 0),
    CONSTRAINT chk_ventas_impuesto CHECK (impuesto >= 0),
    CONSTRAINT chk_ventas_total CHECK (total >= 0),
    INDEX idx_ventas_fecha (fec_eliminacion, fecha_venta),
    INDEX idx_ventas_estado (estado)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE detalle_venta (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    venta_id BIGINT UNSIGNED NOT NULL,
    producto_id BIGINT UNSIGNED NULL,
    servicio_id BIGINT UNSIGNED NULL,
    nombre_item VARCHAR(150) NOT NULL,
    cantidad DECIMAL(12,2) NOT NULL DEFAULT 1.00,
    precio_unitario DECIMAL(10,2) NOT NULL DEFAULT 0.00,
    descuento DECIMAL(12,2) NOT NULL DEFAULT 0.00,
    subtotal DECIMAL(12,2) NOT NULL DEFAULT 0.00,
    fec_creacion TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    fec_actualizacion TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    fec_eliminacion TIMESTAMP NULL DEFAULT NULL,
    CONSTRAINT chk_detalle_cantidad CHECK (cantidad > 0),
    CONSTRAINT chk_detalle_precio CHECK (precio_unitario >= 0),
    CONSTRAINT chk_detalle_descuento CHECK (descuento >= 0),
    CONSTRAINT chk_detalle_subtotal CHECK (subtotal >= 0),
    CONSTRAINT fk_detalle_venta_venta FOREIGN KEY (venta_id)
        REFERENCES ventas(id) ON UPDATE CASCADE ON DELETE RESTRICT,
    CONSTRAINT fk_detalle_venta_producto FOREIGN KEY (producto_id)
        REFERENCES productos(id) ON UPDATE CASCADE ON DELETE RESTRICT,
    CONSTRAINT fk_detalle_venta_servicio FOREIGN KEY (servicio_id)
        REFERENCES servicios(id) ON UPDATE CASCADE ON DELETE RESTRICT,
    INDEX idx_detalle_venta (venta_id, fec_eliminacion),
    INDEX idx_detalle_producto (producto_id),
    INDEX idx_detalle_servicio (servicio_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE movimientos_inventario (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    producto_id BIGINT UNSIGNED NOT NULL,
    venta_id BIGINT UNSIGNED NULL,
    tipo VARCHAR(30) NOT NULL,
    cantidad DECIMAL(12,2) NOT NULL,
    motivo VARCHAR(255) NULL,
    fec_creacion TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    fec_actualizacion TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    fec_eliminacion TIMESTAMP NULL DEFAULT NULL,
    CONSTRAINT chk_movimiento_cantidad CHECK (cantidad > 0),
    CONSTRAINT fk_movimientos_producto FOREIGN KEY (producto_id)
        REFERENCES productos(id) ON UPDATE CASCADE ON DELETE RESTRICT,
    CONSTRAINT fk_movimientos_venta FOREIGN KEY (venta_id)
        REFERENCES ventas(id) ON UPDATE CASCADE ON DELETE RESTRICT,
    INDEX idx_movimientos_producto_fecha (producto_id, fec_creacion),
    INDEX idx_movimientos_venta (venta_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ================= BASE 25/26: db_emp_asoc_quinchicoto (Asociación Agropecuaria Quinchicoto) =================

-- ============================================================
-- BASE DE DATOS OPERATIVA: db_emp_asoc_quinchicoto
-- EMPRENDIMIENTO: Asociación Agropecuaria Quinchicoto
-- ============================================================
CREATE DATABASE IF NOT EXISTS `db_emp_asoc_quinchicoto`
    CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE `db_emp_asoc_quinchicoto`;

-- CREACION DE USUARIO DE BASE DE DATOS Y ASIGNACION DE PERMISOS
CREATE USER IF NOT EXISTS 'emp_asoc_quinchicoto'@'%' IDENTIFIED BY 'DbPass_asoc25';
GRANT ALL PRIVILEGES ON `db_emp_asoc_quinchicoto`.* TO 'emp_asoc_quinchicoto'@'%';
CREATE USER IF NOT EXISTS 'emp_asoc_quinchicoto'@'localhost' IDENTIFIED BY 'DbPass_asoc25';
GRANT ALL PRIVILEGES ON `db_emp_asoc_quinchicoto`.* TO 'emp_asoc_quinchicoto'@'localhost';
FLUSH PRIVILEGES;

SET FOREIGN_KEY_CHECKS = 0;
DROP TABLE IF EXISTS detalle_venta;
DROP TABLE IF EXISTS movimientos_inventario;
DROP TABLE IF EXISTS ventas;
DROP TABLE IF EXISTS productos;
DROP TABLE IF EXISTS servicios;
DROP TABLE IF EXISTS auditoria;
SET FOREIGN_KEY_CHECKS = 1;

CREATE TABLE auditoria (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    usuario_id BIGINT UNSIGNED NULL,
    accion VARCHAR(50) NOT NULL,
    tabla_afectada VARCHAR(100) NOT NULL,
    registro_id BIGINT UNSIGNED NULL,
    valores_anteriores JSON NULL,
    valores_nuevos JSON NULL,
    detalle TEXT NULL,
    direccion_ip VARCHAR(45) NULL,
    fec_creacion TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    fec_actualizacion TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    fec_eliminacion TIMESTAMP NULL DEFAULT NULL,
    INDEX idx_auditoria_usuario (usuario_id),
    INDEX idx_auditoria_tabla_registro (tabla_afectada, registro_id),
    INDEX idx_auditoria_fec_creacion (fec_creacion)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE servicios (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(150) NOT NULL,
    descripcion TEXT NULL,
    precio DECIMAL(10,2) NOT NULL DEFAULT 0.00,
    url_imagen VARCHAR(255) NULL,
    estado VARCHAR(30) NOT NULL DEFAULT 'activo',
    fecha_inicio DATE NULL,
    fecha_fin DATE NULL,
    fec_creacion TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    fec_actualizacion TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    fec_eliminacion TIMESTAMP NULL DEFAULT NULL,
    CONSTRAINT chk_servicios_precio CHECK (precio >= 0),
    CONSTRAINT chk_servicios_fechas CHECK (
        fecha_inicio IS NULL OR fecha_fin IS NULL OR fecha_fin >= fecha_inicio
    ),
    INDEX idx_servicios_nombre (nombre),
    INDEX idx_servicios_estado (estado, fec_eliminacion)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE productos (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    codigo VARCHAR(60) NULL,
    nombre VARCHAR(150) NOT NULL,
    descripcion TEXT NULL,
    cantidad INT NOT NULL DEFAULT 0,
    unidad_medida VARCHAR(50) NOT NULL DEFAULT 'unidad',
    categoria_unidad VARCHAR(100) NULL,
    costo_produccion DECIMAL(10,2) NOT NULL DEFAULT 0.00,
    precio_venta DECIMAL(10,2) NOT NULL DEFAULT 0.00,
    url_imagen VARCHAR(255) NULL,
    activo BOOLEAN NOT NULL DEFAULT TRUE,
    fec_creacion TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    fec_actualizacion TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    fec_eliminacion TIMESTAMP NULL DEFAULT NULL,
    CONSTRAINT chk_productos_costo CHECK (costo_produccion >= 0),
    CONSTRAINT chk_productos_precio_venta CHECK (precio_venta >= 0),
    CONSTRAINT chk_productos_cantidad CHECK (cantidad >= 0),
    UNIQUE KEY uq_productos_codigo (codigo),
    INDEX idx_productos_nombre (nombre),
    INDEX idx_productos_activo (activo, fec_eliminacion)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE ventas (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    fecha_venta DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    estado VARCHAR(30) NOT NULL DEFAULT 'completada',
    metodo_pago VARCHAR(50) NULL,
    subtotal DECIMAL(12,2) NOT NULL DEFAULT 0.00,
    descuento DECIMAL(12,2) NOT NULL DEFAULT 0.00,
    impuesto DECIMAL(12,2) NOT NULL DEFAULT 0.00,
    total DECIMAL(12,2) NOT NULL DEFAULT 0.00,
    observaciones TEXT NULL,
    fec_creacion TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    fec_actualizacion TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    fec_eliminacion TIMESTAMP NULL DEFAULT NULL,
    CONSTRAINT chk_ventas_subtotal CHECK (subtotal >= 0),
    CONSTRAINT chk_ventas_descuento CHECK (descuento >= 0),
    CONSTRAINT chk_ventas_impuesto CHECK (impuesto >= 0),
    CONSTRAINT chk_ventas_total CHECK (total >= 0),
    INDEX idx_ventas_fecha (fec_eliminacion, fecha_venta),
    INDEX idx_ventas_estado (estado)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE detalle_venta (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    venta_id BIGINT UNSIGNED NOT NULL,
    producto_id BIGINT UNSIGNED NULL,
    servicio_id BIGINT UNSIGNED NULL,
    nombre_item VARCHAR(150) NOT NULL,
    cantidad DECIMAL(12,2) NOT NULL DEFAULT 1.00,
    precio_unitario DECIMAL(10,2) NOT NULL DEFAULT 0.00,
    descuento DECIMAL(12,2) NOT NULL DEFAULT 0.00,
    subtotal DECIMAL(12,2) NOT NULL DEFAULT 0.00,
    fec_creacion TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    fec_actualizacion TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    fec_eliminacion TIMESTAMP NULL DEFAULT NULL,
    CONSTRAINT chk_detalle_cantidad CHECK (cantidad > 0),
    CONSTRAINT chk_detalle_precio CHECK (precio_unitario >= 0),
    CONSTRAINT chk_detalle_descuento CHECK (descuento >= 0),
    CONSTRAINT chk_detalle_subtotal CHECK (subtotal >= 0),
    CONSTRAINT fk_detalle_venta_venta FOREIGN KEY (venta_id)
        REFERENCES ventas(id) ON UPDATE CASCADE ON DELETE RESTRICT,
    CONSTRAINT fk_detalle_venta_producto FOREIGN KEY (producto_id)
        REFERENCES productos(id) ON UPDATE CASCADE ON DELETE RESTRICT,
    CONSTRAINT fk_detalle_venta_servicio FOREIGN KEY (servicio_id)
        REFERENCES servicios(id) ON UPDATE CASCADE ON DELETE RESTRICT,
    INDEX idx_detalle_venta (venta_id, fec_eliminacion),
    INDEX idx_detalle_producto (producto_id),
    INDEX idx_detalle_servicio (servicio_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE movimientos_inventario (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    producto_id BIGINT UNSIGNED NOT NULL,
    venta_id BIGINT UNSIGNED NULL,
    tipo VARCHAR(30) NOT NULL,
    cantidad DECIMAL(12,2) NOT NULL,
    motivo VARCHAR(255) NULL,
    fec_creacion TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    fec_actualizacion TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    fec_eliminacion TIMESTAMP NULL DEFAULT NULL,
    CONSTRAINT chk_movimiento_cantidad CHECK (cantidad > 0),
    CONSTRAINT fk_movimientos_producto FOREIGN KEY (producto_id)
        REFERENCES productos(id) ON UPDATE CASCADE ON DELETE RESTRICT,
    CONSTRAINT fk_movimientos_venta FOREIGN KEY (venta_id)
        REFERENCES ventas(id) ON UPDATE CASCADE ON DELETE RESTRICT,
    INDEX idx_movimientos_producto_fecha (producto_id, fec_creacion),
    INDEX idx_movimientos_venta (venta_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ================= BASE 26/26: db_emp_union_tisalena (Asociación Unión Tisaleña) =================

-- ============================================================
-- BASE DE DATOS OPERATIVA: db_emp_union_tisalena
-- EMPRENDIMIENTO: Asociación Unión Tisaleña
-- ============================================================
CREATE DATABASE IF NOT EXISTS `db_emp_union_tisalena`
    CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE `db_emp_union_tisalena`;

-- CREACION DE USUARIO DE BASE DE DATOS Y ASIGNACION DE PERMISOS
CREATE USER IF NOT EXISTS 'emp_union_tisalena'@'%' IDENTIFIED BY 'DbPass_union26';
GRANT ALL PRIVILEGES ON `db_emp_union_tisalena`.* TO 'emp_union_tisalena'@'%';
CREATE USER IF NOT EXISTS 'emp_union_tisalena'@'localhost' IDENTIFIED BY 'DbPass_union26';
GRANT ALL PRIVILEGES ON `db_emp_union_tisalena`.* TO 'emp_union_tisalena'@'localhost';
FLUSH PRIVILEGES;

SET FOREIGN_KEY_CHECKS = 0;
DROP TABLE IF EXISTS detalle_venta;
DROP TABLE IF EXISTS movimientos_inventario;
DROP TABLE IF EXISTS ventas;
DROP TABLE IF EXISTS productos;
DROP TABLE IF EXISTS servicios;
DROP TABLE IF EXISTS auditoria;
SET FOREIGN_KEY_CHECKS = 1;

CREATE TABLE auditoria (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    usuario_id BIGINT UNSIGNED NULL,
    accion VARCHAR(50) NOT NULL,
    tabla_afectada VARCHAR(100) NOT NULL,
    registro_id BIGINT UNSIGNED NULL,
    valores_anteriores JSON NULL,
    valores_nuevos JSON NULL,
    detalle TEXT NULL,
    direccion_ip VARCHAR(45) NULL,
    fec_creacion TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    fec_actualizacion TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    fec_eliminacion TIMESTAMP NULL DEFAULT NULL,
    INDEX idx_auditoria_usuario (usuario_id),
    INDEX idx_auditoria_tabla_registro (tabla_afectada, registro_id),
    INDEX idx_auditoria_fec_creacion (fec_creacion)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE servicios (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(150) NOT NULL,
    descripcion TEXT NULL,
    precio DECIMAL(10,2) NOT NULL DEFAULT 0.00,
    url_imagen VARCHAR(255) NULL,
    estado VARCHAR(30) NOT NULL DEFAULT 'activo',
    fecha_inicio DATE NULL,
    fecha_fin DATE NULL,
    fec_creacion TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    fec_actualizacion TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    fec_eliminacion TIMESTAMP NULL DEFAULT NULL,
    CONSTRAINT chk_servicios_precio CHECK (precio >= 0),
    CONSTRAINT chk_servicios_fechas CHECK (
        fecha_inicio IS NULL OR fecha_fin IS NULL OR fecha_fin >= fecha_inicio
    ),
    INDEX idx_servicios_nombre (nombre),
    INDEX idx_servicios_estado (estado, fec_eliminacion)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE productos (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    codigo VARCHAR(60) NULL,
    nombre VARCHAR(150) NOT NULL,
    descripcion TEXT NULL,
    cantidad INT NOT NULL DEFAULT 0,
    unidad_medida VARCHAR(50) NOT NULL DEFAULT 'unidad',
    categoria_unidad VARCHAR(100) NULL,
    costo_produccion DECIMAL(10,2) NOT NULL DEFAULT 0.00,
    precio_venta DECIMAL(10,2) NOT NULL DEFAULT 0.00,
    url_imagen VARCHAR(255) NULL,
    activo BOOLEAN NOT NULL DEFAULT TRUE,
    fec_creacion TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    fec_actualizacion TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    fec_eliminacion TIMESTAMP NULL DEFAULT NULL,
    CONSTRAINT chk_productos_costo CHECK (costo_produccion >= 0),
    CONSTRAINT chk_productos_precio_venta CHECK (precio_venta >= 0),
    CONSTRAINT chk_productos_cantidad CHECK (cantidad >= 0),
    UNIQUE KEY uq_productos_codigo (codigo),
    INDEX idx_productos_nombre (nombre),
    INDEX idx_productos_activo (activo, fec_eliminacion)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE ventas (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    fecha_venta DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    estado VARCHAR(30) NOT NULL DEFAULT 'completada',
    metodo_pago VARCHAR(50) NULL,
    subtotal DECIMAL(12,2) NOT NULL DEFAULT 0.00,
    descuento DECIMAL(12,2) NOT NULL DEFAULT 0.00,
    impuesto DECIMAL(12,2) NOT NULL DEFAULT 0.00,
    total DECIMAL(12,2) NOT NULL DEFAULT 0.00,
    observaciones TEXT NULL,
    fec_creacion TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    fec_actualizacion TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    fec_eliminacion TIMESTAMP NULL DEFAULT NULL,
    CONSTRAINT chk_ventas_subtotal CHECK (subtotal >= 0),
    CONSTRAINT chk_ventas_descuento CHECK (descuento >= 0),
    CONSTRAINT chk_ventas_impuesto CHECK (impuesto >= 0),
    CONSTRAINT chk_ventas_total CHECK (total >= 0),
    INDEX idx_ventas_fecha (fec_eliminacion, fecha_venta),
    INDEX idx_ventas_estado (estado)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE detalle_venta (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    venta_id BIGINT UNSIGNED NOT NULL,
    producto_id BIGINT UNSIGNED NULL,
    servicio_id BIGINT UNSIGNED NULL,
    nombre_item VARCHAR(150) NOT NULL,
    cantidad DECIMAL(12,2) NOT NULL DEFAULT 1.00,
    precio_unitario DECIMAL(10,2) NOT NULL DEFAULT 0.00,
    descuento DECIMAL(12,2) NOT NULL DEFAULT 0.00,
    subtotal DECIMAL(12,2) NOT NULL DEFAULT 0.00,
    fec_creacion TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    fec_actualizacion TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    fec_eliminacion TIMESTAMP NULL DEFAULT NULL,
    CONSTRAINT chk_detalle_cantidad CHECK (cantidad > 0),
    CONSTRAINT chk_detalle_precio CHECK (precio_unitario >= 0),
    CONSTRAINT chk_detalle_descuento CHECK (descuento >= 0),
    CONSTRAINT chk_detalle_subtotal CHECK (subtotal >= 0),
    CONSTRAINT fk_detalle_venta_venta FOREIGN KEY (venta_id)
        REFERENCES ventas(id) ON UPDATE CASCADE ON DELETE RESTRICT,
    CONSTRAINT fk_detalle_venta_producto FOREIGN KEY (producto_id)
        REFERENCES productos(id) ON UPDATE CASCADE ON DELETE RESTRICT,
    CONSTRAINT fk_detalle_venta_servicio FOREIGN KEY (servicio_id)
        REFERENCES servicios(id) ON UPDATE CASCADE ON DELETE RESTRICT,
    INDEX idx_detalle_venta (venta_id, fec_eliminacion),
    INDEX idx_detalle_producto (producto_id),
    INDEX idx_detalle_servicio (servicio_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE movimientos_inventario (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    producto_id BIGINT UNSIGNED NOT NULL,
    venta_id BIGINT UNSIGNED NULL,
    tipo VARCHAR(30) NOT NULL,
    cantidad DECIMAL(12,2) NOT NULL,
    motivo VARCHAR(255) NULL,
    fec_creacion TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    fec_actualizacion TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    fec_eliminacion TIMESTAMP NULL DEFAULT NULL,
    CONSTRAINT chk_movimiento_cantidad CHECK (cantidad > 0),
    CONSTRAINT fk_movimientos_producto FOREIGN KEY (producto_id)
        REFERENCES productos(id) ON UPDATE CASCADE ON DELETE RESTRICT,
    CONSTRAINT fk_movimientos_venta FOREIGN KEY (venta_id)
        REFERENCES ventas(id) ON UPDATE CASCADE ON DELETE RESTRICT,
    INDEX idx_movimientos_producto_fecha (producto_id, fec_creacion),
    INDEX idx_movimientos_venta (venta_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
