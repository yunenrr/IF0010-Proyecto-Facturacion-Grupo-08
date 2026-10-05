USE facturacion;
GO

CREATE TABLE dbo.estado_factura
(
    id_estado INT NOT NULL,
    codigo_estado VARCHAR(15) NOT NULL,
    descripcion VARCHAR(150) NOT NULL,
    CONSTRAINT [PK_estado_factura] PRIMARY KEY (id_estado)
);
GO
