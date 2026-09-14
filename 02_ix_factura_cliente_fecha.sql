USE facturacion;
GO

IF
    NOT EXISTS
    (
        SELECT 1
        FROM sys.indexes
        WHERE
            name = N'IX_factura_cliente_fecha'
            AND object_id = OBJECT_ID(N'dbo.factura')
    )
    BEGIN
        CREATE NONCLUSTERED INDEX [IX_factura_cliente_fecha]
            ON dbo.factura (id_cliente, fecha_emision DESC)
            INCLUDE
            (
                identificador_comprobante,
                id_empresa,
                codigo_tipo_documento,
                codigo_moneda,
                codigo_estado,
                monto_total
            );
    END;
GO
