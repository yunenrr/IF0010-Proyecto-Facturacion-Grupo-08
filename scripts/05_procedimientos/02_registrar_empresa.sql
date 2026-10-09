USE facturacion;
GO

CREATE OR ALTER PROCEDURE dbo.registrar_empresa
    @id_direccion BIGINT, @cedula VARCHAR(20),
    @nombre_comercial VARCHAR(200), @razon_social VARCHAR(250),
    @telefono VARCHAR(20), @correo_electronico VARCHAR(254), @activo BIT,
    @id_empresa INT OUTPUT,
    @codigo_error INT OUTPUT,
    @mensaje_error VARCHAR(4000) OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    SET @codigo_error = 0;
    SET @mensaje_error = N'';
    SET @id_empresa = NULL;
    DECLARE @entrada INT = @@TRANCOUNT;
    DECLARE @guardado BIT = 0;
    BEGIN TRY

        IF @entrada = 0
            BEGIN TRANSACTION;
        ELSE
            BEGIN
                SAVE TRANSACTION registrar_empresa;
                SET @guardado = 1;
            END;
        IF
            @telefono IS NULL OR TRIM(@telefono) = ''
            OR @correo_electronico IS NULL OR TRIM(@correo_electronico) = ''
            THROW 50013, 'Telefono y correo son obligatorios.', 1;
        IF
            NOT EXISTS (
                SELECT 1 FROM dbo.direccion
                WHERE id_direccion = @id_direccion
            )
            THROW 50014, 'La direccion no existe.', 1;

        IF
            @cedula IS NULL OR TRIM(@cedula) = '' OR @nombre_comercial IS NULL
            OR TRIM(@nombre_comercial) = N'' OR @razon_social IS NULL
            OR TRIM(@razon_social) = N'' OR @activo IS NULL
            THROW 50015,
            'Complete los datos obligatorios de la empresa.',
            1;
        IF
            EXISTS (
                SELECT 1 FROM dbo.empresa_emisora WITH (UPDLOCK, HOLDLOCK)
                WHERE cedula = TRIM(@cedula)
            )
            THROW 50016, 'La cedula de empresa ya existe.', 1;
        IF
            EXISTS (
                SELECT 1 FROM dbo.empresa_emisora WITH (UPDLOCK, HOLDLOCK)
                WHERE id_direccion = @id_direccion
            )
            THROW 50019, 'Direccion asignada a otra empresa.', 1;
        INSERT INTO dbo.empresa_emisora (
            id_direccion, cedula, nombre_comercial,
            razon_social, telefono, correo_electronico, fecha_creacion, activo
        )
        VALUES (
            @id_direccion, TRIM(@cedula), TRIM(@nombre_comercial),
            TRIM(@razon_social), TRIM(@telefono), TRIM(@correo_electronico),
            SYSDATETIME(), @activo
        );
        SET @id_empresa = SCOPE_IDENTITY();

        IF @entrada = 0 COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        SET @codigo_error = ERROR_NUMBER();
        SET @mensaje_error = ERROR_MESSAGE();
        SET @id_empresa = NULL;
        IF @entrada = 0 AND XACT_STATE() <> 0
            ROLLBACK TRANSACTION;
        ELSE IF @guardado = 1 AND XACT_STATE() = 1
            ROLLBACK TRANSACTION registrar_empresa;
    END CATCH;
    RETURN @codigo_error;
END;
GO
