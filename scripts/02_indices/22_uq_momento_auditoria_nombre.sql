USE facturacion;
GO

IF
    NOT EXISTS (
        SELECT 1 FROM sys.key_constraints
        WHERE
            parent_object_id = OBJECT_ID(N'dbo.momento_auditoria')
            AND name = N'UQ_momento_auditoria_nombre'
    )
    BEGIN
        ALTER TABLE dbo.momento_auditoria
        ADD CONSTRAINT [UQ_momento_auditoria_nombre]
        UNIQUE NONCLUSTERED (
            nombre
        );
    END;
GO
