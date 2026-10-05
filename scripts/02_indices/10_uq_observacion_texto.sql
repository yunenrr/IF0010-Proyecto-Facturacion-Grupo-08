USE facturacion;
GO

IF
    NOT EXISTS (
        SELECT 1 FROM sys.key_constraints
        WHERE
            parent_object_id = OBJECT_ID(N'dbo.observacion')
            AND name = N'UQ_observacion_texto'
    )
    BEGIN
        ALTER TABLE dbo.observacion
        ADD CONSTRAINT [UQ_observacion_texto]
        UNIQUE NONCLUSTERED (
            texto
        );
    END;
GO
