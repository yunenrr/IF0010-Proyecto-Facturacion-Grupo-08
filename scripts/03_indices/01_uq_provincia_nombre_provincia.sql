USE facturacion;
GO

IF
    NOT EXISTS (
        SELECT 1 FROM sys.key_constraints
        WHERE
            parent_object_id = OBJECT_ID(N'dbo.provincia')
            AND name = N'UQ_provincia_nombre_provincia'
    )
    BEGIN
        ALTER TABLE dbo.provincia
        ADD CONSTRAINT [UQ_provincia_nombre_provincia]
        UNIQUE NONCLUSTERED (
            nombre_provincia
        );
    END;
GO
