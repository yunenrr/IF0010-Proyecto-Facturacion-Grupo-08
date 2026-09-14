USE facturacion;
GO

IF OBJECT_ID(N'dbo.factura', N'U') IS NULL
    BEGIN
        CREATE TABLE dbo.factura
        (
            id_factura BIGINT IDENTITY (1, 1) NOT NULL,
            identificador_comprobante VARCHAR(40) NOT NULL,
            id_empresa INT NOT NULL,
            id_cliente INT NOT NULL,
            codigo_tipo_documento VARCHAR(10) NOT NULL,
            codigo_moneda CHAR(3) NOT NULL,
            codigo_estado VARCHAR(15) NOT NULL,
            fecha_emision DATETIME2(0) NOT NULL,
            subtotal DECIMAL(19, 4) NOT NULL,
            total_descuentos DECIMAL(19, 4) NOT NULL
            CONSTRAINT [DF_factura_total_descuentos] DEFAULT (0),
            total_impuestos DECIMAL(19, 4) NOT NULL
            CONSTRAINT [DF_factura_total_impuestos] DEFAULT (0),
            monto_total DECIMAL(19, 4) NOT NULL,
            observaciones NVARCHAR(1000) NULL,
            fecha_creacion DATETIME2(7) NOT NULL
            CONSTRAINT [DF_factura_fecha_creacion] DEFAULT (SYSDATETIME()),
            fecha_modificacion DATETIME2(7) NOT NULL
            CONSTRAINT [DF_factura_fecha_modificacion] DEFAULT (SYSDATETIME()),

            CONSTRAINT [PK_factura]
            PRIMARY KEY (id_factura),
            CONSTRAINT [FK_factura_empresa_emisora]
            FOREIGN KEY (id_empresa)
            REFERENCES dbo.empresa_emisora (id_empresa),
            CONSTRAINT [FK_factura_cliente]
            FOREIGN KEY (id_cliente)
            REFERENCES dbo.cliente (id_cliente),
            CONSTRAINT [FK_factura_tipo_documento]
            FOREIGN KEY (codigo_tipo_documento)
            REFERENCES dbo.tipo_documento (codigo_tipo_documento),
            CONSTRAINT [FK_factura_moneda]
            FOREIGN KEY (codigo_moneda)
            REFERENCES dbo.moneda (codigo_moneda),
            CONSTRAINT [FK_factura_estado]
            FOREIGN KEY (codigo_estado)
            REFERENCES dbo.estado_factura (codigo_estado),
            CONSTRAINT [CK_factura_subtotal_positivo]
            CHECK (subtotal > 0),
            CONSTRAINT [CK_factura_descuentos]
            CHECK (total_descuentos >= 0 AND total_descuentos <= subtotal),
            CONSTRAINT [CK_factura_impuestos_no_negativos]
            CHECK (total_impuestos >= 0),
            CONSTRAINT [CK_factura_total_no_negativo]
            CHECK (monto_total >= 0),
            CONSTRAINT [CK_factura_fechas]
            CHECK (fecha_modificacion >= fecha_creacion)
        );
    END;
GO
