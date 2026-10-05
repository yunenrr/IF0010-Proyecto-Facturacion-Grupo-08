USE facturacion;
GO

CREATE TABLE dbo.operacion_auditoria
(
    id_operacion INT NOT NULL,
    nombre VARCHAR(10) NOT NULL,
    CONSTRAINT [PK_operacion_auditoria] PRIMARY KEY (id_operacion)
);
GO
