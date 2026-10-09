USE facturacion;
GO

CREATE OR ALTER PROCEDURE dbo.registrar_factura
    @id_empresa INT, @id_cliente INT,
    @id_tipo_documento INT, @id_moneda INT, @id_estado INT,
    @detalles dbo.DETALLE_FACTURA_ENTRADA READONLY,
    @id_factura BIGINT OUTPUT, @identificador_comprobante VARCHAR(40) OUTPUT,
    @fecha_emision DATETIME2(0) = NULL, @observaciones VARCHAR(800) = NULL,
    @codigo_error INT OUTPUT,
    @mensaje_error VARCHAR(4000) OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    SET @codigo_error = 0;
    SET @mensaje_error = N'';
    SET @id_factura = NULL; SET @identificador_comprobante = NULL;
    DECLARE @entrada INT = @@TRANCOUNT;
    DECLARE @guardado BIT = 0;
    BEGIN TRY

        IF @entrada = 0
            BEGIN TRANSACTION;
        ELSE
            BEGIN
                SAVE TRANSACTION registrar_factura;
                SET @guardado = 1;
            END;

        IF NOT EXISTS (SELECT 1 FROM @detalles)
            THROW 50001, 'La factura debe contener al menos una linea.', 1;
        IF
            EXISTS (
                SELECT 1 FROM @detalles
                WHERE
                    numero_linea <= 0 OR cantidad <= 0
                    OR precio_unitario <= 0 OR porcentaje_impuesto < 0
                    OR porcentaje_impuesto > 100 OR monto_descuento < 0
            )
            THROW 50002, 'Una linea contiene valores invalidos.', 1;
        IF
            EXISTS (
                SELECT 1 FROM @detalles
                HAVING
                    MIN(numero_linea) <> 1
                    OR MAX(numero_linea) <> COUNT(*)
                    OR COUNT(DISTINCT numero_linea) <> COUNT(*)
            )
            THROW 50003,
            'Las lineas deben ser consecutivas y no repetidas.',
            1;
        IF
            NOT EXISTS (
                SELECT 1 FROM dbo.empresa_emisora WITH (HOLDLOCK)
                WHERE id_empresa = @id_empresa AND activo = 1
            )
            THROW 50004, 'La empresa no existe o esta inactiva.', 1;
        IF
            NOT EXISTS (
                SELECT 1 FROM dbo.cliente
                WHERE id_cliente = @id_cliente
            )
            THROW 50005, 'El cliente no existe.', 1;
        DECLARE @tipo VARCHAR(10);
        SELECT @tipo = codigo_tipo_documento FROM dbo.tipo_documento
        WHERE id_tipo_documento = @id_tipo_documento;
        IF @tipo IS NULL THROW 50006, 'El tipo de documento no existe.', 1;
        IF
            NOT EXISTS (
                SELECT 1 FROM dbo.moneda
                WHERE id_moneda = @id_moneda
            )
            THROW 50017, 'La moneda no existe.', 1;
        IF
            NOT EXISTS (
                SELECT 1 FROM dbo.estado_factura
                WHERE id_estado = @id_estado
            )
            THROW 50018, 'El estado no existe.', 1;
        IF
            EXISTS (
                SELECT 1 FROM @detalles AS d
                LEFT JOIN dbo.producto_servicio AS p WITH (HOLDLOCK)
                    ON d.id_producto_servicio = p.id_producto_servicio
                LEFT JOIN dbo.producto AS pr WITH (HOLDLOCK)
                    ON p.id_producto_servicio = pr.id_producto_servicio
                LEFT JOIN dbo.servicio AS s WITH (HOLDLOCK)
                    ON p.id_producto_servicio = s.id_producto_servicio
                WHERE
                    p.id_producto_servicio IS NULL OR p.activo = 0
                    OR (
                        p.id_tipo_articulo = 1
                        AND pr.id_producto_servicio IS NULL
                    )
                    OR (
                        p.id_tipo_articulo = 2
                        AND s.id_producto_servicio IS NULL
                    )
            )
            THROW 50007, 'Articulo inexistente, inactivo o sin subtipo.', 1;
        IF @observaciones IS NOT NULL AND TRIM(@observaciones) = N''
            THROW 50026,
            'La observacion proporcionada no puede estar vacia.',
            1;

        SELECT
            d.numero_linea,
            d.id_producto_servicio,
            p.id_descripcion,
            d.cantidad,
            d.precio_unitario,
            d.porcentaje_impuesto,
            d.monto_descuento,
            CAST(ROUND(d.cantidad * d.precio_unitario, 4) AS DECIMAL(19, 4))
                AS subtotal_linea
        INTO #bases FROM @detalles AS d
        INNER JOIN
            dbo.producto_servicio AS p
            ON d.id_producto_servicio = p.id_producto_servicio;
        IF
            EXISTS (
                SELECT 1 FROM #bases
                WHERE
                    subtotal_linea <= 0
                    OR monto_descuento > subtotal_linea
            )
            THROW 50008, 'Subtotal insuficiente para el descuento.', 1;
        SELECT
            b.numero_linea,
            b.id_producto_servicio,
            b.id_descripcion,
            b.cantidad,
            b.precio_unitario,
            b.porcentaje_impuesto,
            b.monto_descuento,
            b.subtotal_linea,
            CAST(ROUND(
                (b.subtotal_linea - b.monto_descuento)
                * b.porcentaje_impuesto / 100, 4
            ) AS DECIMAL(19, 4
            )) AS monto_impuesto
        INTO #lineas FROM #bases AS b;
        SET @fecha_emision = COALESCE(@fecha_emision, SYSDATETIME());
        SET @identificador_comprobante = CONCAT(
            CONVERT(CHAR(8), @fecha_emision, 112),
            REPLACE(CONVERT(CHAR(8), @fecha_emision, 108), ':', ''), '-', @tipo
        );
        IF
            EXISTS (
                SELECT 1 FROM dbo.factura WITH (UPDLOCK, HOLDLOCK)
                WHERE identificador_comprobante = @identificador_comprobante
            )
            THROW 50009,
            'Comprobante duplicado para ese tipo y segundo.',
            1;
        DECLARE @ahora DATETIME2(7) = SYSDATETIME();
        INSERT INTO dbo.factura (
            identificador_comprobante, id_empresa, id_cliente,
            id_tipo_documento, id_moneda, id_estado, fecha_emision, subtotal,
            total_descuentos,
            total_impuestos,
            monto_total,
            fecha_creacion,
            fecha_modificacion
        )
        SELECT
            @identificador_comprobante AS identificador_comprobante,
            @id_empresa AS id_empresa,
            @id_cliente AS id_cliente,
            @id_tipo_documento AS id_tipo_documento,
            @id_moneda AS id_moneda,
            @id_estado AS id_estado,
            @fecha_emision AS fecha_emision,
            SUM(subtotal_linea) AS subtotal,
            SUM(monto_descuento) AS total_descuentos,
            SUM(monto_impuesto) AS total_impuestos,
            SUM(subtotal_linea - monto_descuento + monto_impuesto)
                AS monto_total,
            @ahora AS fecha_creacion,
            @ahora AS fecha_modificacion
        FROM #lineas;
        SET @id_factura = SCOPE_IDENTITY();
        INSERT INTO dbo.detalle_factura (
            id_factura, numero_linea, id_producto_servicio,
            id_descripcion, cantidad, precio_unitario, porcentaje_impuesto,
            monto_descuento, subtotal_linea, monto_impuesto, monto_total_linea
        )
        SELECT
            @id_factura AS id_factura,
            numero_linea,
            id_producto_servicio,
            id_descripcion,
            cantidad,
            precio_unitario,
            porcentaje_impuesto,
            monto_descuento,
            subtotal_linea,
            monto_impuesto,
            subtotal_linea
            - monto_descuento
            + monto_impuesto AS monto_total_linea
        FROM #lineas;
        IF @observaciones IS NOT NULL
            BEGIN
                DECLARE @error_obs INT, @mensaje_obs VARCHAR(4000);
                EXEC dbo.guardar_observacion_factura
                    @id_factura, @observaciones,
                    @codigo_error = @error_obs OUTPUT,
                    @mensaje_error = @mensaje_obs OUTPUT;
                IF @error_obs <> 0 THROW 50026, @mensaje_obs, 1;
            END;

        IF @entrada = 0 COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        SET @codigo_error = ERROR_NUMBER();
        SET @mensaje_error = ERROR_MESSAGE();

        SET @id_factura = NULL;
        SET @identificador_comprobante = NULL;
        IF @codigo_error = 8115
            BEGIN
                SET @codigo_error = 50027;
                SET @mensaje_error = N'Importe fuera de rango.';
            END;
        IF @codigo_error IN (2601, 2627)
            BEGIN
                SET @codigo_error = 50009;
                SET @mensaje_error = N'Comprobante duplicado.';
            END;
        IF @entrada = 0 AND XACT_STATE() <> 0
            ROLLBACK TRANSACTION;
        ELSE IF @guardado = 1 AND XACT_STATE() = 1
            ROLLBACK TRANSACTION registrar_factura;
    END CATCH;
    RETURN @codigo_error;
END;
GO
