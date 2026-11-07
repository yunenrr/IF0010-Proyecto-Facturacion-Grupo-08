USE facturacion;
GO

IF
    NOT EXISTS (
        SELECT 1 FROM sys.indexes
        WHERE
            object_id = OBJECT_ID('dbo.persona_juridica')
            AND name = 'IX_persona_juridica_nombre_comercial'
    )
    BEGIN
        CREATE NONCLUSTERED INDEX [IX_persona_juridica_nombre_comercial]
            ON dbo.persona_juridica (nombre_comercial)
            INCLUDE (razon_social);
    END;
GO
