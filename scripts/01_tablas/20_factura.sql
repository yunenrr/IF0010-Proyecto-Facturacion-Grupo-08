USE facturacion;
GO

CREATE TABLE dbo.factura
(
    id_factura BIGINT IDENTITY (1, 1) NOT NULL,
    identificador_comprobante VARCHAR(40) NOT NULL,
    id_empresa INT NOT NULL,
    id_cliente INT NOT NULL,
    id_tipo_documento INT NOT NULL,
    id_moneda INT NOT NULL,
    id_estado INT NOT NULL,
    fecha_emision DATETIME2(0) NOT NULL,
    subtotal DECIMAL(19, 4) NOT NULL,
    total_descuentos DECIMAL(19, 4) NOT NULL,
    total_impuestos DECIMAL(19, 4) NOT NULL,
    monto_total DECIMAL(19, 4) NOT NULL,
    fecha_creacion DATETIME2(7) NOT NULL,
    fecha_modificacion DATETIME2(7) NOT NULL,
    CONSTRAINT [PK_factura] PRIMARY KEY (id_factura),
    CONSTRAINT [FK_factura_empresa_emisora] FOREIGN KEY (
        id_empresa
    ) REFERENCES dbo.empresa_emisora (id_empresa),
    CONSTRAINT [FK_factura_cliente] FOREIGN KEY (
        id_cliente
    ) REFERENCES dbo.cliente (id_cliente),
    CONSTRAINT [FK_factura_tipo_documento] FOREIGN KEY (
        id_tipo_documento
    ) REFERENCES dbo.tipo_documento (id_tipo_documento),
    CONSTRAINT [FK_factura_moneda] FOREIGN KEY (
        id_moneda
    ) REFERENCES dbo.moneda (id_moneda),
    CONSTRAINT [FK_factura_estado_factura] FOREIGN KEY (
        id_estado
    ) REFERENCES dbo.estado_factura (id_estado)
);
GO
