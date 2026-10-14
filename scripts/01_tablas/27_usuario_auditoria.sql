USE facturacion;
GO

CREATE TABLE dbo.usuario_auditoria
(
    id_usuario INT IDENTITY (1, 1) NOT NULL,
    nombre VARCHAR(128) NOT NULL,
    CONSTRAINT [PK_usuario_auditoria] PRIMARY KEY (id_usuario)
);
GO
