USE facturacion;
GO

IF OBJECT_ID(N'dbo.moneda', N'U') IS NULL
    BEGIN
        CREATE TABLE dbo.moneda
        (
            codigo_moneda CHAR(3) NOT NULL,
            simbolo NVARCHAR(5) NOT NULL,
            descripcion NVARCHAR(100) NOT NULL,

            CONSTRAINT [PK_moneda]
            PRIMARY KEY (codigo_moneda),
            CONSTRAINT [CK_moneda_codigo]
            CHECK (codigo_moneda NOT LIKE '%[^A-Z]%'),
            CONSTRAINT [CK_moneda_simbolo_no_vacio]
            CHECK (TRIM(simbolo) <> N''),
            CONSTRAINT [CK_moneda_descripcion_no_vacia]
            CHECK (TRIM(descripcion) <> N'')
        );
    END;
GO
