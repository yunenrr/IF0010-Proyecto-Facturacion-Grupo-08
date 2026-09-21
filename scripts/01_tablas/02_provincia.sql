USE facturacion;
GO

IF OBJECT_ID(N'dbo.provincia', N'U') IS NULL
    BEGIN
        CREATE TABLE dbo.provincia
        (
            -- Codigo oficial proporcionado al cargar el catalogo.
            id_provincia TINYINT NOT NULL,
            nombre_provincia NVARCHAR(100) NOT NULL,

            CONSTRAINT [PK_provincia]
            PRIMARY KEY (id_provincia),
            CONSTRAINT [CK_provincia_nombre_no_vacio]
            CHECK (TRIM(nombre_provincia) <> N'')
        );
    END;
GO
