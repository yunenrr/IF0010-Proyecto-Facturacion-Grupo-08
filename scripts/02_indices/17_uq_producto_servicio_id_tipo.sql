USE facturacion;
GO

-- Esta clave permite comprobar tambien el tipo en las FK de los subtipos.
IF
    NOT EXISTS
    (
        SELECT 1
        FROM sys.key_constraints
        WHERE
            name = N'UQ_producto_servicio_id_tipo'
            AND parent_object_id = OBJECT_ID(N'dbo.producto_servicio')
            AND type = 'UQ'
    )
    BEGIN
        ALTER TABLE dbo.producto_servicio
        ADD CONSTRAINT [UQ_producto_servicio_id_tipo]
        UNIQUE NONCLUSTERED (id_producto_servicio, tipo_producto_servicio);
    END;
GO

-- Las FK se crean despues de su clave UNIQUE, en este mismo archivo.
IF
    NOT EXISTS
    (
        SELECT 1
        FROM sys.foreign_keys
        WHERE
            name = N'FK_producto_producto_servicio'
            AND parent_object_id = OBJECT_ID(N'dbo.producto')
    )
    BEGIN
        ALTER TABLE dbo.producto WITH CHECK
        ADD CONSTRAINT [FK_producto_producto_servicio]
        FOREIGN KEY (id_producto_servicio, tipo_producto_servicio)
        REFERENCES dbo.producto_servicio
        (id_producto_servicio, tipo_producto_servicio);
    END;
GO

IF
    NOT EXISTS
    (
        SELECT 1
        FROM sys.foreign_keys
        WHERE
            name = N'FK_servicio_producto_servicio'
            AND parent_object_id = OBJECT_ID(N'dbo.servicio')
    )
    BEGIN
        ALTER TABLE dbo.servicio WITH CHECK
        ADD CONSTRAINT [FK_servicio_producto_servicio]
        FOREIGN KEY (id_producto_servicio, tipo_producto_servicio)
        REFERENCES dbo.producto_servicio
        (id_producto_servicio, tipo_producto_servicio);
    END;
GO
