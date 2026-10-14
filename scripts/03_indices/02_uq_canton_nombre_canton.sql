USE facturacion;
GO

IF
    NOT EXISTS (
        SELECT 1 FROM sys.key_constraints
        WHERE
            parent_object_id = OBJECT_ID(N'dbo.canton')
            AND name = N'UQ_canton_nombre_canton'
    )
    BEGIN
        ALTER TABLE dbo.canton
        ADD CONSTRAINT [UQ_canton_nombre_canton]
        UNIQUE NONCLUSTERED (
            id_provincia, nombre_canton
        );
    END;
GO
