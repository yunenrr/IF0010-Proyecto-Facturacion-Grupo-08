USE facturacion;
GO

CREATE TABLE dbo.provincia
(
    id_provincia INT NOT NULL,
    nombre_provincia VARCHAR(100) NOT NULL,
    CONSTRAINT [PK_provincia] PRIMARY KEY (id_provincia)
);
GO
