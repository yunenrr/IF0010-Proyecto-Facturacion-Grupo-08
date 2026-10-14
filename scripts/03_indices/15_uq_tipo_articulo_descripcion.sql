USE facturacion;
GO

IF
    NOT EXISTS (
        SELECT 1 FROM sys.key_constraints
        WHERE
            parent_object_id = OBJECT_ID(N'dbo.tipo_articulo')
            AND name = N'UQ_tipo_articulo_descripcion'
    )
    BEGIN
        ALTER TABLE dbo.tipo_articulo
        ADD CONSTRAINT [UQ_tipo_articulo_descripcion]
        UNIQUE NONCLUSTERED (
            descripcion
        );
    END;
GO
