USE facturacion;
GO

IF
    NOT EXISTS (
        SELECT 1 FROM sys.indexes
        WHERE
            object_id = OBJECT_ID('dbo.persona_fisica')
            AND name = 'IX_persona_fisica_primer_apellido_nombre'
    )
    BEGIN
        CREATE NONCLUSTERED INDEX [IX_persona_fisica_primer_apellido_nombre]
            ON dbo.persona_fisica (primer_apellido, nombre_persona)
            INCLUDE (segundo_apellido);
    END;
GO
