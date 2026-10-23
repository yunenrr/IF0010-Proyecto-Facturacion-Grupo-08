USE facturacion;
GO

CREATE OR ALTER FUNCTION dbo.consultar_historial_cambios()
RETURNS TABLE
AS
RETURN
(
    SELECT
        a.id_evento,
        e.nombre AS entidad,
        a.id_registro_principal,
        d.numero_linea,
        o.nombre AS operacion,
        u.nombre AS usuario,
        a.fecha_hora_cambio,
        c.nombre AS campo,
        m.nombre AS momento,
        v.valor
    FROM dbo.auditoria_evento AS a
    INNER JOIN dbo.entidad_auditoria AS e ON a.id_entidad = e.id_entidad
    INNER JOIN dbo.operacion_auditoria AS o ON a.id_operacion = o.id_operacion
    INNER JOIN dbo.usuario_auditoria AS u ON a.id_usuario = u.id_usuario
    LEFT JOIN dbo.auditoria_evento_detalle AS d ON a.id_evento = d.id_evento
    LEFT JOIN dbo.auditoria_valor AS v ON a.id_evento = v.id_evento
    LEFT JOIN dbo.campo_auditoria AS c ON v.id_campo = c.id_campo
    LEFT JOIN dbo.momento_auditoria AS m ON v.id_momento = m.id_momento
    WHERE IS_ROLEMEMBER('Auditor') = 1 OR IS_ROLEMEMBER('DBA') = 1
);
GO
