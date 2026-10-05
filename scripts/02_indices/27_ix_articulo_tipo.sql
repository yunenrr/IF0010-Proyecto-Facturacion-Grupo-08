USE facturacion;
GO

IF
    NOT EXISTS (
        SELECT 1 FROM sys.indexes
        WHERE
            object_id = OBJECT_ID(N'dbo.producto_servicio')
            AND name = N'IX_articulo_tipo'
    )
    BEGIN
        CREATE NONCLUSTERED INDEX [IX_articulo_tipo]
            ON dbo.producto_servicio (id_tipo_articulo)
            INCLUDE (
                id_descripcion,
                precio_unitario_lista
            );
    END;
GO
