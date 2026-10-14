USE facturacion;
GO

IF
    NOT EXISTS (
        SELECT 1 FROM sys.indexes
        WHERE
            object_id = OBJECT_ID(N'dbo.factura')
            AND name = N'IX_factura_empresa_fecha'
    )
    BEGIN
        CREATE NONCLUSTERED INDEX [IX_factura_empresa_fecha]
            ON dbo.factura (id_empresa, fecha_emision DESC)
            INCLUDE (
                id_cliente,
                monto_total
            );
    END;
GO
