USE facturacion;
GO

IF
    NOT EXISTS (
        SELECT 1 FROM sys.key_constraints
        WHERE
            parent_object_id = OBJECT_ID(N'dbo.producto_servicio')
            AND name = N'UQ_producto_servicio_codigo_interno'
    )
    BEGIN
        ALTER TABLE dbo.producto_servicio
        ADD CONSTRAINT [UQ_producto_servicio_codigo_interno]
        UNIQUE NONCLUSTERED (
            codigo_interno
        );
    END;
GO
