USE facturacion;
GO

IF
    NOT EXISTS (
        SELECT 1 FROM sys.indexes
        WHERE
            object_id = OBJECT_ID('dbo.persona_juridica')
            AND name = 'IX_persona_juridica_razon_social'
    )
    BEGIN
        CREATE NONCLUSTERED INDEX [IX_persona_juridica_razon_social]
            ON dbo.persona_juridica (razon_social)
            INCLUDE (nombre_comercial);
    END;
GO
