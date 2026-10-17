USE facturacion;
GO

CREATE OR ALTER VIEW dbo.informacion_comercial_clientes
AS
SELECT
    c.cedula AS Cedula,
    COALESCE(p.nombre_persona, j.razon_social) AS NombreORazonSocial,
    COUNT(f.id_factura) AS CantidadFacturas,
    CASE
        WHEN SUM(CASE
            WHEN f.fecha_emision >= DATEADD(MONTH, -6, SYSDATETIME())
                AND f.fecha_emision <= SYSDATETIME()
                THEN 1
            ELSE 0
        END) > 5 THEN N'Sí'
        ELSE N'No'
    END AS ClienteFrecuente
FROM dbo.cliente AS c
LEFT JOIN dbo.persona_fisica AS p ON c.id_cliente = p.id_cliente
LEFT JOIN dbo.persona_juridica AS j ON c.id_cliente = j.id_cliente
LEFT JOIN dbo.factura AS f ON c.id_cliente = f.id_cliente
GROUP BY
    c.id_cliente,
    c.cedula,
    p.nombre_persona,
    j.razon_social;
GO
