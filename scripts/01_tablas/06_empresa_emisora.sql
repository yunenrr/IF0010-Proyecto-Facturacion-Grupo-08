USE facturacion;
GO

IF OBJECT_ID(N'dbo.empresa_emisora', N'U') IS NULL
    BEGIN
        CREATE TABLE dbo.empresa_emisora
        (
            id_empresa INT IDENTITY (1, 1) NOT NULL,
            id_direccion BIGINT NOT NULL,
            cedula VARCHAR(20) NOT NULL,
            nombre_comercial NVARCHAR(200) NOT NULL,
            razon_social NVARCHAR(250) NOT NULL,
            telefono VARCHAR(20) NOT NULL,
            correo_electronico VARCHAR(254) NOT NULL,
            fecha_creacion DATETIME2(7) NOT NULL
            CONSTRAINT [DF_empresa_emisora_fecha_creacion] DEFAULT (
                SYSDATETIME()
            ),
            activo BIT NOT NULL
            CONSTRAINT [DF_empresa_emisora_activo] DEFAULT (1),

            CONSTRAINT [PK_empresa_emisora]
            PRIMARY KEY (id_empresa),
            CONSTRAINT [FK_empresa_emisora_direccion]
            FOREIGN KEY (id_direccion)
            REFERENCES dbo.direccion (id_direccion),
            CONSTRAINT [CK_empresa_emisora_cedula_no_vacia]
            CHECK (TRIM(cedula) <> ''),
            CONSTRAINT [CK_empresa_emisora_nombre_no_vacio]
            CHECK (TRIM(nombre_comercial) <> N''),
            CONSTRAINT [CK_empresa_emisora_razon_no_vacia]
            CHECK (TRIM(razon_social) <> N''),
            CONSTRAINT [CK_empresa_emisora_telefono_no_vacio]
            CHECK (TRIM(telefono) <> ''),
            CONSTRAINT [CK_empresa_emisora_correo_no_vacio]
            CHECK (TRIM(correo_electronico) <> '')
        );
    END;
GO
