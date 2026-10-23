USE facturacion;
GO

CREATE OR ALTER PROCEDURE dbo.guardar_observacion_factura
    @id_factura BIGINT, @texto VARCHAR(800),
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
                SAVE TRANSACTION guardar_observacion_factura;
                SET @guardado = 1;
            END;

        IF @texto IS NULL OR TRIM(@texto) = N''
            THROW 50026, 'El texto de observacion es obligatorio.', 1;
        IF
            NOT EXISTS (
                SELECT 1 FROM dbo.factura WITH (UPDLOCK, HOLDLOCK)
                WHERE id_factura = @id_factura
            )
            THROW 50011, 'La factura no existe.', 1;
        DECLARE @id_observacion INT;
        SELECT @id_observacion = id_observacion
        FROM
            dbo.observacion
            WITH (UPDLOCK, HOLDLOCK)
        WHERE texto = TRIM(@texto);
        IF @id_observacion IS NULL
            BEGIN
                INSERT INTO dbo.observacion (texto) VALUES (TRIM(@texto));
                SET @id_observacion = SCOPE_IDENTITY();
            END;
        UPDATE dbo.factura_observacion SET id_observacion = @id_observacion
        WHERE id_factura = @id_factura;
        IF @@ROWCOUNT = 0
            INSERT INTO dbo.factura_observacion (id_factura, id_observacion)
            VALUES (@id_factura, @id_observacion);

        IF @entrada = 0 COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        SET @codigo_error = ERROR_NUMBER();
        SET @mensaje_error = ERROR_MESSAGE();

        IF @entrada = 0 AND XACT_STATE() <> 0
            ROLLBACK TRANSACTION;
        ELSE IF @guardado = 1 AND XACT_STATE() = 1
            ROLLBACK TRANSACTION guardar_observacion_factura;
    END CATCH;
    RETURN @codigo_error;
END;
GO
