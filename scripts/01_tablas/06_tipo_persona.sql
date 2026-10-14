USE facturacion;
GO

CREATE TABLE dbo.tipo_persona
(
    id_tipo_persona INT NOT NULL,
    descripcion VARCHAR(30) NOT NULL,
    CONSTRAINT [PK_tipo_persona] PRIMARY KEY (id_tipo_persona)
);
GO
