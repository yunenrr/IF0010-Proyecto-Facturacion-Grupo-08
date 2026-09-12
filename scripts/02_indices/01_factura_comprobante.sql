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
    WHERE name = N'UX_factura_identificador_comprobante'
      AND object_id = OBJECT_ID(N'dbo.factura')
)
BEGIN
    CREATE UNIQUE NONCLUSTERED INDEX UX_factura_identificador_comprobante
        ON dbo.factura (identificador_comprobante)
        INCLUDE
        (
            id_empresa,
            id_cliente,
            codigo_estado,
            codigo_moneda,
            fecha_emision,
            subtotal,
            total_descuentos,
            total_impuestos,
            monto_total
        );
END;
GO
