USE facturacion;
GO

SET ANSI_NULLS ON;
SET ANSI_PADDING ON;
SET ANSI_WARNINGS ON;
SET ARITHABORT ON;
SET CONCAT_NULL_YIELDS_NULL ON;
SET QUOTED_IDENTIFIER ON;
SET NUMERIC_ROUNDABORT OFF;
GO

SET NOCOUNT ON;
SET XACT_ABORT ON;
GO

IF NOT EXISTS
(
    SELECT 1
    FROM sys.indexes
    WHERE name = N'IX_auditoria_evento_registro_fecha'
      AND object_id = OBJECT_ID(N'dbo.auditoria_evento')
)
BEGIN
    CREATE NONCLUSTERED INDEX IX_auditoria_evento_registro_fecha
        ON dbo.auditoria_evento
        (
            tipo_entidad,
            id_registro_principal,
            fecha_hora_cambio DESC
        )
        INCLUDE
        (
            id_registro_secundario,
            tipo_operacion,
            usuario_responsable
        );
END;
GO
