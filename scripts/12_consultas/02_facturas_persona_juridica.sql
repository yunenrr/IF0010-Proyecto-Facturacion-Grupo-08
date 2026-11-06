USE facturacion;
GO

DECLARE @cedula VARCHAR(20) = '3102000005';

SELECT
    f.id_factura,
    f.identificador_comprobante,
    f.id_empresa,
    f.id_cliente,
    f.id_tipo_documento,
    f.id_moneda,
    f.id_estado,
    f.fecha_emision,
    f.subtotal,
    f.total_descuentos,
    f.total_impuestos,
    f.monto_total,
    f.fecha_creacion,
    f.fecha_modificacion
FROM dbo.factura AS f
INNER JOIN dbo.cliente AS c ON f.id_cliente = c.id_cliente
INNER JOIN dbo.persona_juridica AS p ON c.id_cliente = p.id_cliente
WHERE c.cedula = @cedula
ORDER BY f.fecha_emision, f.id_factura;
GO
