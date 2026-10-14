USE facturacion;
GO

CREATE TABLE dbo.momento_auditoria
(
    id_momento INT NOT NULL,
    nombre VARCHAR(10) NOT NULL,
    CONSTRAINT [PK_momento_auditoria] PRIMARY KEY (id_momento)
);
GO
