USE facturacion;
GO

IF
    NOT EXISTS (
        SELECT 1 FROM sys.key_constraints
        WHERE
            parent_object_id = OBJECT_ID(N'dbo.tipo_documento')
            AND name = N'UQ_tipo_documento_codigo_tipo_documento'
    )
    BEGIN
        ALTER TABLE dbo.tipo_documento
        ADD CONSTRAINT [UQ_tipo_documento_codigo_tipo_documento]
        UNIQUE NONCLUSTERED (
            codigo_tipo_documento
        );
    END;
GO
