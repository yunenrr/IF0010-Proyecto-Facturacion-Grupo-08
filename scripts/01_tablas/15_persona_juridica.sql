USE facturacion;
GO

CREATE TABLE dbo.persona_juridica
(
    id_cliente INT NOT NULL,
    razon_social VARCHAR(250) NOT NULL,
    nombre_comercial VARCHAR(200) NOT NULL,
    CONSTRAINT [PK_persona_juridica] PRIMARY KEY (id_cliente),
    CONSTRAINT [FK_persona_juridica_cliente] FOREIGN KEY (
        id_cliente
    ) REFERENCES dbo.cliente (id_cliente)
);
GO
