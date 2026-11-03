USE facturacion;
GO

DECLARE @codigo_producto VARCHAR(30) = 'DEMO-0001';
DECLARE @desde DATE = DATEADD(MONTH, -3, CAST(SYSDATETIME() AS DATE));
DECLARE @hasta DATE = CAST(SYSDATETIME() AS DATE);

SELECT
    f.identificador_comprobante,
    f.fecha_emision,
    SUM(d.cantidad) AS cantidad
FROM dbo.producto_servicio AS a
INNER JOIN dbo.producto AS p
    ON a.id_producto_servicio = p.id_producto_servicio
INNER JOIN dbo.detalle_factura AS d
    ON p.id_producto_servicio = d.id_producto_servicio
INNER JOIN dbo.factura AS f ON d.id_factura = f.id_factura
WHERE
    a.codigo_interno = @codigo_producto
    AND f.fecha_emision >= @desde
    AND f.fecha_emision < DATEADD(DAY, 1, @hasta)
GROUP BY f.id_factura, f.identificador_comprobante, f.fecha_emision
ORDER BY f.fecha_emision, f.identificador_comprobante;
GO
