USE facturacion;
GO

IF OBJECT_ID(N'dbo.distrito', N'U') IS NULL
    BEGIN
        CREATE TABLE dbo.distrito
        (
            id_provincia TINYINT NOT NULL,
            id_canton SMALLINT NOT NULL,
            -- Codigo oficial de distrito dentro de su canton y provincia.
            id_distrito SMALLINT NOT NULL,
            nombre_distrito NVARCHAR(100) NOT NULL,

            CONSTRAINT [PK_distrito]
            PRIMARY KEY (id_provincia, id_canton, id_distrito),
            CONSTRAINT [FK_distrito_canton]
            FOREIGN KEY (id_provincia, id_canton)
            REFERENCES dbo.canton (id_provincia, id_canton),
            CONSTRAINT [CK_distrito_nombre_no_vacio]
            CHECK (TRIM(nombre_distrito) <> N'')
        );
    END;
GO
