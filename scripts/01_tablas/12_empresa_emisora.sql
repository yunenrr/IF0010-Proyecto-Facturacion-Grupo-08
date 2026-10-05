USE facturacion;
GO

CREATE TABLE dbo.empresa_emisora
(
    id_empresa INT IDENTITY (1, 1) NOT NULL,
    id_direccion BIGINT NOT NULL,
    cedula VARCHAR(20) NOT NULL,
    nombre_comercial VARCHAR(200) NOT NULL,
    razon_social VARCHAR(250) NOT NULL,
    telefono VARCHAR(20) NOT NULL,
    correo_electronico VARCHAR(254) NOT NULL,
    fecha_creacion DATETIME2(7) NOT NULL,
    activo BIT NOT NULL,
    CONSTRAINT [PK_empresa_emisora] PRIMARY KEY (id_empresa),
    CONSTRAINT [FK_empresa_emisora_direccion] FOREIGN KEY (
        id_direccion
    ) REFERENCES dbo.direccion (id_direccion)
);
GO
