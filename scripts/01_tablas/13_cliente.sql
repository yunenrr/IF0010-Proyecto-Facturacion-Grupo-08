USE facturacion;
GO

CREATE TABLE dbo.cliente
(
    id_cliente INT IDENTITY (1, 1) NOT NULL,
    id_direccion BIGINT NOT NULL,
    id_tipo_persona INT NOT NULL,
    cedula VARCHAR(20) NOT NULL,
    telefono VARCHAR(20) NOT NULL,
    correo_electronico VARCHAR(254) NOT NULL,
    fecha_registro DATETIME2(7) NOT NULL,
    fecha_ultima_actualizacion DATETIME2(7) NOT NULL,
    CONSTRAINT [PK_cliente] PRIMARY KEY (id_cliente),
    CONSTRAINT [FK_cliente_direccion] FOREIGN KEY (
        id_direccion
    ) REFERENCES dbo.direccion (id_direccion),
    CONSTRAINT [FK_cliente_tipo_persona] FOREIGN KEY (
        id_tipo_persona
    ) REFERENCES dbo.tipo_persona (id_tipo_persona)
);
GO
