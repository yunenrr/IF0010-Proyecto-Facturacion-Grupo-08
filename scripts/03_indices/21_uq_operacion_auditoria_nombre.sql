USE facturacion;
GO

IF
    NOT EXISTS (
        SELECT 1 FROM sys.key_constraints
        WHERE
            parent_object_id = OBJECT_ID(N'dbo.operacion_auditoria')
            AND name = N'UQ_operacion_auditoria_nombre'
    )
    BEGIN
        ALTER TABLE dbo.operacion_auditoria
        ADD CONSTRAINT [UQ_operacion_auditoria_nombre]
        UNIQUE NONCLUSTERED (
            nombre
        );
    END;
GO
