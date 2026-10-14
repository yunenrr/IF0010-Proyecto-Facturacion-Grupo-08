USE facturacion;
GO

CREATE TABLE dbo.detalle_factura
(
    id_factura BIGINT NOT NULL,
    numero_linea SMALLINT NOT NULL,
    id_producto_servicio INT NOT NULL,
    id_descripcion INT NOT NULL,
    cantidad DECIMAL(18, 4) NOT NULL,
    precio_unitario DECIMAL(19, 4) NOT NULL,
    porcentaje_impuesto DECIMAL(5, 2) NOT NULL,
    monto_descuento DECIMAL(19, 4) NOT NULL,
    subtotal_linea DECIMAL(19, 4) NOT NULL,
    monto_impuesto DECIMAL(19, 4) NOT NULL,
    monto_total_linea DECIMAL(19, 4) NOT NULL,
    CONSTRAINT [PK_detalle_factura] PRIMARY KEY (id_factura, numero_linea),
    CONSTRAINT [FK_detalle_factura_factura] FOREIGN KEY (
        id_factura
    ) REFERENCES dbo.factura (id_factura),
    CONSTRAINT [FK_detalle_factura_producto_servicio] FOREIGN KEY (
        id_producto_servicio
    ) REFERENCES dbo.producto_servicio (id_producto_servicio),
    CONSTRAINT [FK_detalle_factura_descripcion_articulo] FOREIGN KEY (
        id_descripcion
    ) REFERENCES dbo.descripcion_articulo (id_descripcion)
);
GO
