USE facturacion;
GO

IF
    NOT EXISTS (
        SELECT 1 FROM sys.indexes
        WHERE
            object_id = OBJECT_ID(N'dbo.auditoria_evento')
            AND name = N'IX_auditoria_registro_fecha'
    )
    BEGIN
        CREATE NONCLUSTERED INDEX [IX_auditoria_registro_fecha]
            ON dbo.auditoria_evento
            (id_entidad, id_registro_principal, fecha_hora_cambio DESC);
    END;
GO
