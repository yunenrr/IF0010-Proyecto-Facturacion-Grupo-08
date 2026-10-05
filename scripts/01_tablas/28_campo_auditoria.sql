USE facturacion;
GO

CREATE TABLE dbo.campo_auditoria
(
    id_campo INT IDENTITY (1, 1) NOT NULL,
    id_entidad INT NOT NULL,
    nombre VARCHAR(128) NOT NULL,
    CONSTRAINT [PK_campo_auditoria] PRIMARY KEY (id_campo),
    CONSTRAINT [FK_campo_auditoria_entidad_auditoria] FOREIGN KEY (
        id_entidad
    ) REFERENCES dbo.entidad_auditoria (id_entidad)
);
GO
