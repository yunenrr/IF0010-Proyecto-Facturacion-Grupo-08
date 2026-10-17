USE facturacion;
GO

CREATE OR ALTER FUNCTION dbo.consultar_informacion_cliente
(
    @cedula VARCHAR(20)
)
RETURNS TABLE
AS
RETURN
(
    SELECT
        c.id_cliente,
        c.cedula,
        c.id_tipo_persona,
        t.descripcion AS tipo_persona,
        COALESCE(f.nombre_persona, j.razon_social) AS nombre_o_razon_social,
        c.id_direccion,
        CASE WHEN IS_ROLEMEMBER('Administrativo') = 1
            THEN c.telefono ELSE NULL END AS telefono,
        CASE WHEN IS_ROLEMEMBER('Administrativo') = 1
            THEN c.correo_electronico ELSE NULL END AS correo_electronico,
        c.fecha_registro,
        c.fecha_ultima_actualizacion
    FROM dbo.cliente AS c
    INNER JOIN dbo.tipo_persona AS t ON c.id_tipo_persona = t.id_tipo_persona
    LEFT JOIN dbo.persona_fisica AS f ON c.id_cliente = f.id_cliente
    LEFT JOIN dbo.persona_juridica AS j ON c.id_cliente = j.id_cliente
    WHERE c.cedula = @cedula
        AND (
            IS_ROLEMEMBER('Administrativo') = 1
            OR IS_ROLEMEMBER('Cajero') = 1
            OR IS_ROLEMEMBER('Consulta') = 1
        )
);
GO
