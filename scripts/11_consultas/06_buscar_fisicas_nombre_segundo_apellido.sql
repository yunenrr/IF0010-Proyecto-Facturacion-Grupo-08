USE facturacion;
GO

DECLARE @nombre VARCHAR(100) = 'Ana';
DECLARE @segundo_apellido VARCHAR(100) = 'Mora';

SELECT
    c.cedula,
    p.nombre_persona,
    p.primer_apellido,
    p.segundo_apellido
FROM dbo.persona_fisica AS p
INNER JOIN dbo.cliente AS c ON p.id_cliente = c.id_cliente
WHERE
    p.segundo_apellido = @segundo_apellido
    AND p.nombre_persona LIKE @nombre + ' %'
ORDER BY p.nombre_persona, c.cedula;
GO
