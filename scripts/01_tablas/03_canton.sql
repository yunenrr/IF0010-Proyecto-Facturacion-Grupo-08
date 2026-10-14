USE facturacion;
GO

CREATE TABLE dbo.canton
(
    id_provincia INT NOT NULL,
    id_canton SMALLINT NOT NULL,
    nombre_canton VARCHAR(100) NOT NULL,
    CONSTRAINT [PK_canton] PRIMARY KEY (id_provincia, id_canton),
    CONSTRAINT [FK_canton_provincia] FOREIGN KEY (
        id_provincia
    ) REFERENCES dbo.provincia (id_provincia)
);
GO
