USE facturacion;
GO

IF
    NOT EXISTS (
        SELECT 1 FROM sys.indexes
        WHERE
            object_id = OBJECT_ID(N'dbo.cliente')
            AND name = N'IX_cliente_tipo'
    )
    BEGIN
        CREATE NONCLUSTERED INDEX [IX_cliente_tipo]
            ON dbo.cliente (id_tipo_persona)
            INCLUDE (
                cedula
            );
    END;
GO
