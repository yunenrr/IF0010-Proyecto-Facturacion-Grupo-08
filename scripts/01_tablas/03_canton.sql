USE facturacion;
GO

SET NOCOUNT ON;
SET XACT_ABORT ON;
GO

IF OBJECT_ID(N'dbo.canton', N'U') IS NULL
    BEGIN
        CREATE TABLE dbo.canton
        (
            id_canton SMALLINT IDENTITY (1, 1) NOT NULL,
            id_provincia TINYINT NOT NULL,
            nombre_canton NVARCHAR(100) NOT NULL,

            CONSTRAINT [PK_canton]
            PRIMARY KEY CLUSTERED (id_canton),
            CONSTRAINT [UQ_canton_provincia_nombre]
            UNIQUE NONCLUSTERED (id_provincia, nombre_canton),
            CONSTRAINT [FK_canton_provincia]
            FOREIGN KEY (id_provincia)
            REFERENCES dbo.provincia (id_provincia),
            CONSTRAINT [CK_canton_nombre_no_vacio]
            CHECK (LTRIM(RTRIM(nombre_canton)) <> N'')
        );
    END;
GO
