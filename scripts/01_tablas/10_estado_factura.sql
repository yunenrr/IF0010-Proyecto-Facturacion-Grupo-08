USE facturacion;
GO

SET NOCOUNT ON;
SET XACT_ABORT ON;
GO

IF OBJECT_ID(N'dbo.estado_factura', N'U') IS NULL
    BEGIN
        CREATE TABLE dbo.estado_factura
        (
            codigo_estado VARCHAR(15) NOT NULL,
            descripcion NVARCHAR(150) NOT NULL,

            CONSTRAINT [PK_estado_factura]
            PRIMARY KEY CLUSTERED (codigo_estado),
            CONSTRAINT [UQ_estado_factura_descripcion]
            UNIQUE NONCLUSTERED (descripcion),
            CONSTRAINT [CK_estado_factura_codigo_no_vacio]
            CHECK (LTRIM(RTRIM(codigo_estado)) <> ''),
            CONSTRAINT [CK_estado_factura_descripcion_no_vacia]
            CHECK (LTRIM(RTRIM(descripcion)) <> N'')
        );
    END;
GO
