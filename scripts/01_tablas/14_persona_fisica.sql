USE facturacion;
GO

CREATE TABLE dbo.persona_fisica
(
    id_cliente INT NOT NULL,
    nombre_persona VARCHAR(250) NOT NULL,
    primer_apellido VARCHAR(100) NOT NULL,
    segundo_apellido VARCHAR(100) NOT NULL,
    CONSTRAINT [PK_persona_fisica] PRIMARY KEY (id_cliente),
    CONSTRAINT [FK_persona_fisica_cliente] FOREIGN KEY (
        id_cliente
    ) REFERENCES dbo.cliente (id_cliente)
);
GO
