USE facturacion;
GO

DECLARE @razon_social VARCHAR(250) = 'Servicios';

SELECT
    c.cedula,
    p.razon_social,
    p.nombre_comercial
FROM dbo.persona_juridica AS p
INNER JOIN dbo.cliente AS c ON p.id_cliente = c.id_cliente
WHERE p.razon_social LIKE @razon_social + '%'
ORDER BY p.razon_social, c.cedula;
GO
