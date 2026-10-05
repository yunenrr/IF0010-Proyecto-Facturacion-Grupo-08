USE facturacion;
GO

IF
    NOT EXISTS (
        SELECT 1 FROM sys.indexes
        WHERE
            object_id = OBJECT_ID(N'dbo.detalle_factura')
            AND name = N'IX_detalle_producto_factura'
    )
    BEGIN
        CREATE NONCLUSTERED INDEX [IX_detalle_producto_factura]
            ON dbo.detalle_factura (id_producto_servicio, id_factura)
            INCLUDE (
                numero_linea,
                cantidad,
                monto_total_linea
            );
    END;
GO
