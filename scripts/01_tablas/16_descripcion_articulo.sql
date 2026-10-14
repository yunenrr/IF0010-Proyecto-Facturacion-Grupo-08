USE facturacion;
GO

CREATE TABLE dbo.descripcion_articulo
(
    id_descripcion INT IDENTITY (1, 1) NOT NULL,
    descripcion VARCHAR(500) NOT NULL,
    CONSTRAINT [PK_descripcion_articulo] PRIMARY KEY (id_descripcion)
);
GO
