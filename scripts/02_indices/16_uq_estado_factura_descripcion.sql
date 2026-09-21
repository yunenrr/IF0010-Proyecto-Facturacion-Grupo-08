USE facturacion;
GO

-- La restriccion UNIQUE y su indice se crean en la carpeta de indices.
IF
    NOT EXISTS
    (
        SELECT 1
        FROM sys.key_constraints
        WHERE
            name = N'UQ_estado_factura_descripcion'
            AND parent_object_id = OBJECT_ID(N'dbo.estado_factura')
            AND type = 'UQ'
    )
    BEGIN
        ALTER TABLE dbo.estado_factura
        ADD CONSTRAINT [UQ_estado_factura_descripcion]
        UNIQUE NONCLUSTERED (descripcion);
    END;
GO
