USE facturacion;
GO

CREATE TABLE dbo.auditoria_evento
(
    id_evento BIGINT IDENTITY (1, 1) NOT NULL,
    id_entidad INT NOT NULL,
    id_registro_principal BIGINT NOT NULL,
    id_operacion INT NOT NULL,
    id_usuario INT NOT NULL,
    fecha_hora_cambio DATETIME2(7) NOT NULL,
    CONSTRAINT [PK_auditoria_evento] PRIMARY KEY (id_evento),
    CONSTRAINT [FK_auditoria_evento_entidad_auditoria] FOREIGN KEY (
        id_entidad
    ) REFERENCES dbo.entidad_auditoria (id_entidad),
    CONSTRAINT [FK_auditoria_evento_operacion_auditoria] FOREIGN KEY (
        id_operacion
    ) REFERENCES dbo.operacion_auditoria (id_operacion),
    CONSTRAINT [FK_auditoria_evento_usuario_auditoria] FOREIGN KEY (
        id_usuario
    ) REFERENCES dbo.usuario_auditoria (id_usuario)
);
GO
