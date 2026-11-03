USE facturacion;
GO
SET NOCOUNT ON;

IF @@TRANCOUNT <> 0
    THROW 55001, 'Ejecute la demostracion sin una transaccion abierta.', 1;

DECLARE @id_factura BIGINT = (SELECT MIN(id_factura) FROM dbo.factura);
IF @id_factura IS NULL
    THROW 55002, 'Ejecute primero la carga de datos.', 1;

DECLARE @id_usuario INT, @id_evento BIGINT;

BEGIN TRY
    BEGIN TRANSACTION;

    CREATE USER demo_auditor WITHOUT LOGIN;
    CREATE USER demo_dba WITHOUT LOGIN;
    CREATE USER demo_sin_rol WITHOUT LOGIN;

    ALTER ROLE [Auditor] ADD MEMBER demo_auditor;
    ALTER ROLE dba ADD MEMBER demo_dba;

    GRANT SELECT ON OBJECT::dbo.consultar_historial_cambios TO demo_sin_rol;

    SELECT @id_usuario = id_usuario
    FROM dbo.usuario_auditoria
    WHERE nombre = 'demo_historial';

    IF @id_usuario IS NULL
        BEGIN
            INSERT INTO dbo.usuario_auditoria (nombre) VALUES (
                'demo_historial'
            );
            SET @id_usuario = SCOPE_IDENTITY();
        END;

    INSERT INTO dbo.auditoria_evento
    (
        id_entidad,
        id_registro_principal,
        id_operacion,
        id_usuario,
        fecha_hora_cambio
    )
    VALUES (1, @id_factura, 2, @id_usuario, SYSDATETIME());
    SET @id_evento = SCOPE_IDENTITY();

    EXEC sys.sp_executesql
        N'EXECUTE AS USER = ''demo_auditor'';
SELECT USER_NAME() AS usuario, ''Auditor'' AS rol,
    1 AS registros_esperados, COUNT(*) AS registros_obtenidos
FROM dbo.consultar_historial_cambios()
WHERE id_evento = @id_evento;
REVERT;',
        N'@id_evento BIGINT',
        @id_evento = @id_evento;

    EXEC sys.sp_executesql
        N'EXECUTE AS USER = ''demo_dba'';
SELECT USER_NAME() AS usuario, ''DBA'' AS rol,
    1 AS registros_esperados, COUNT(*) AS registros_obtenidos
FROM dbo.consultar_historial_cambios()
WHERE id_evento = @id_evento;
REVERT;',
        N'@id_evento BIGINT',
        @id_evento = @id_evento;

    EXEC sys.sp_executesql
        N'EXECUTE AS USER = ''demo_sin_rol'';
SELECT USER_NAME() AS usuario, ''Sin rol Auditor ni DBA'' AS rol,
    0 AS registros_esperados, COUNT(*) AS registros_obtenidos
FROM dbo.consultar_historial_cambios()
WHERE id_evento = @id_evento;
REVERT;',
        N'@id_evento BIGINT',
        @id_evento = @id_evento;

    ROLLBACK TRANSACTION;
END TRY
BEGIN CATCH
    IF XACT_STATE() <> 0 ROLLBACK TRANSACTION;
    THROW;
END CATCH;
GO
