USE facturacion;
GO

IF
    NOT EXISTS
    (
        SELECT 1
        FROM sys.indexes
        WHERE
            name = N'UX_producto_servicio_codigo'
            AND object_id = OBJECT_ID(N'dbo.producto_servicio')
    )
    BEGIN
        CREATE UNIQUE NONCLUSTERED INDEX [UX_producto_servicio_codigo]
            ON dbo.producto_servicio (codigo_interno)
            INCLUDE
            (
                tipo_producto_servicio,
                descripcion,
                precio_unitario_lista,
                porcentaje_impuesto,
                activo
            );
    END;
GO
