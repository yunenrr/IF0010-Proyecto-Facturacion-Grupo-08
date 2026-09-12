USE facturacion;
GO

SET NOCOUNT ON;
SET XACT_ABORT ON;
GO

IF OBJECT_ID(N'dbo.distrito', N'U') IS NULL
    BEGIN
        CREATE TABLE dbo.distrito
        (
            id_distrito SMALLINT IDENTITY (1, 1) NOT NULL,
            id_canton SMALLINT NOT NULL,
            nombre_distrito NVARCHAR(100) NOT NULL,

            CONSTRAINT [PK_distrito]
            PRIMARY KEY CLUSTERED (id_distrito),
            CONSTRAINT [UQ_distrito_canton_nombre]
            UNIQUE NONCLUSTERED (id_canton, nombre_distrito),
            CONSTRAINT [FK_distrito_canton]
            FOREIGN KEY (id_canton)
            REFERENCES dbo.canton (id_canton),
            CONSTRAINT [CK_distrito_nombre_no_vacio]
            CHECK (LTRIM(RTRIM(nombre_distrito)) <> N'')
        );
    END;
GO
