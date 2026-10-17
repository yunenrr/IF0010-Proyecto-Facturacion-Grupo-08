USE facturacion;
GO

CREATE OR ALTER VIEW dbo.totales_diarios_facturados
AS
SELECT
    CAST(f.fecha_emision AS DATE) AS FechaEmision,
    e.razon_social AS NombreEmpresa,
    t.descripcion AS TipoDocumento,
    COUNT(*) AS CantidadFacturas,
    SUM(f.subtotal) AS SubtotalAcumulado,
    SUM(f.total_descuentos) AS TotalDescuentos,
    SUM(f.total_impuestos) AS TotalImpuestos,
    SUM(f.monto_total) AS MontoTotalFacturado
FROM dbo.factura AS f
INNER JOIN dbo.empresa_emisora AS e ON f.id_empresa = e.id_empresa
INNER JOIN dbo.tipo_documento AS t ON f.id_tipo_documento = t.id_tipo_documento
GROUP BY
    CAST(f.fecha_emision AS DATE),
    e.id_empresa,
    e.razon_social,
    t.id_tipo_documento,
    t.descripcion;
GO
