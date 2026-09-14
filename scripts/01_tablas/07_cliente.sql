USE facturacion;
GO

IF OBJECT_ID(N'dbo.cliente', N'U') IS NULL
    BEGIN
        CREATE TABLE dbo.cliente
        (
            id_cliente INT IDENTITY (1, 1) NOT NULL,
            id_direccion BIGINT NOT NULL,
            cedula VARCHAR(20) NOT NULL,
            tipo_persona VARCHAR(8) NOT NULL,
            nombre_persona NVARCHAR(250) NULL,
            razon_social NVARCHAR(250) NULL,
            telefono VARCHAR(20) NOT NULL,
            correo_electronico VARCHAR(254) NOT NULL,
            fecha_registro DATETIME2(7) NOT NULL
            CONSTRAINT [DF_cliente_fecha_registro] DEFAULT (SYSDATETIME()),
            fecha_ultima_actualizacion DATETIME2(7) NOT NULL
            CONSTRAINT [DF_cliente_fecha_actualizacion] DEFAULT (SYSDATETIME()),

            CONSTRAINT [PK_cliente]
            PRIMARY KEY (id_cliente),
            CONSTRAINT [FK_cliente_direccion]
            FOREIGN KEY (id_direccion)
            REFERENCES dbo.direccion (id_direccion),
            CONSTRAINT [CK_cliente_cedula_no_vacia]
            CHECK (TRIM(cedula) <> ''),
            CONSTRAINT [CK_cliente_tipo_persona]
            CHECK (tipo_persona IN ('FISICA', 'JURIDICA')),
            CONSTRAINT [CK_cliente_nombre_segun_tipo]
            CHECK
            (
                (
                    tipo_persona = 'FISICA'
                    AND nombre_persona IS NOT NULL
                    AND TRIM(nombre_persona) <> N''
                    AND razon_social IS NULL
                )
                OR
                (
                    tipo_persona = 'JURIDICA'
                    AND razon_social IS NOT NULL
                    AND TRIM(razon_social) <> N''
                    AND nombre_persona IS NULL
                )
            ),
            CONSTRAINT [CK_cliente_telefono_no_vacio]
            CHECK (TRIM(telefono) <> ''),
            CONSTRAINT [CK_cliente_correo_no_vacio]
            CHECK (TRIM(correo_electronico) <> ''),
            CONSTRAINT [CK_cliente_fechas]
            CHECK (fecha_ultima_actualizacion >= fecha_registro)
        );
    END;
GO
