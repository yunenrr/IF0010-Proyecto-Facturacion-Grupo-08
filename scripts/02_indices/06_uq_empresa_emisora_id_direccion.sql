USE facturacion;
GO

IF
    NOT EXISTS (
        SELECT 1 FROM sys.key_constraints
        WHERE
            parent_object_id = OBJECT_ID(N'dbo.empresa_emisora')
            AND name = N'UQ_empresa_emisora_id_direccion'
    )
    BEGIN
        ALTER TABLE dbo.empresa_emisora
        ADD CONSTRAINT [UQ_empresa_emisora_id_direccion]
        UNIQUE NONCLUSTERED (
            id_direccion
        );
    END;
GO
