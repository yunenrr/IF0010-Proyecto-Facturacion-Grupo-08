USE facturacion;
GO

IF
    NOT EXISTS
    (
        SELECT 1
        FROM sys.indexes
        WHERE
            name = N'UX_cliente_cedula'
            AND object_id = OBJECT_ID(N'dbo.cliente')
    )
    BEGIN
        CREATE UNIQUE NONCLUSTERED INDEX [UX_cliente_cedula]
            ON dbo.cliente (cedula)
            INCLUDE
            (
                tipo_persona,
                nombre_persona,
                razon_social,
                correo_electronico,
                telefono,
                id_direccion,
                fecha_ultima_actualizacion
            );
    END;
GO
