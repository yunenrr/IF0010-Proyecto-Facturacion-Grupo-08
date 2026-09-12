USE facturacion;
GO

SET NOCOUNT ON;
SET XACT_ABORT ON;
GO

IF OBJECT_ID(N'dbo.provincia', N'U') IS NULL
    BEGIN
        CREATE TABLE dbo.provincia
        (
            id_provincia TINYINT IDENTITY (1, 1) NOT NULL,
            nombre_provincia NVARCHAR(100) NOT NULL,

            CONSTRAINT [PK_provincia]
            PRIMARY KEY CLUSTERED (id_provincia),
            CONSTRAINT [UQ_provincia_nombre]
            UNIQUE NONCLUSTERED (nombre_provincia),
            CONSTRAINT [CK_provincia_nombre_no_vacio]
            CHECK (LTRIM(RTRIM(nombre_provincia)) <> N'')
        );
    END;
GO
