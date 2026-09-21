USE facturacion;
GO

IF OBJECT_ID(N'dbo.direccion', N'U') IS NULL
    BEGIN
        CREATE TABLE dbo.direccion
        (
            id_direccion BIGINT IDENTITY (1, 1) NOT NULL,
            id_provincia TINYINT NOT NULL,
            id_canton SMALLINT NOT NULL,
            id_distrito SMALLINT NOT NULL,
            senas_exactas NVARCHAR(500) NOT NULL,

            CONSTRAINT [PK_direccion]
            PRIMARY KEY (id_direccion),
            CONSTRAINT [FK_direccion_distrito]
            FOREIGN KEY (id_provincia, id_canton, id_distrito)
            REFERENCES dbo.distrito (id_provincia, id_canton, id_distrito),
            CONSTRAINT [CK_direccion_senas_no_vacias]
            CHECK (TRIM(senas_exactas) <> N'')
        );
    END;
GO
