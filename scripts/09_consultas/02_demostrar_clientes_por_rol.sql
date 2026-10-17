USE facturacion;
GO
SET NOCOUNT ON;

IF @@TRANCOUNT <> 0
    THROW 55003, 'Ejecute la demostracion sin una transaccion abierta.', 1;

DECLARE @cedula_fisica VARCHAR(20) = (
    SELECT MIN(c.cedula)
    FROM dbo.cliente AS c
    INNER JOIN dbo.persona_fisica AS f ON c.id_cliente = f.id_cliente
);
DECLARE @cedula_juridica VARCHAR(20) = (
    SELECT MIN(c.cedula)
    FROM dbo.cliente AS c
    INNER JOIN dbo.persona_juridica AS j ON c.id_cliente = j.id_cliente
);

IF @cedula_fisica IS NULL OR @cedula_juridica IS NULL
    THROW 55004, 'Se requiere un cliente fisico y uno juridico.', 1;

DECLARE @usuario_cambiado BIT = 0;

BEGIN TRY
    BEGIN TRANSACTION;

    CREATE USER demo_administrativo WITHOUT LOGIN;
    CREATE USER demo_cajero WITHOUT LOGIN;
    CREATE USER demo_consulta WITHOUT LOGIN;
    CREATE USER demo_cliente_sin_rol WITHOUT LOGIN;

    ALTER ROLE Administrativo ADD MEMBER demo_administrativo;
    ALTER ROLE Cajero ADD MEMBER demo_cajero;
    ALTER ROLE Consulta ADD MEMBER demo_consulta;

    GRANT SELECT ON OBJECT::dbo.consultar_informacion_cliente TO demo_cliente_sin_rol;

    PRINT 'Administrativo: se esperan dos clientes con telefono y correo visibles.';
    EXECUTE AS USER = 'demo_administrativo';
    SET @usuario_cambiado = 1;
    SELECT USER_NAME() AS usuario, c.*
    FROM dbo.consultar_informacion_cliente(@cedula_fisica) AS c
    UNION ALL
    SELECT USER_NAME() AS usuario, c.*
    FROM dbo.consultar_informacion_cliente(@cedula_juridica) AS c;
    REVERT;
    SET @usuario_cambiado = 0;

    PRINT 'Cajero: se esperan dos clientes con telefono y correo en NULL.';
    EXECUTE AS USER = 'demo_cajero';
    SET @usuario_cambiado = 1;
    SELECT USER_NAME() AS usuario, c.*
    FROM dbo.consultar_informacion_cliente(@cedula_fisica) AS c
    UNION ALL
    SELECT USER_NAME() AS usuario, c.*
    FROM dbo.consultar_informacion_cliente(@cedula_juridica) AS c;
    REVERT;
    SET @usuario_cambiado = 0;

    PRINT 'Consulta: se esperan dos clientes con telefono y correo en NULL.';
    EXECUTE AS USER = 'demo_consulta';
    SET @usuario_cambiado = 1;
    SELECT USER_NAME() AS usuario, c.*
    FROM dbo.consultar_informacion_cliente(@cedula_fisica) AS c
    UNION ALL
    SELECT USER_NAME() AS usuario, c.*
    FROM dbo.consultar_informacion_cliente(@cedula_juridica) AS c;
    REVERT;
    SET @usuario_cambiado = 0;

    PRINT 'Sin los roles requeridos: se esperan cero clientes.';
    EXECUTE AS USER = 'demo_cliente_sin_rol';
    SET @usuario_cambiado = 1;
    SELECT USER_NAME() AS usuario, c.*
    FROM dbo.consultar_informacion_cliente(@cedula_fisica) AS c
    UNION ALL
    SELECT USER_NAME() AS usuario, c.*
    FROM dbo.consultar_informacion_cliente(@cedula_juridica) AS c;
    REVERT;
    SET @usuario_cambiado = 0;

    ROLLBACK TRANSACTION;
END TRY
BEGIN CATCH
    IF @usuario_cambiado = 1 REVERT;
    IF XACT_STATE() <> 0 ROLLBACK TRANSACTION;
    THROW;
END CATCH;
GO
