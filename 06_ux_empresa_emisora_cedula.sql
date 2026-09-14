USE facturacion;
GO

IF
    NOT EXISTS
    (
        SELECT 1
        FROM sys.indexes
        WHERE
            name = N'UX_empresa_emisora_cedula'
            AND object_id = OBJECT_ID(N'dbo.empresa_emisora')
    )
    BEGIN
        CREATE UNIQUE NONCLUSTERED INDEX [UX_empresa_emisora_cedula]
            ON dbo.empresa_emisora (cedula)
            INCLUDE
            (
                nombre_comercial,
                razon_social,
                correo_electronico,
                telefono,
                id_direccion,
                activo
            );
    END;
GO
