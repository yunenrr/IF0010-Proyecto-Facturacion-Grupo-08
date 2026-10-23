USE facturacion;
GO

IF
    NOT EXISTS (
        SELECT 1 FROM sys.key_constraints
        WHERE
            parent_object_id = OBJECT_ID(N'dbo.usuario_auditoria')
            AND name = N'UQ_usuario_auditoria_nombre'
    )
    BEGIN
        ALTER TABLE dbo.usuario_auditoria
        ADD CONSTRAINT [UQ_usuario_auditoria_nombre]
        UNIQUE NONCLUSTERED (
            nombre
        );
    END;
GO
