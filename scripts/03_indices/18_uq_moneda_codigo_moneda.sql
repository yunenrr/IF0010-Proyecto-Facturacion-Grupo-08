USE facturacion;
GO

IF
    NOT EXISTS (
        SELECT 1 FROM sys.key_constraints
        WHERE
            parent_object_id = OBJECT_ID(N'dbo.moneda')
            AND name = N'UQ_moneda_codigo_moneda'
    )
    BEGIN
        ALTER TABLE dbo.moneda
        ADD CONSTRAINT [UQ_moneda_codigo_moneda]
        UNIQUE NONCLUSTERED (
            codigo_moneda
        );
    END;
GO
