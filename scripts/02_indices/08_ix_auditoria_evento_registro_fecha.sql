USE facturacion;
GO

IF
    NOT EXISTS
    (
        SELECT 1
        FROM sys.indexes
        WHERE
            name = N'IX_auditoria_evento_registro_fecha'
            AND object_id = OBJECT_ID(N'dbo.auditoria_evento')
    )
    BEGIN
        CREATE NONCLUSTERED INDEX [IX_auditoria_evento_registro_fecha]
            ON dbo.auditoria_evento
            (
                tipo_entidad,
                id_registro_principal,
                fecha_hora_cambio DESC
            )
            INCLUDE
            (
                id_registro_secundario,
                tipo_operacion,
                usuario_responsable
            );
    END;
GO
