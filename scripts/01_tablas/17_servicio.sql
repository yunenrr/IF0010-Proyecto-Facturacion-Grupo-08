USE facturacion;
GO

IF OBJECT_ID(N'dbo.servicio', N'U') IS NULL
    BEGIN
        CREATE TABLE dbo.servicio
        (
            id_producto_servicio INT NOT NULL,
            tipo_producto_servicio VARCHAR(8) NOT NULL
            CONSTRAINT [DF_servicio_tipo] DEFAULT ('SERVICIO'),
            unidad_cobro NVARCHAR(50) NOT NULL,

            CONSTRAINT [PK_servicio]
            PRIMARY KEY (id_producto_servicio),
            CONSTRAINT [CK_servicio_tipo]
            CHECK (tipo_producto_servicio = 'SERVICIO'),
            CONSTRAINT [CK_servicio_unidad_no_vacia]
            CHECK (TRIM(unidad_cobro) <> N'')
        );
    END;
GO

-- La FK se agrega en 02_indices/17_uq_producto_servicio_id_tipo.sql.
