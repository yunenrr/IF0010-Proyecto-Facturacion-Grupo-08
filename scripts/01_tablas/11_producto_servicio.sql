USE facturacion;
GO

IF OBJECT_ID(N'dbo.producto_servicio', N'U') IS NULL
    BEGIN
        -- Datos comunes; los datos propios van en producto o servicio.
        CREATE TABLE dbo.producto_servicio
        (
            id_producto_servicio INT IDENTITY (1, 1) NOT NULL,
            tipo_producto_servicio VARCHAR(8) NOT NULL,
            codigo_interno VARCHAR(30) NOT NULL,
            descripcion NVARCHAR(500) NOT NULL,
            precio_unitario_lista DECIMAL(19, 4) NOT NULL,
            porcentaje_impuesto DECIMAL(5, 2) NOT NULL,
            activo BIT NOT NULL
            CONSTRAINT [DF_producto_servicio_activo] DEFAULT (1),
            fecha_creacion DATETIME2(7) NOT NULL
            CONSTRAINT [DF_producto_servicio_fecha_creacion] DEFAULT (
                SYSDATETIME()
            ),

            CONSTRAINT [PK_producto_servicio]
            PRIMARY KEY (id_producto_servicio),
            CONSTRAINT [CK_producto_servicio_tipo]
            CHECK (tipo_producto_servicio IN ('PRODUCTO', 'SERVICIO')),
            CONSTRAINT [CK_producto_servicio_codigo_no_vacio]
            CHECK (TRIM(codigo_interno) <> ''),
            CONSTRAINT [CK_producto_servicio_descripcion_no_vacia]
            CHECK (TRIM(descripcion) <> N''),
            CONSTRAINT [CK_producto_servicio_precio_positivo]
            CHECK (precio_unitario_lista > 0),
            CONSTRAINT [CK_producto_servicio_impuesto]
            CHECK (porcentaje_impuesto >= 0 AND porcentaje_impuesto <= 100)
        );
    END;
GO
