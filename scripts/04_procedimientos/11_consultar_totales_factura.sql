USE facturacion;
GO

CREATE OR ALTER PROCEDURE dbo.consultar_totales_factura
    @id_factura BIGINT = NULL,
    @identificador_comprobante VARCHAR(40) = NULL,
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
                SAVE TRANSACTION consultar_totales_factura;
                SET @guardado = 1;
            END;

        IF
            (@id_factura IS NULL AND @identificador_comprobante IS NULL)
            OR (
                @id_factura IS NOT NULL
                AND @identificador_comprobante IS NOT NULL
            )
            THROW 50010, 'Indique solo id o comprobante.', 1;
        IF @identificador_comprobante IS NOT NULL
            BEGIN
                IF TRIM(@identificador_comprobante) = ''
                    THROW 50010, 'El comprobante no puede estar vacio.', 1;
                SELECT @id_factura = id_factura FROM dbo.factura
                WHERE
                    identificador_comprobante
                    = TRIM(@identificador_comprobante);
            END;
        IF
            NOT EXISTS (
                SELECT 1 FROM dbo.factura
                WHERE id_factura = @id_factura
            )
            THROW 50011, 'La factura no existe.', 1;
        SELECT
            f.id_factura,
            f.identificador_comprobante,
            m.codigo_moneda,
            f.subtotal,
            f.total_descuentos,
            f.total_impuestos,
            f.monto_total
        FROM dbo.factura AS f
        INNER JOIN dbo.moneda AS m ON f.id_moneda = m.id_moneda
        WHERE f.id_factura = @id_factura;

        IF @entrada = 0 COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        SET @codigo_error = ERROR_NUMBER();
        SET @mensaje_error = ERROR_MESSAGE();

        IF @entrada = 0 AND XACT_STATE() <> 0
            ROLLBACK TRANSACTION;
        ELSE IF @guardado = 1 AND XACT_STATE() = 1
            ROLLBACK TRANSACTION consultar_totales_factura;
    END CATCH;
    RETURN @codigo_error;
END;
GO
