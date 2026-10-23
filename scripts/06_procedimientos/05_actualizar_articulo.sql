USE facturacion;
GO

CREATE OR ALTER PROCEDURE dbo.actualizar_articulo
    @id_articulo INT, @descripcion VARCHAR(500),
    @precio DECIMAL(19, 4), @impuesto DECIMAL(5, 2), @activo BIT,
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
                SAVE TRANSACTION actualizar_articulo;
                SET @guardado = 1;
            END;
        IF
            @descripcion IS NULL OR TRIM(@descripcion) = N''
            OR @precio IS NULL OR @precio <= 0 OR @impuesto IS NULL
            OR @impuesto < 0 OR @impuesto > 100 OR @activo IS NULL
            THROW 50020,
            'Descripcion, precio, impuesto o estado invalidos.',
            1;

        IF
            NOT EXISTS (
                SELECT 1 FROM dbo.producto_servicio WITH (UPDLOCK, HOLDLOCK)
                WHERE id_producto_servicio = @id_articulo
            )
            THROW 50025, 'El articulo no existe.', 1;
        DECLARE @id_descripcion INT;
        SELECT @id_descripcion = id_descripcion
        FROM
            dbo.descripcion_articulo
            WITH (UPDLOCK, HOLDLOCK)
        WHERE descripcion = TRIM(@descripcion);
        IF @id_descripcion IS NULL
            BEGIN
                INSERT INTO dbo.descripcion_articulo (descripcion)
                VALUES (TRIM(@descripcion));
                SET @id_descripcion = SCOPE_IDENTITY();
            END;

        UPDATE
            dbo.producto_servicio SET
            id_descripcion = @id_descripcion,
            precio_unitario_lista = @precio, porcentaje_impuesto = @impuesto,
            activo = @activo
        WHERE id_producto_servicio = @id_articulo;

        IF @entrada = 0 COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        SET @codigo_error = ERROR_NUMBER();
        SET @mensaje_error = ERROR_MESSAGE();

        IF @entrada = 0 AND XACT_STATE() <> 0
            ROLLBACK TRANSACTION;
        ELSE IF @guardado = 1 AND XACT_STATE() = 1
            ROLLBACK TRANSACTION actualizar_articulo;
    END CATCH;
    RETURN @codigo_error;
END;
GO
