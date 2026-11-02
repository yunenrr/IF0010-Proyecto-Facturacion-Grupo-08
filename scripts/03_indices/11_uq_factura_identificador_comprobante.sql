USE facturacion;
GO

IF
    NOT EXISTS (
        SELECT 1 FROM sys.key_constraints
        WHERE
            parent_object_id = OBJECT_ID(N'dbo.factura')
            AND name = N'UQ_factura_identificador_comprobante'
    )
    BEGIN
        ALTER TABLE dbo.factura
        ADD CONSTRAINT [UQ_factura_identificador_comprobante]
        UNIQUE NONCLUSTERED (
            identificador_comprobante
        );
    END;
GO
