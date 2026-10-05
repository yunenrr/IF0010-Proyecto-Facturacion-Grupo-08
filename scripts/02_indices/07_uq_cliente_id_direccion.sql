USE facturacion;
GO

IF
    NOT EXISTS (
        SELECT 1 FROM sys.key_constraints
        WHERE
            parent_object_id = OBJECT_ID(N'dbo.cliente')
            AND name = N'UQ_cliente_id_direccion'
    )
    BEGIN
        ALTER TABLE dbo.cliente
        ADD CONSTRAINT [UQ_cliente_id_direccion]
        UNIQUE NONCLUSTERED (
            id_direccion
        );
    END;
GO
