USE facturacion;
GO

SET ANSI_NULLS ON;
SET ANSI_PADDING ON;
SET ANSI_WARNINGS ON;
SET ARITHABORT ON;
SET CONCAT_NULL_YIELDS_NULL ON;
SET QUOTED_IDENTIFIER ON;
SET NUMERIC_ROUNDABORT OFF;
GO

SET NOCOUNT ON;
SET XACT_ABORT ON;
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
            subtotal_linea AS
            CONVERT(DECIMAL(19, 4), cantidad * precio_unitario)
            PERSISTED,
            -- Redondear cada importe monetario a cuatro decimales
            -- antes de sumarlo.
            -- Se repite la expresion: una columna calculada no puede usar otra.
            monto_impuesto AS
            CONVERT(
                DECIMAL(19, 4),
                (
                    CONVERT(DECIMAL(19, 4), cantidad * precio_unitario)
                    - monto_descuento
                )
                * (porcentaje_impuesto / CONVERT(DECIMAL(5, 2), 100.00))
            ) PERSISTED,
            monto_total_linea AS
            CONVERT(
                DECIMAL(19, 4),
                (
                    CONVERT(DECIMAL(19, 4), cantidad * precio_unitario)
                    - monto_descuento
                )
                +
                CONVERT(
                    DECIMAL(19, 4),
                    (
                        CONVERT(DECIMAL(19, 4), cantidad * precio_unitario)
                        - monto_descuento
                    )
                    * (porcentaje_impuesto / CONVERT(DECIMAL(5, 2), 100.00))
                )
            ) PERSISTED,

            CONSTRAINT [PK_detalle_factura]
            PRIMARY KEY CLUSTERED (id_factura, numero_linea),
            CONSTRAINT [FK_detalle_factura_factura]
            FOREIGN KEY (id_factura)
            REFERENCES dbo.factura (id_factura),
            CONSTRAINT [FK_detalle_factura_producto_servicio]
            FOREIGN KEY (id_producto_servicio)
            REFERENCES dbo.producto_servicio (id_producto_servicio),
            CONSTRAINT [CK_detalle_factura_numero_linea]
            CHECK (numero_linea > 0),
            CONSTRAINT [CK_detalle_factura_descripcion_no_vacia]
            CHECK (LTRIM(RTRIM(descripcion_linea)) <> N''),
            CONSTRAINT [CK_detalle_factura_cantidad]
            CHECK (cantidad > 0),
            CONSTRAINT [CK_detalle_factura_precio_no_negativo]
            CHECK (precio_unitario >= 0),
            CONSTRAINT [CK_detalle_factura_impuesto]
            CHECK (porcentaje_impuesto >= 0 AND porcentaje_impuesto <= 100),
            CONSTRAINT [CK_detalle_factura_descuento]
            CHECK
            (
                monto_descuento >= 0
                AND monto_descuento
                <= CONVERT(DECIMAL(19, 4), cantidad * precio_unitario)
            ),
            CONSTRAINT [CK_detalle_factura_total_no_negativo]
            CHECK (monto_total_linea >= 0)
        );
    END;
GO
