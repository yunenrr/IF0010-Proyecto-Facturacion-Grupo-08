USE facturacion;
GO

SET NOCOUNT ON;
SET XACT_ABORT ON;
GO

IF OBJECT_ID(N'dbo.cliente', N'U') IS NULL
    BEGIN
        CREATE TABLE dbo.cliente
        (
            id_cliente INT IDENTITY (1, 1) NOT NULL,
            id_direccion BIGINT NOT NULL,
            cedula VARCHAR(20) NOT NULL,
            nombre_razon_social NVARCHAR(250) NOT NULL,
            telefono VARCHAR(20) NOT NULL,
            correo_electronico VARCHAR(254) NOT NULL,
            fecha_registro DATETIME2(7) NOT NULL
            CONSTRAINT [DF_cliente_fecha_registro] DEFAULT (SYSDATETIME()),
            fecha_ultima_actualizacion DATETIME2(7) NOT NULL
            CONSTRAINT [DF_cliente_fecha_actualizacion] DEFAULT (SYSDATETIME()),

            CONSTRAINT [PK_cliente]
            PRIMARY KEY CLUSTERED (id_cliente),
            CONSTRAINT [UQ_cliente_direccion]
            UNIQUE NONCLUSTERED (id_direccion),
            CONSTRAINT [FK_cliente_direccion]
            FOREIGN KEY (id_direccion)
            REFERENCES dbo.direccion (id_direccion),
            CONSTRAINT [CK_cliente_cedula_no_vacia]
            CHECK (LTRIM(RTRIM(cedula)) <> ''),
            CONSTRAINT [CK_cliente_nombre_no_vacio]
            CHECK (LTRIM(RTRIM(nombre_razon_social)) <> N''),
            CONSTRAINT [CK_cliente_telefono_no_vacio]
            CHECK (LTRIM(RTRIM(telefono)) <> ''),
            CONSTRAINT [CK_cliente_correo_no_vacio]
            CHECK (LTRIM(RTRIM(correo_electronico)) <> ''),
            CONSTRAINT [CK_cliente_fechas]
            CHECK (fecha_ultima_actualizacion >= fecha_registro)
        );
    END;
GO
