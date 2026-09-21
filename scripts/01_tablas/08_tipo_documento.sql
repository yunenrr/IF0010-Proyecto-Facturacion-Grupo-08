USE facturacion;
GO

IF OBJECT_ID(N'dbo.tipo_documento', N'U') IS NULL
    BEGIN
        CREATE TABLE dbo.tipo_documento
        (
            codigo_tipo_documento VARCHAR(10) NOT NULL,
            descripcion NVARCHAR(100) NOT NULL,

            CONSTRAINT [PK_tipo_documento]
            PRIMARY KEY (codigo_tipo_documento),
            CONSTRAINT [CK_tipo_documento_codigo_no_vacio]
            CHECK (TRIM(codigo_tipo_documento) <> ''),
            CONSTRAINT [CK_tipo_documento_descripcion_no_vacia]
            CHECK (TRIM(descripcion) <> N'')
        );
    END;
GO
