USE facturacion;
GO

CREATE TABLE dbo.observacion
(
    id_observacion INT IDENTITY (1, 1) NOT NULL,
    texto VARCHAR(800) NOT NULL,
    CONSTRAINT [PK_observacion] PRIMARY KEY (id_observacion)
);
GO
