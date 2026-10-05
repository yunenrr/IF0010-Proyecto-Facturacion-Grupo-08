USE facturacion;
GO

CREATE TABLE dbo.servicio
(
    id_producto_servicio INT NOT NULL,
    id_unidad_cobro INT NOT NULL,
    CONSTRAINT [PK_servicio] PRIMARY KEY (id_producto_servicio),
    CONSTRAINT [FK_servicio_producto_servicio] FOREIGN KEY (
        id_producto_servicio
    ) REFERENCES dbo.producto_servicio (id_producto_servicio),
    CONSTRAINT [FK_servicio_unidad_cobro] FOREIGN KEY (
        id_unidad_cobro
    ) REFERENCES dbo.unidad_cobro (id_unidad_cobro)
);
GO
