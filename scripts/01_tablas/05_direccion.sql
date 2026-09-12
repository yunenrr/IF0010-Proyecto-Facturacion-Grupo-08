USE facturacion;
GO

SET NOCOUNT ON;
SET XACT_ABORT ON;
GO

IF OBJECT_ID(N'dbo.direccion', N'U') IS NULL
    BEGIN
        CREATE TABLE dbo.direccion
        (
            id_direccion BIGINT IDENTITY (1, 1) NOT NULL,
            id_distrito SMALLINT NOT NULL,
            senas_exactas NVARCHAR(500) NOT NULL,

            CONSTRAINT [PK_direccion]
            PRIMARY KEY CLUSTERED (id_direccion),
            CONSTRAINT [FK_direccion_distrito]
            FOREIGN KEY (id_distrito)
            REFERENCES dbo.distrito (id_distrito),
            CONSTRAINT [CK_direccion_senas_no_vacias]
            CHECK (LTRIM(RTRIM(senas_exactas)) <> N'')
        );
    END;
GO
