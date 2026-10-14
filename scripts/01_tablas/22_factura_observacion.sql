USE facturacion;
GO

CREATE TABLE dbo.factura_observacion
(
    id_factura BIGINT NOT NULL,
    id_observacion INT NOT NULL,
    CONSTRAINT [PK_factura_observacion] PRIMARY KEY (id_factura),
    CONSTRAINT [FK_factura_observacion_factura] FOREIGN KEY (
        id_factura
    ) REFERENCES dbo.factura (id_factura),
    CONSTRAINT [FK_factura_observacion_observacion] FOREIGN KEY (
        id_observacion
    ) REFERENCES dbo.observacion (id_observacion)
);
GO
