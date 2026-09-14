USE facturacion;
GO

-- La restriccion UNIQUE y su indice se crean en la carpeta de indices.
IF
    NOT EXISTS
    (
        SELECT 1
        FROM sys.key_constraints
        WHERE
            name = N'UQ_distrito_canton_nombre'
            AND parent_object_id = OBJECT_ID(N'dbo.distrito')
            AND type = 'UQ'
    )
    BEGIN
        ALTER TABLE dbo.distrito
        ADD CONSTRAINT [UQ_distrito_canton_nombre]
        UNIQUE NONCLUSTERED (id_provincia, id_canton, nombre_distrito);
    END;
GO
