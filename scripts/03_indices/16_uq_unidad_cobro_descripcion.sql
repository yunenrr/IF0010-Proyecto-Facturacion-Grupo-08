USE facturacion;
GO

IF
    NOT EXISTS (
        SELECT 1 FROM sys.key_constraints
        WHERE
            parent_object_id = OBJECT_ID(N'dbo.unidad_cobro')
            AND name = N'UQ_unidad_cobro_descripcion'
    )
    BEGIN
        ALTER TABLE dbo.unidad_cobro
        ADD CONSTRAINT [UQ_unidad_cobro_descripcion]
        UNIQUE NONCLUSTERED (
            descripcion
        );
    END;
GO
