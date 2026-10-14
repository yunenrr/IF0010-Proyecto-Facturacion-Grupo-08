USE facturacion;
GO

CREATE TABLE dbo.distrito
(
    id_provincia INT NOT NULL,
    id_canton SMALLINT NOT NULL,
    id_distrito SMALLINT NOT NULL,
    nombre_distrito VARCHAR(100) NOT NULL,
    CONSTRAINT [PK_distrito] PRIMARY KEY (id_provincia, id_canton, id_distrito),
    CONSTRAINT [FK_distrito_canton] FOREIGN KEY (
        id_provincia, id_canton
    ) REFERENCES dbo.canton (id_provincia, id_canton)
);
GO
