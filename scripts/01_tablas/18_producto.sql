USE facturacion;
GO

CREATE TABLE dbo.producto
(
    id_producto_servicio INT NOT NULL,
    existencias DECIMAL(18, 4) NOT NULL,
    CONSTRAINT [PK_producto] PRIMARY KEY (id_producto_servicio),
    CONSTRAINT [FK_producto_producto_servicio] FOREIGN KEY (
        id_producto_servicio
    ) REFERENCES dbo.producto_servicio (id_producto_servicio)
);
GO
