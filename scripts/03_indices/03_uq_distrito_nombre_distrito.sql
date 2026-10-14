USE facturacion;
GO

IF
    NOT EXISTS (
        SELECT 1 FROM sys.key_constraints
        WHERE
            parent_object_id = OBJECT_ID(N'dbo.distrito')
            AND name = N'UQ_distrito_nombre_distrito'
    )
    BEGIN
        ALTER TABLE dbo.distrito
        ADD CONSTRAINT [UQ_distrito_nombre_distrito]
        UNIQUE NONCLUSTERED (
            id_provincia, id_canton, nombre_distrito
        );
    END;
GO
