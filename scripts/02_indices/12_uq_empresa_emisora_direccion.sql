USE facturacion;
GO

-- La restriccion UNIQUE y su indice se crean en la carpeta de indices.
IF
    NOT EXISTS
    (
        SELECT 1
        FROM sys.key_constraints
        WHERE
            name = N'UQ_empresa_emisora_direccion'
            AND parent_object_id = OBJECT_ID(N'dbo.empresa_emisora')
            AND type = 'UQ'
    )
    BEGIN
        ALTER TABLE dbo.empresa_emisora
        ADD CONSTRAINT [UQ_empresa_emisora_direccion]
        UNIQUE NONCLUSTERED (id_direccion);
    END;
GO
