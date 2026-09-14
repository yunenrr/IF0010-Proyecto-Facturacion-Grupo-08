USE facturacion;
GO

-- La restriccion UNIQUE y su indice se crean en la carpeta de indices.
IF
    NOT EXISTS
    (
        SELECT 1
        FROM sys.key_constraints
        WHERE
            name = N'UQ_canton_provincia_nombre'
            AND parent_object_id = OBJECT_ID(N'dbo.canton')
            AND type = 'UQ'
    )
    BEGIN
        ALTER TABLE dbo.canton
        ADD CONSTRAINT [UQ_canton_provincia_nombre]
        UNIQUE NONCLUSTERED (id_provincia, nombre_canton);
    END;
GO
