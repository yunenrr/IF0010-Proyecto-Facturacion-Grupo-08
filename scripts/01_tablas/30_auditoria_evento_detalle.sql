USE facturacion;
GO

CREATE TABLE dbo.auditoria_evento_detalle
(
    id_evento BIGINT NOT NULL,
    numero_linea SMALLINT NOT NULL,
    CONSTRAINT [PK_auditoria_evento_detalle] PRIMARY KEY (id_evento),
    CONSTRAINT [FK_auditoria_evento_detalle_auditoria_evento] FOREIGN KEY (
        id_evento
    ) REFERENCES dbo.auditoria_evento (id_evento)
);
GO
