USE facturacion;
GO

SET NOCOUNT ON;
SET XACT_ABORT ON;
GO

IF OBJECT_ID(N'dbo.tipo_documento', N'U') IS NULL
    BEGIN
        CREATE TABLE dbo.tipo_documento
        (
            codigo_tipo_documento VARCHAR(10) NOT NULL,
            descripcion NVARCHAR(100) NOT NULL,

            CONSTRAINT [PK_tipo_documento]
            PRIMARY KEY CLUSTERED (codigo_tipo_documento),
            CONSTRAINT [UQ_tipo_documento_descripcion]
            UNIQUE NONCLUSTERED (descripcion),
            CONSTRAINT [CK_tipo_documento_codigo_no_vacio]
            CHECK (LTRIM(RTRIM(codigo_tipo_documento)) <> ''),
            CONSTRAINT [CK_tipo_documento_descripcion_no_vacia]
            CHECK (LTRIM(RTRIM(descripcion)) <> N'')
        );
    END;
GO
