USE facturacion;
GO

IF
    NOT EXISTS (
        SELECT 1 FROM sys.key_constraints
        WHERE
            parent_object_id = OBJECT_ID(N'dbo.estado_factura')
            AND name = N'UQ_estado_factura_codigo_estado'
    )
    BEGIN
        ALTER TABLE dbo.estado_factura
        ADD CONSTRAINT [UQ_estado_factura_codigo_estado]
        UNIQUE NONCLUSTERED (
            codigo_estado
        );
    END;
GO
