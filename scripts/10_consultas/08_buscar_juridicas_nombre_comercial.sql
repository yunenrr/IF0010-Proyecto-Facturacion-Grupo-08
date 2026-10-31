USE facturacion;
GO

DECLARE @nombre_comercial VARCHAR(200) = 'Servicios';

SELECT
    c.cedula,
    p.razon_social,
    p.nombre_comercial
FROM dbo.persona_juridica AS p
INNER JOIN dbo.cliente AS c ON p.id_cliente = c.id_cliente
WHERE p.nombre_comercial LIKE @nombre_comercial + '%'
ORDER BY p.nombre_comercial, c.cedula;
GO
