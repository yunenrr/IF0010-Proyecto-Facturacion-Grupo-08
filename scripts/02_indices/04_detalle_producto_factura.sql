USE facturacion;
GO

SET ANSI_NULLS ON;
SET ANSI_PADDING ON;
SET ANSI_WARNINGS ON;
SET ARITHABORT ON;
SET CONCAT_NULL_YIELDS_NULL ON;
SET QUOTED_IDENTIFIER ON;
SET NUMERIC_ROUNDABORT OFF;
GO

SET NOCOUNT ON;
SET XACT_ABORT ON;
GO

IF NOT EXISTS
(
    SELECT 1
    FROM sys.indexes
    WHERE name = N'IX_detalle_factura_producto_factura'
      AND object_id = OBJECT_ID(N'dbo.detalle_factura')
)
BEGIN
    CREATE NONCLUSTERED INDEX IX_detalle_factura_producto_factura
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
