USE facturacion;
GO

CREATE TABLE dbo.unidad_cobro
(
    id_unidad_cobro INT NOT NULL,
    descripcion VARCHAR(50) NOT NULL,
    CONSTRAINT [PK_unidad_cobro] PRIMARY KEY (id_unidad_cobro)
);
GO
