USE facturacion;
GO

CREATE OR ALTER PROCEDURE dbo.consultar_facturas_comprador
    @id_cliente INT,
    @fecha_desde DATETIME2(0) = NULL, @fecha_hasta DATETIME2(0) = NULL,
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
                SAVE TRANSACTION consultar_facturas_comprador;
                SET @guardado = 1;
            END;

        IF
            NOT EXISTS (
                SELECT 1 FROM dbo.cliente
                WHERE id_cliente = @id_cliente
            )
            THROW 50005, 'El cliente no existe.', 1;
        IF
            @fecha_desde IS NOT NULL AND @fecha_hasta IS NOT NULL
            AND @fecha_desde >= @fecha_hasta
            THROW 50012, 'El inicio debe ser anterior al limite final.', 1;
        SELECT
            f.id_factura,
            f.identificador_comprobante,
            f.id_empresa,
            f.id_cliente,
            t.codigo_tipo_documento,
            m.codigo_moneda,
            e.codigo_estado,
            f.fecha_emision,
            f.monto_total
        FROM dbo.factura AS f
        INNER JOIN
            dbo.tipo_documento AS t
            ON f.id_tipo_documento = t.id_tipo_documento
        INNER JOIN dbo.moneda AS m ON f.id_moneda = m.id_moneda
        INNER JOIN dbo.estado_factura AS e ON f.id_estado = e.id_estado
        WHERE
            f.id_cliente = @id_cliente
            AND (@fecha_desde IS NULL OR f.fecha_emision >= @fecha_desde)
            AND (@fecha_hasta IS NULL OR f.fecha_emision < @fecha_hasta)
        ORDER BY f.fecha_emision DESC, f.id_factura DESC;

        IF @entrada = 0 COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        SET @codigo_error = ERROR_NUMBER();
        SET @mensaje_error = ERROR_MESSAGE();

        IF @entrada = 0 AND XACT_STATE() <> 0
            ROLLBACK TRANSACTION;
        ELSE IF @guardado = 1 AND XACT_STATE() = 1
            ROLLBACK TRANSACTION consultar_facturas_comprador;
    END CATCH;
    RETURN @codigo_error;
END;
GO
