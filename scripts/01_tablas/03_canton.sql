USE facturacion;
GO

IF OBJECT_ID(N'dbo.canton', N'U') IS NULL
    BEGIN
        CREATE TABLE dbo.canton
        (
            id_provincia TINYINT NOT NULL,
            -- Codigo oficial de canton dentro de su provincia.
            id_canton SMALLINT NOT NULL,
            nombre_canton NVARCHAR(100) NOT NULL,

            CONSTRAINT [PK_canton]
            PRIMARY KEY (id_provincia, id_canton),
            CONSTRAINT [FK_canton_provincia]
            FOREIGN KEY (id_provincia)
            REFERENCES dbo.provincia (id_provincia),
            CONSTRAINT [CK_canton_nombre_no_vacio]
            CHECK (TRIM(nombre_canton) <> N'')
        );
    END;
GO
