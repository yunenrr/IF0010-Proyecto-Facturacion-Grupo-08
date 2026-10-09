USE facturacion;
GO

CREATE TYPE dbo.detalle_factura_entrada AS TABLE
(
    numero_linea SMALLINT NOT NULL,
    id_producto_servicio INT NOT NULL,
    cantidad DECIMAL(18, 4) NOT NULL,
    precio_unitario DECIMAL(19, 4) NOT NULL,
    porcentaje_impuesto DECIMAL(5, 2) NOT NULL,
    monto_descuento DECIMAL(19, 4) NOT NULL
);
GO
