USE facturacion;
GO

CREATE TABLE dbo.tipo_articulo
(
    id_tipo_articulo INT NOT NULL,
    descripcion VARCHAR(30) NOT NULL,
    CONSTRAINT [PK_tipo_articulo] PRIMARY KEY (id_tipo_articulo)
);
GO
