USE facturacion;
GO

IF
    NOT EXISTS (
        SELECT 1 FROM sys.key_constraints
        WHERE
            parent_object_id = OBJECT_ID(N'dbo.campo_auditoria')
            AND name = N'UQ_campo_auditoria_nombre'
    )
    BEGIN
        ALTER TABLE dbo.campo_auditoria
        ADD CONSTRAINT [UQ_campo_auditoria_nombre]
        UNIQUE NONCLUSTERED (
            id_entidad, nombre
        );
    END;
GO
