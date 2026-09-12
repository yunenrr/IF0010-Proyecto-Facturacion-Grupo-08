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

IF
    NOT EXISTS
    (
        SELECT 1
        FROM sys.indexes
        WHERE
            name = N'UX_cliente_cedula'
            AND object_id = OBJECT_ID(N'dbo.cliente')
    )
    BEGIN
        CREATE UNIQUE NONCLUSTERED INDEX [UX_cliente_cedula]
            ON dbo.cliente (cedula)
            INCLUDE
            (
                nombre_razon_social,
                correo_electronico,
                telefono,
                id_direccion,
                fecha_ultima_actualizacion
            );
    END;
GO
