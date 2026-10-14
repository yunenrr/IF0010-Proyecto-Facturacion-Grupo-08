USE facturacion;
GO

CREATE TABLE dbo.entidad_auditoria
(
    id_entidad INT NOT NULL,
    nombre VARCHAR(50) NOT NULL,
    CONSTRAINT [PK_entidad_auditoria] PRIMARY KEY (id_entidad)
);
GO
