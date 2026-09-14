USE facturacion;
GO

IF OBJECT_ID(N'dbo.producto', N'U') IS NULL
    BEGIN
        CREATE TABLE dbo.producto
        (
            id_producto_servicio INT NOT NULL,
            tipo_producto_servicio VARCHAR(8) NOT NULL
            CONSTRAINT [DF_producto_tipo] DEFAULT ('PRODUCTO'),
            existencias DECIMAL(18, 4) NOT NULL,

            CONSTRAINT [PK_producto]
            PRIMARY KEY (id_producto_servicio),
            CONSTRAINT [CK_producto_tipo]
            CHECK (tipo_producto_servicio = 'PRODUCTO'),
            CONSTRAINT [CK_producto_existencias]
            CHECK (existencias >= 0)
        );
    END;
GO

-- La FK se agrega en 02_indices/17_uq_producto_servicio_id_tipo.sql.
