USE facturacion;
GO

-- La restriccion UNIQUE y su indice se crean en la carpeta de indices.
IF
    NOT EXISTS
    (
        SELECT 1
        FROM sys.key_constraints
        WHERE
            name = N'UQ_provincia_nombre'
            AND parent_object_id = OBJECT_ID(N'dbo.provincia')
            AND type = 'UQ'
    )
    BEGIN
        ALTER TABLE dbo.provincia
        ADD CONSTRAINT [UQ_provincia_nombre]
        UNIQUE NONCLUSTERED (nombre_provincia);
    END;
GO
