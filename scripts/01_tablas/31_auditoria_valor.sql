USE facturacion;
GO

CREATE TABLE dbo.auditoria_valor
(
    id_evento BIGINT NOT NULL,
    id_campo INT NOT NULL,
    id_momento INT NOT NULL,
    valor VARCHAR(4000) NOT NULL,
    CONSTRAINT [PK_auditoria_valor] PRIMARY KEY (
        id_evento, id_campo, id_momento
    ),
    CONSTRAINT [FK_auditoria_valor_auditoria_evento] FOREIGN KEY (
        id_evento
    ) REFERENCES dbo.auditoria_evento (id_evento),
    CONSTRAINT [FK_auditoria_valor_campo_auditoria] FOREIGN KEY (
        id_campo
    ) REFERENCES dbo.campo_auditoria (id_campo),
    CONSTRAINT [FK_auditoria_valor_momento_auditoria] FOREIGN KEY (
        id_momento
    ) REFERENCES dbo.momento_auditoria (id_momento)
);
GO
