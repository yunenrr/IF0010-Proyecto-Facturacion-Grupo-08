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
