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
    WHERE name = N'UX_producto_servicio_codigo'
      AND object_id = OBJECT_ID(N'dbo.producto_servicio')
)
BEGIN
    CREATE UNIQUE NONCLUSTERED INDEX UX_producto_servicio_codigo
        ON dbo.producto_servicio (codigo_interno)
        INCLUDE
        (
            descripcion,
            precio_unitario_lista,
            porcentaje_impuesto,
            activo
        );
END;
GO
