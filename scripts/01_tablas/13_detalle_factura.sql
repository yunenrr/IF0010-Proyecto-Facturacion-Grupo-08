USE facturacion;
GO

IF OBJECT_ID(N'dbo.detalle_factura', N'U') IS NULL
    BEGIN
        CREATE TABLE dbo.detalle_factura
        (
            id_factura BIGINT NOT NULL,
            numero_linea SMALLINT NOT NULL,
            id_producto_servicio INT NOT NULL,
            descripcion_linea NVARCHAR(500) NOT NULL,
            cantidad DECIMAL(18, 4) NOT NULL,
            precio_unitario DECIMAL(19, 4) NOT NULL,
            porcentaje_impuesto DECIMAL(5, 2) NOT NULL,
            monto_descuento DECIMAL(19, 4) NOT NULL
            CONSTRAINT [DF_detalle_factura_descuento] DEFAULT (0),
            subtotal_linea DECIMAL(19, 4) NOT NULL,
            monto_impuesto DECIMAL(19, 4) NOT NULL,
            monto_total_linea DECIMAL(19, 4) NOT NULL,

            CONSTRAINT [PK_detalle_factura]
            PRIMARY KEY (id_factura, numero_linea),
            CONSTRAINT [FK_detalle_factura_factura]
            FOREIGN KEY (id_factura)
            REFERENCES dbo.factura (id_factura),
            CONSTRAINT [FK_detalle_factura_producto_servicio]
            FOREIGN KEY (id_producto_servicio)
            REFERENCES dbo.producto_servicio (id_producto_servicio),
            CONSTRAINT [CK_detalle_factura_numero_linea]
            CHECK (numero_linea > 0),
            CONSTRAINT [CK_detalle_factura_descripcion_no_vacia]
            CHECK (TRIM(descripcion_linea) <> N''),
            CONSTRAINT [CK_detalle_factura_cantidad]
            CHECK (cantidad > 0),
            CONSTRAINT [CK_detalle_factura_precio_positivo]
            CHECK (precio_unitario > 0),
            CONSTRAINT [CK_detalle_factura_impuesto]
            CHECK (porcentaje_impuesto >= 0 AND porcentaje_impuesto <= 100),
            CONSTRAINT [CK_detalle_factura_descuento]
            CHECK (monto_descuento >= 0),
            CONSTRAINT [CK_detalle_factura_total_no_negativo]
            CHECK (monto_total_linea >= 0)
        );
    END;
GO
