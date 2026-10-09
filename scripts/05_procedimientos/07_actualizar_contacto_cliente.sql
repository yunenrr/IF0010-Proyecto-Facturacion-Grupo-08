USE facturacion;
GO

CREATE OR ALTER PROCEDURE dbo.actualizar_contacto_cliente
    @id_cliente INT, @id_direccion BIGINT,
    @telefono VARCHAR(20), @correo_electronico VARCHAR(254),
    @codigo_error INT OUTPUT,
    @mensaje_error VARCHAR(4000) OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    SET @codigo_error = 0;
    SET @mensaje_error = N'';

    DECLARE @entrada INT = @@TRANCOUNT;
    DECLARE @guardado BIT = 0;
    BEGIN TRY

        IF @entrada = 0
            BEGIN TRANSACTION;
        ELSE
            BEGIN
                SAVE TRANSACTION actualizar_contacto_cliente;
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
            NOT EXISTS (
                SELECT 1 FROM dbo.cliente WITH (UPDLOCK, HOLDLOCK)
                WHERE id_cliente = @id_cliente
            )
            THROW 50005, 'El cliente no existe.', 1;
        IF
            EXISTS (
                SELECT 1 FROM dbo.cliente WITH (UPDLOCK, HOLDLOCK)
                WHERE id_direccion = @id_direccion AND id_cliente <> @id_cliente
            )
            THROW 50019, 'Direccion asignada a otro cliente.', 1;
        UPDATE dbo.cliente SET
            id_direccion = @id_direccion,
            telefono = TRIM(@telefono),
            correo_electronico = TRIM(@correo_electronico),
            fecha_ultima_actualizacion = SYSDATETIME()
        WHERE id_cliente = @id_cliente;

        IF @entrada = 0 COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        SET @codigo_error = ERROR_NUMBER();
        SET @mensaje_error = ERROR_MESSAGE();

        IF @entrada = 0 AND XACT_STATE() <> 0
            ROLLBACK TRANSACTION;
        ELSE IF @guardado = 1 AND XACT_STATE() = 1
            ROLLBACK TRANSACTION actualizar_contacto_cliente;
    END CATCH;
    RETURN @codigo_error;
END;
GO
