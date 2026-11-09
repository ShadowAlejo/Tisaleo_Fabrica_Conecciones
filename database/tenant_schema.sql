-- Select one tenant database in the SQL client, then import this file.
-- The central database owns users, roles, emprendimientos and access mappings.
-- usuario_id values below refer to the central usuarios.id and intentionally have no cross-database foreign key.

CREATE TABLE productos (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    codigo VARCHAR(60) NULL,
    nombre VARCHAR(150) NOT NULL,
    descripcion TEXT NULL,
    cantidad DECIMAL(12,2) UNSIGNED NOT NULL DEFAULT 0,
    stock_minimo DECIMAL(12,2) UNSIGNED NOT NULL DEFAULT 0,
    categoria_unidad VARCHAR(100) NOT NULL,
    unidad_medida VARCHAR(50) NOT NULL,
    precio DECIMAL(10,2) NOT NULL,
    activo BOOLEAN NOT NULL DEFAULT TRUE,
    fec_creacion TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    fec_actualizacion TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    fec_eliminacion TIMESTAMP NULL DEFAULT NULL,
    CONSTRAINT chk_productos_precio CHECK (precio >= 0),
    UNIQUE KEY uq_productos_codigo (codigo),
    INDEX idx_productos_nombre (nombre),
    INDEX idx_productos_activo (activo, fec_eliminacion)
) ENGINE=InnoDB;

CREATE TABLE servicios (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(150) NOT NULL,
    categoria VARCHAR(100) NULL,
    descripcion TEXT NULL,
    precio DECIMAL(10,2) NOT NULL,
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
    INDEX idx_servicios_estado (estado, fec_eliminacion)
) ENGINE=InnoDB;

CREATE TABLE ventas (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    usuario_id BIGINT UNSIGNED NULL,
    fecha_venta DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    estado VARCHAR(30) NOT NULL DEFAULT 'completada',
    metodo_pago VARCHAR(40) NULL,
    subtotal DECIMAL(12,2) NOT NULL DEFAULT 0,
    descuento DECIMAL(12,2) NOT NULL DEFAULT 0,
    impuesto DECIMAL(12,2) NOT NULL DEFAULT 0,
    total DECIMAL(12,2) NOT NULL DEFAULT 0,
    observaciones TEXT NULL,
    fec_creacion TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    fec_actualizacion TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    fec_eliminacion TIMESTAMP NULL DEFAULT NULL,
    CONSTRAINT chk_ventas_subtotal CHECK (subtotal >= 0),
    CONSTRAINT chk_ventas_descuento CHECK (descuento >= 0),
    CONSTRAINT chk_ventas_impuesto CHECK (impuesto >= 0),
    CONSTRAINT chk_ventas_total CHECK (total >= 0),
    INDEX idx_ventas_fecha (fec_eliminacion, fecha_venta),
    INDEX idx_ventas_usuario (usuario_id),
    INDEX idx_ventas_estado (estado)
) ENGINE=InnoDB;

CREATE TABLE detalle_venta (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    venta_id BIGINT UNSIGNED NOT NULL,
    producto_id BIGINT UNSIGNED NULL,
    servicio_id BIGINT UNSIGNED NULL,
    nombre_item VARCHAR(150) NOT NULL,
    cantidad DECIMAL(12,2) NOT NULL DEFAULT 1,
    precio_unitario DECIMAL(10,2) NOT NULL,
    descuento DECIMAL(12,2) NOT NULL DEFAULT 0,
    subtotal DECIMAL(12,2) NOT NULL,
    fec_creacion TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    fec_actualizacion TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    fec_eliminacion TIMESTAMP NULL DEFAULT NULL,
    CONSTRAINT chk_detalle_un_solo_item CHECK (
        (producto_id IS NOT NULL AND servicio_id IS NULL)
        OR (producto_id IS NULL AND servicio_id IS NOT NULL)
    ),
    CONSTRAINT chk_detalle_cantidad CHECK (cantidad > 0),
    CONSTRAINT chk_detalle_precio CHECK (precio_unitario >= 0),
    CONSTRAINT chk_detalle_descuento CHECK (descuento >= 0),
    CONSTRAINT chk_detalle_subtotal CHECK (subtotal >= 0),
    CONSTRAINT fk_detalle_venta FOREIGN KEY (venta_id)
        REFERENCES ventas(id) ON UPDATE CASCADE ON DELETE RESTRICT,
    CONSTRAINT fk_detalle_producto FOREIGN KEY (producto_id)
        REFERENCES productos(id) ON DELETE RESTRICT,
    CONSTRAINT fk_detalle_servicio FOREIGN KEY (servicio_id)
        REFERENCES servicios(id) ON DELETE RESTRICT,
    INDEX idx_detalle_venta (venta_id, fec_eliminacion),
    INDEX idx_detalle_producto (producto_id),
    INDEX idx_detalle_servicio (servicio_id)
) ENGINE=InnoDB;

CREATE TABLE movimientos_inventario (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    producto_id BIGINT UNSIGNED NOT NULL,
    usuario_id BIGINT UNSIGNED NULL,
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
) ENGINE=InnoDB;

CREATE TABLE terminos_condiciones (
    id TINYINT UNSIGNED PRIMARY KEY,
    contenido LONGTEXT NOT NULL,
    activo BOOLEAN NOT NULL DEFAULT TRUE,
    fec_creacion TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    fec_actualizacion TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    fec_eliminacion TIMESTAMP NULL DEFAULT NULL,
    CONSTRAINT chk_unico_documento_terminos CHECK (id = 1)
) ENGINE=InnoDB;

CREATE TABLE aceptaciones_terminos (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    usuario_id BIGINT UNSIGNED NOT NULL,
    terminos_condiciones_id TINYINT UNSIGNED NOT NULL DEFAULT 1,
    aceptado_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    direccion_ip VARCHAR(45) NULL,
    user_agent VARCHAR(500) NULL,
    fec_creacion TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    fec_actualizacion TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    fec_eliminacion TIMESTAMP NULL DEFAULT NULL,
    CONSTRAINT fk_aceptaciones_terminos FOREIGN KEY (terminos_condiciones_id)
        REFERENCES terminos_condiciones(id) ON UPDATE CASCADE ON DELETE RESTRICT,
    UNIQUE KEY uq_aceptacion_usuario_terminos (usuario_id, terminos_condiciones_id)
) ENGINE=InnoDB;

CREATE TABLE imagenes (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    producto_id BIGINT UNSIGNED NULL,
    servicio_id BIGINT UNSIGNED NULL,
    url VARCHAR(500) NOT NULL,
    texto_alternativo VARCHAR(255) NULL,
    orden SMALLINT UNSIGNED NOT NULL DEFAULT 0,
    fec_creacion TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    fec_actualizacion TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    fec_eliminacion TIMESTAMP NULL DEFAULT NULL,
    CONSTRAINT chk_imagen_un_solo_destino CHECK (
        (producto_id IS NOT NULL AND servicio_id IS NULL)
        OR (producto_id IS NULL AND servicio_id IS NOT NULL)
    ),
    CONSTRAINT fk_imagen_producto FOREIGN KEY (producto_id)
        REFERENCES productos(id) ON DELETE RESTRICT,
    CONSTRAINT fk_imagen_servicio FOREIGN KEY (servicio_id)
        REFERENCES servicios(id) ON DELETE RESTRICT,
    INDEX idx_imagen_producto (producto_id),
    INDEX idx_imagen_servicio (servicio_id)
) ENGINE=InnoDB;

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
    INDEX idx_auditoria_usuario_fecha (usuario_id, fec_creacion),
    INDEX idx_auditoria_registro (tabla_afectada, registro_id),
    INDEX idx_auditoria_fecha (fec_creacion)
) ENGINE=InnoDB;
