USE facturacion;
GO

SET NOCOUNT ON;
SET XACT_ABORT ON;
GO

IF OBJECT_ID(N'dbo.auditoria_evento', N'U') IS NULL
BEGIN
    CREATE TABLE dbo.auditoria_evento
    (
        id_evento             BIGINT IDENTITY(1,1) NOT NULL,
        tipo_entidad          VARCHAR(30) NOT NULL,
        id_registro_principal BIGINT NOT NULL,
        id_registro_secundario SMALLINT NULL,
        tipo_operacion        VARCHAR(6) NOT NULL,
        usuario_responsable   SYSNAME NOT NULL
            CONSTRAINT DF_auditoria_evento_usuario DEFAULT (ORIGINAL_LOGIN()),
        fecha_hora_cambio     DATETIME2(7) NOT NULL
            CONSTRAINT DF_auditoria_evento_fecha DEFAULT (SYSDATETIME()),
        descripcion_cambios   NVARCHAR(2000) NOT NULL,

        CONSTRAINT PK_auditoria_evento
            PRIMARY KEY CLUSTERED (id_evento),
        CONSTRAINT CK_auditoria_evento_entidad
            CHECK
            (
                tipo_entidad IN
                (
                    'FACTURA',
                    'DETALLE_FACTURA',
                    'CLIENTE',
                    'PRODUCTO_SERVICIO'
                )
            ),
        CONSTRAINT CK_auditoria_evento_operacion
            CHECK (tipo_operacion IN ('INSERT', 'UPDATE', 'DELETE')),
        CONSTRAINT CK_auditoria_evento_registro_secundario
            CHECK
            (
                (tipo_entidad = 'DETALLE_FACTURA' AND id_registro_secundario IS NOT NULL)
                OR
                (tipo_entidad <> 'DETALLE_FACTURA' AND id_registro_secundario IS NULL)
            ),
        CONSTRAINT CK_auditoria_evento_descripcion_no_vacia
            CHECK (LTRIM(RTRIM(descripcion_cambios)) <> N'')
    );

    -- Los identificadores auditados no son llaves foraneas intencionalmente.
    -- El evento debe permanecer aunque el registro original sea eliminado.
END;
GO
