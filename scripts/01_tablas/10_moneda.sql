USE facturacion;
GO

CREATE TABLE dbo.moneda
(
    id_moneda INT NOT NULL,
    codigo_moneda CHAR(3) NOT NULL,
    simbolo VARCHAR(5) NOT NULL,
    descripcion VARCHAR(100) NOT NULL,
    CONSTRAINT [PK_moneda] PRIMARY KEY (id_moneda)
);
GO
