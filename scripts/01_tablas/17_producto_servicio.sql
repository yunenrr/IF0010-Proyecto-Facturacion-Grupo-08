USE facturacion;
GO

CREATE TABLE dbo.producto_servicio
(
    id_producto_servicio INT IDENTITY (1, 1) NOT NULL,
    id_tipo_articulo INT NOT NULL,
    codigo_interno VARCHAR(30) NOT NULL,
    id_descripcion INT NOT NULL,
    precio_unitario_lista DECIMAL(19, 4) NOT NULL,
    porcentaje_impuesto DECIMAL(5, 2) NOT NULL,
    activo BIT NOT NULL,
    fecha_creacion DATETIME2(7) NOT NULL,
    CONSTRAINT [PK_producto_servicio] PRIMARY KEY (id_producto_servicio),
    CONSTRAINT [FK_producto_servicio_tipo_articulo] FOREIGN KEY (
        id_tipo_articulo
    ) REFERENCES dbo.tipo_articulo (id_tipo_articulo),
    CONSTRAINT [FK_producto_servicio_descripcion_articulo] FOREIGN KEY (
        id_descripcion
    ) REFERENCES dbo.descripcion_articulo (id_descripcion)
);
GO
