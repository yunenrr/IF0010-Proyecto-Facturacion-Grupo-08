USE facturacion;
GO

SET NOCOUNT ON;
SET XACT_ABORT ON;
GO

IF OBJECT_ID(N'dbo.moneda', N'U') IS NULL
    BEGIN
        CREATE TABLE dbo.moneda
        (
            codigo_moneda CHAR(3) NOT NULL,
            simbolo NVARCHAR(5) NOT NULL,
            descripcion NVARCHAR(100) NOT NULL,

            CONSTRAINT [PK_moneda]
            PRIMARY KEY CLUSTERED (codigo_moneda),
            CONSTRAINT [UQ_moneda_descripcion]
            UNIQUE NONCLUSTERED (descripcion),
            CONSTRAINT [CK_moneda_codigo]
            CHECK (codigo_moneda NOT LIKE '%[^A-Z]%'),
            CONSTRAINT [CK_moneda_simbolo_no_vacio]
            CHECK (LTRIM(RTRIM(simbolo)) <> N''),
            CONSTRAINT [CK_moneda_descripcion_no_vacia]
            CHECK (LTRIM(RTRIM(descripcion)) <> N'')
        );
    END;
GO
