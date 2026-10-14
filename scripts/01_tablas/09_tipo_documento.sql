USE facturacion;
GO

CREATE TABLE dbo.tipo_documento
(
    id_tipo_documento INT NOT NULL,
    codigo_tipo_documento VARCHAR(10) NOT NULL,
    descripcion VARCHAR(100) NOT NULL,
    CONSTRAINT [PK_tipo_documento] PRIMARY KEY (id_tipo_documento)
);
GO
