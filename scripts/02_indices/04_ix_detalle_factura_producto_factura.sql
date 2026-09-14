USE facturacion;
GO

IF
    NOT EXISTS
    (
        SELECT 1
        FROM sys.indexes
        WHERE
            name = N'IX_detalle_factura_producto_factura'
            AND object_id = OBJECT_ID(N'dbo.detalle_factura')
    )
    BEGIN
        CREATE NONCLUSTERED INDEX [IX_detalle_factura_producto_factura]
            ON dbo.detalle_factura (id_producto_servicio, id_factura)
            INCLUDE
            (
                numero_linea,
                cantidad,
                precio_unitario,
                monto_descuento,
                monto_impuesto,
                monto_total_linea
            );
    END;
GO
