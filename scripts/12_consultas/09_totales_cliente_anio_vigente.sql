USE facturacion;
GO

DECLARE @cedula VARCHAR(20) = '100000001';
DECLARE @inicio DATE = DATEFROMPARTS(YEAR(SYSDATETIME()), 1, 1);
DECLARE @fin DATE = DATEADD(YEAR, 1, @inicio);

SELECT
    COALESCE(SUM(f.total_descuentos), 0) AS total_descuentos,
    COALESCE(SUM(f.total_impuestos), 0) AS total_impuestos,
    COALESCE(SUM(f.monto_total), 0) AS monto_total_facturado
FROM dbo.cliente AS c
INNER JOIN dbo.factura AS f ON c.id_cliente = f.id_cliente
WHERE
    c.cedula = @cedula
    AND f.fecha_emision >= @inicio
    AND f.fecha_emision < @fin;
GO
