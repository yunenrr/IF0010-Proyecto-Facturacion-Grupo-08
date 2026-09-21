USE facturacion;
GO

-- La restriccion UNIQUE y su indice se crean en la carpeta de indices.
IF
    NOT EXISTS
    (
        SELECT 1
        FROM sys.key_constraints
        WHERE
            name = N'UQ_moneda_descripcion'
            AND parent_object_id = OBJECT_ID(N'dbo.moneda')
            AND type = 'UQ'
    )
    BEGIN
        ALTER TABLE dbo.moneda
        ADD CONSTRAINT [UQ_moneda_descripcion]
        UNIQUE NONCLUSTERED (descripcion);
    END;
GO
