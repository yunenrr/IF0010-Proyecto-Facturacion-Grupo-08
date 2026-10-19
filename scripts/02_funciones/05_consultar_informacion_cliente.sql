USE facturacion;
GO

CREATE OR ALTER FUNCTION dbo.consultar_informacion_cliente(
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
        c.id_direccion,
        c.fecha_registro,
        c.fecha_ultima_actualizacion,
        COALESCE(f.nombre_persona, j.razon_social) AS nombre_o_razon_social,
        CASE
            WHEN IS_ROLEMEMBER('Administrativo') = 1
                THEN c.telefono
        END AS telefono,
        CASE
            WHEN IS_ROLEMEMBER('Administrativo') = 1
                THEN c.correo_electronico
        END AS correo_electronico
    FROM dbo.cliente AS c
    INNER JOIN dbo.tipo_persona AS t ON c.id_tipo_persona = t.id_tipo_persona
    LEFT JOIN dbo.persona_fisica AS f ON c.id_cliente = f.id_cliente
    LEFT JOIN dbo.persona_juridica AS j ON c.id_cliente = j.id_cliente
    WHERE
        c.cedula = @cedula
        AND (
            IS_ROLEMEMBER('Administrativo') = 1
            OR IS_ROLEMEMBER('Cajero') = 1
            OR IS_ROLEMEMBER('Consulta') = 1
        )
);
GO
