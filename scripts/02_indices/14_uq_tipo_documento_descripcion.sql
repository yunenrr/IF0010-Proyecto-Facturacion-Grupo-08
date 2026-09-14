USE facturacion;
GO

-- La restriccion UNIQUE y su indice se crean en la carpeta de indices.
IF
    NOT EXISTS
    (
        SELECT 1
        FROM sys.key_constraints
        WHERE
            name = N'UQ_tipo_documento_descripcion'
            AND parent_object_id = OBJECT_ID(N'dbo.tipo_documento')
            AND type = 'UQ'
    )
    BEGIN
        ALTER TABLE dbo.tipo_documento
        ADD CONSTRAINT [UQ_tipo_documento_descripcion]
        UNIQUE NONCLUSTERED (descripcion);
    END;
GO
