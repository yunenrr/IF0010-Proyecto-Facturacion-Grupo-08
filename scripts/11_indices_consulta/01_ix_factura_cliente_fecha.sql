USE facturacion;
GO

IF
    NOT EXISTS (
        SELECT 1 FROM sys.indexes
        WHERE
            object_id = OBJECT_ID(N'dbo.factura')
            AND name = N'IX_factura_cliente_fecha'
    )
    BEGIN
        CREATE NONCLUSTERED INDEX [IX_factura_cliente_fecha]
            ON dbo.factura (id_cliente, fecha_emision DESC)
            INCLUDE (
                identificador_comprobante,
                id_empresa,
                id_tipo_documento,
                id_moneda,
                id_estado,
                monto_total
            );
    END;
GO
