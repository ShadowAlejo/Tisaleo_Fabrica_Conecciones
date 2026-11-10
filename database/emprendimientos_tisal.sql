-- CREACION DE 26 BASES DE DATOS OPERATIVAS PARA TISALEO EMPRENDE
-- Se utilizan exclusivamente los nombres db_name del archivo proporcionado.
-- Cada base contiene auditoria, servicios, productos, ventas, detalle_venta y movimientos_inventario.


-- ================= BASE 1/26: db_emp_calzado_john =================

-- ============================================================
-- BASE DE DATOS OPERATIVA: db_emp_calzado_john
-- ============================================================
CREATE DATABASE IF NOT EXISTS `db_emp_calzado_john`
    CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE `db_emp_calzado_john`;

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

-- ================= BASE 2/26: db_emp_alju =================

-- ============================================================
-- BASE DE DATOS OPERATIVA: db_emp_alju
-- ============================================================
CREATE DATABASE IF NOT EXISTS `db_emp_alju`
    CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE `db_emp_alju`;

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

-- ================= BASE 3/26: db_emp_lufeli =================

-- ============================================================
-- BASE DE DATOS OPERATIVA: db_emp_lufeli
-- ============================================================
CREATE DATABASE IF NOT EXISTS `db_emp_lufeli`
    CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE `db_emp_lufeli`;

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

-- ================= BASE 4/26: db_emp_helados_golositos =================

-- ============================================================
-- BASE DE DATOS OPERATIVA: db_emp_helados_golositos
-- ============================================================
CREATE DATABASE IF NOT EXISTS `db_emp_helados_golositos`
    CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE `db_emp_helados_golositos`;

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

-- ================= BASE 5/26: db_emp_heladeria_karito =================

-- ============================================================
-- BASE DE DATOS OPERATIVA: db_emp_heladeria_karito
-- ============================================================
CREATE DATABASE IF NOT EXISTS `db_emp_heladeria_karito`
    CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE `db_emp_heladeria_karito`;

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

-- ================= BASE 6/26: db_emp_conos_kelvin =================

-- ============================================================
-- BASE DE DATOS OPERATIVA: db_emp_conos_kelvin
-- ============================================================
CREATE DATABASE IF NOT EXISTS `db_emp_conos_kelvin`
    CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE `db_emp_conos_kelvin`;

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

-- ================= BASE 7/26: db_emp_turrones_don_goyo =================

-- ============================================================
-- BASE DE DATOS OPERATIVA: db_emp_turrones_don_goyo
-- ============================================================
CREATE DATABASE IF NOT EXISTS `db_emp_turrones_don_goyo`
    CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE `db_emp_turrones_don_goyo`;

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

-- ================= BASE 8/26: db_emp_razu_corp =================

-- ============================================================
-- BASE DE DATOS OPERATIVA: db_emp_razu_corp
-- ============================================================
CREATE DATABASE IF NOT EXISTS `db_emp_razu_corp`
    CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE `db_emp_razu_corp`;

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

-- ================= BASE 9/26: db_emp_bodega_ga =================

-- ============================================================
-- BASE DE DATOS OPERATIVA: db_emp_bodega_ga
-- ============================================================
CREATE DATABASE IF NOT EXISTS `db_emp_bodega_ga`
    CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE `db_emp_bodega_ga`;

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

-- ================= BASE 10/26: db_emp_sirackagro =================

-- ============================================================
-- BASE DE DATOS OPERATIVA: db_emp_sirackagro
-- ============================================================
CREATE DATABASE IF NOT EXISTS `db_emp_sirackagro`
    CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE `db_emp_sirackagro`;

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

-- ================= BASE 11/26: db_emp_vinos_san_juan =================

-- ============================================================
-- BASE DE DATOS OPERATIVA: db_emp_vinos_san_juan
-- ============================================================
CREATE DATABASE IF NOT EXISTS `db_emp_vinos_san_juan`
    CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE `db_emp_vinos_san_juan`;

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


-- ================= BASE 13/26: db_emp_granja_ainhoa =================

-- ============================================================
-- BASE DE DATOS OPERATIVA: db_emp_granja_ainhoa
-- ============================================================
CREATE DATABASE IF NOT EXISTS `db_emp_granja_ainhoa`
    CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE `db_emp_granja_ainhoa`;

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


-- ================= BASE 15/26: db_emp_vinos_mm =================

-- ============================================================
-- BASE DE DATOS OPERATIVA: db_emp_vinos_mm
-- ============================================================
CREATE DATABASE IF NOT EXISTS `db_emp_vinos_mm`
    CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE `db_emp_vinos_mm`;

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

-- ================= BASE 16/26: db_emp_barros_nicole =================

-- ============================================================
-- BASE DE DATOS OPERATIVA: db_emp_barros_nicole
-- ============================================================
CREATE DATABASE IF NOT EXISTS `db_emp_barros_nicole`
    CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE `db_emp_barros_nicole`;

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

-- ================= BASE 17/26: db_emp_vinos_mopocita =================

-- ============================================================
-- BASE DE DATOS OPERATIVA: db_emp_vinos_mopocita
-- ============================================================
CREATE DATABASE IF NOT EXISTS `db_emp_vinos_mopocita`
    CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE `db_emp_vinos_mopocita`;

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

-- ================= BASE 18/26: db_emp_vinos_don_bolo =================

-- ============================================================
-- BASE DE DATOS OPERATIVA: db_emp_vinos_don_bolo
-- ============================================================
CREATE DATABASE IF NOT EXISTS `db_emp_vinos_don_bolo`
    CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE `db_emp_vinos_don_bolo`;

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

-- ================= BASE 19/26: db_emp_granja_san_jose =================

-- ============================================================
-- BASE DE DATOS OPERATIVA: db_emp_granja_san_jose
-- ============================================================
CREATE DATABASE IF NOT EXISTS `db_emp_granja_san_jose`
    CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE `db_emp_granja_san_jose`;

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

-- ================= BASE 20/26: db_emp_museo_santa_lucia =================

-- ============================================================
-- BASE DE DATOS OPERATIVA: db_emp_museo_santa_lucia
-- ============================================================
CREATE DATABASE IF NOT EXISTS `db_emp_museo_santa_lucia`
    CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE `db_emp_museo_santa_lucia`;

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

-- ================= BASE 21/26: db_emp_granja_san_martin =================

-- ============================================================
-- BASE DE DATOS OPERATIVA: db_emp_granja_san_martin
-- ============================================================
CREATE DATABASE IF NOT EXISTS `db_emp_granja_san_martin`
    CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE `db_emp_granja_san_martin`;

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

-- ================= BASE 23/26: db_emp_san_miguel =================

-- ============================================================
-- BASE DE DATOS OPERATIVA: db_emp_san_miguel
-- ============================================================
CREATE DATABASE IF NOT EXISTS `db_emp_san_miguel`
    CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE `db_emp_san_miguel`;

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

-- ================= BASE 24/26: db_emp_union_hermandad =================

-- ============================================================
-- BASE DE DATOS OPERATIVA: db_emp_union_hermandad
-- ============================================================
CREATE DATABASE IF NOT EXISTS `db_emp_union_hermandad`
    CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE `db_emp_union_hermandad`;

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

-- ================= BASE 25/26: db_emp_asoc_quinchicoto =================

-- ============================================================
-- BASE DE DATOS OPERATIVA: db_emp_asoc_quinchicoto
-- ============================================================
CREATE DATABASE IF NOT EXISTS `db_emp_asoc_quinchicoto`
    CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE `db_emp_asoc_quinchicoto`;

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

-- ================= BASE 26/26: db_emp_union_tisalena =================

-- ============================================================
-- BASE DE DATOS OPERATIVA: db_emp_union_tisalena
-- ============================================================
CREATE DATABASE IF NOT EXISTS `db_emp_union_tisalena`
    CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE `db_emp_union_tisalena`;

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
