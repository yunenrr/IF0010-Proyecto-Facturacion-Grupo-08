USE facturacion;
GO

CREATE OR ALTER PROCEDURE dbo.eliminar_observacion_factura
    @id_factura BIGINT,
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
                SAVE TRANSACTION eliminar_observacion_factura;
                SET @guardado = 1;
            END;

        IF
            NOT EXISTS (
                SELECT 1 FROM dbo.factura WITH (UPDLOCK, HOLDLOCK)
                WHERE id_factura = @id_factura
            )
            THROW 50011, 'La factura no existe.', 1;
        DELETE FROM dbo.factura_observacion
        WHERE id_factura = @id_factura;

        IF @entrada = 0 COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        SET @codigo_error = ERROR_NUMBER();
        SET @mensaje_error = ERROR_MESSAGE();

        IF @entrada = 0 AND XACT_STATE() <> 0
            ROLLBACK TRANSACTION;
        ELSE IF @guardado = 1 AND XACT_STATE() = 1
            ROLLBACK TRANSACTION eliminar_observacion_factura;
    END CATCH;
    RETURN @codigo_error;
END;
GO
