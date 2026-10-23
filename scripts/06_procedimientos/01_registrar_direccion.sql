USE facturacion;
GO

CREATE OR ALTER PROCEDURE dbo.registrar_direccion
    @id_provincia INT, @id_canton SMALLINT,
    @id_distrito SMALLINT, @senas_exactas VARCHAR(500),
    @id_direccion BIGINT OUTPUT,
    @codigo_error INT OUTPUT,
    @mensaje_error VARCHAR(4000) OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    SET @codigo_error = 0;
    SET @mensaje_error = N'';
    SET @id_direccion = NULL;
    DECLARE @entrada INT = @@TRANCOUNT;
    DECLARE @guardado BIT = 0;
    BEGIN TRY

        IF @entrada = 0
            BEGIN TRANSACTION;
        ELSE
            BEGIN
                SAVE TRANSACTION registrar_direccion;
                SET @guardado = 1;
            END;

        IF @senas_exactas IS NULL OR TRIM(@senas_exactas) = N''
            THROW 50001, 'Las senas exactas son obligatorias.', 1;
        IF
            NOT EXISTS (
                SELECT 1 FROM dbo.distrito
                WHERE
                    id_provincia = @id_provincia
                    AND id_canton = @id_canton AND id_distrito = @id_distrito
            )
            THROW 50002, 'La ruta geografica no existe.', 1;
        INSERT INTO dbo.direccion (
            id_provincia, id_canton, id_distrito, senas_exactas
        )
        VALUES (@id_provincia, @id_canton, @id_distrito, TRIM(@senas_exactas));
        SET @id_direccion = SCOPE_IDENTITY();

        IF @entrada = 0 COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        SET @codigo_error = ERROR_NUMBER();
        SET @mensaje_error = ERROR_MESSAGE();
        SET @id_direccion = NULL;
        IF @entrada = 0 AND XACT_STATE() <> 0
            ROLLBACK TRANSACTION;
        ELSE IF @guardado = 1 AND XACT_STATE() = 1
            ROLLBACK TRANSACTION registrar_direccion;
    END CATCH;
    RETURN @codigo_error;
END;
GO
