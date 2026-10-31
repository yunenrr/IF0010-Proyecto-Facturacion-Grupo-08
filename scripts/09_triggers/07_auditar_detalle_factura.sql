USE facturacion;
GO

CREATE OR ALTER TRIGGER dbo.auditar_detalle_factura
ON dbo.detalle_factura
AFTER INSERT, UPDATE, DELETE
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE
        @cambios TABLE
        (
            id_registro BIGINT NOT NULL,
            numero_linea SMALLINT NOT NULL,
            id_operacion INT NOT NULL,
            campo VARCHAR(128) NOT NULL,
            anterior VARCHAR(4000) NULL,
            nuevo VARCHAR(4000) NULL
        );

    WITH registros AS (
        SELECT
            COALESCE(i.id_factura, d.id_factura) AS id_registro,
            COALESCE(i.numero_linea, d.numero_linea) AS numero_linea,
            CASE
                WHEN d.id_factura IS NULL THEN 1
                WHEN i.id_factura IS NULL THEN 3 ELSE 2
            END AS id_operacion,
            CONVERT(VARCHAR(4000), d.id_producto_servicio)
                AS id_producto_servicio_anterior,
            CONVERT(VARCHAR(4000), i.id_producto_servicio)
                AS id_producto_servicio_nuevo,
            CONVERT(VARCHAR(4000), d.id_descripcion) AS id_descripcion_anterior,
            CONVERT(VARCHAR(4000), i.id_descripcion) AS id_descripcion_nuevo,
            CONVERT(VARCHAR(4000), d.cantidad) AS cantidad_anterior,
            CONVERT(VARCHAR(4000), i.cantidad) AS cantidad_nuevo,
            CONVERT(VARCHAR(4000), d.precio_unitario)
                AS precio_unitario_anterior,
            CONVERT(VARCHAR(4000), i.precio_unitario) AS precio_unitario_nuevo,
            CONVERT(VARCHAR(4000), d.porcentaje_impuesto)
                AS porcentaje_impuesto_anterior,
            CONVERT(VARCHAR(4000), i.porcentaje_impuesto)
                AS porcentaje_impuesto_nuevo,
            CONVERT(VARCHAR(4000), d.monto_descuento)
                AS monto_descuento_anterior,
            CONVERT(VARCHAR(4000), i.monto_descuento) AS monto_descuento_nuevo,
            CONVERT(VARCHAR(4000), d.subtotal_linea) AS subtotal_linea_anterior,
            CONVERT(VARCHAR(4000), i.subtotal_linea) AS subtotal_linea_nuevo,
            CONVERT(VARCHAR(4000), d.monto_impuesto) AS monto_impuesto_anterior,
            CONVERT(VARCHAR(4000), i.monto_impuesto) AS monto_impuesto_nuevo,
            CONVERT(VARCHAR(4000), d.monto_total_linea)
                AS monto_total_linea_anterior,
            CONVERT(VARCHAR(4000), i.monto_total_linea)
                AS monto_total_linea_nuevo
        FROM inserted AS i
        FULL OUTER JOIN
            deleted AS d
            ON i.id_factura = d.id_factura AND i.numero_linea = d.numero_linea
    ),

    valores AS (
        SELECT
            id_registro,
            numero_linea,
            id_operacion,
            'id_producto_servicio' AS campo,
            id_producto_servicio_anterior AS anterior,
            id_producto_servicio_nuevo AS nuevo
        FROM registros
        UNION ALL
        SELECT
            id_registro,
            numero_linea,
            id_operacion,
            'id_descripcion' AS campo,
            id_descripcion_anterior AS anterior,
            id_descripcion_nuevo AS nuevo
        FROM registros
        UNION ALL
        SELECT
            id_registro,
            numero_linea,
            id_operacion,
            'cantidad' AS campo,
            cantidad_anterior AS anterior,
            cantidad_nuevo AS nuevo
        FROM registros
        UNION ALL
        SELECT
            id_registro,
            numero_linea,
            id_operacion,
            'precio_unitario' AS campo,
            precio_unitario_anterior AS anterior,
            precio_unitario_nuevo AS nuevo
        FROM registros
        UNION ALL
        SELECT
            id_registro,
            numero_linea,
            id_operacion,
            'porcentaje_impuesto' AS campo,
            porcentaje_impuesto_anterior AS anterior,
            porcentaje_impuesto_nuevo AS nuevo
        FROM registros
        UNION ALL
        SELECT
            id_registro,
            numero_linea,
            id_operacion,
            'monto_descuento' AS campo,
            monto_descuento_anterior AS anterior,
            monto_descuento_nuevo AS nuevo
        FROM registros
        UNION ALL
        SELECT
            id_registro,
            numero_linea,
            id_operacion,
            'subtotal_linea' AS campo,
            subtotal_linea_anterior AS anterior,
            subtotal_linea_nuevo AS nuevo
        FROM registros
        UNION ALL
        SELECT
            id_registro,
            numero_linea,
            id_operacion,
            'monto_impuesto' AS campo,
            monto_impuesto_anterior AS anterior,
            monto_impuesto_nuevo AS nuevo
        FROM registros
        UNION ALL
        SELECT
            id_registro,
            numero_linea,
            id_operacion,
            'monto_total_linea' AS campo,
            monto_total_linea_anterior AS anterior,
            monto_total_linea_nuevo AS nuevo
        FROM registros
    )

    INSERT INTO @cambios (
        id_registro, numero_linea, id_operacion, campo, anterior, nuevo
    )
    SELECT
        v.id_registro,
        v.numero_linea,
        v.id_operacion,
        v.campo,
        v.anterior,
        v.nuevo
    FROM valores AS v
    WHERE
        v.anterior <> v.nuevo
        OR (v.anterior IS NULL AND v.nuevo IS NOT NULL)
        OR (v.anterior IS NOT NULL AND v.nuevo IS NULL);

    IF NOT EXISTS (SELECT 1 FROM @cambios) RETURN;

    BEGIN TRY
        BEGIN TRANSACTION;
        DECLARE @usuario VARCHAR(128) = ORIGINAL_LOGIN();
        DECLARE @id_usuario INT;
        DECLARE @fecha DATETIME2(7) = SYSDATETIME();

        SELECT @id_usuario = id_usuario
        FROM dbo.usuario_auditoria WITH (UPDLOCK, HOLDLOCK)
        WHERE nombre = @usuario;
        IF @id_usuario IS NULL
            BEGIN
                INSERT INTO dbo.usuario_auditoria (nombre) VALUES (@usuario);
                SET @id_usuario = SCOPE_IDENTITY();
            END;

        DECLARE @id_factura BIGINT, @linea SMALLINT;
        DECLARE @operacion INT, @id_evento BIGINT;
        DECLARE detalle_cursor CURSOR LOCAL FAST_FORWARD FOR
        SELECT DISTINCT
            id_registro,
            numero_linea,
            id_operacion
        FROM @cambios;
        OPEN detalle_cursor;
        FETCH NEXT FROM detalle_cursor INTO @id_factura, @linea, @operacion;
        WHILE @@FETCH_STATUS = 0
            BEGIN
                INSERT INTO dbo.auditoria_evento
                (
                    id_entidad, id_registro_principal, id_operacion,
                    id_usuario, fecha_hora_cambio
                )
                VALUES (2, @id_factura, @operacion, @id_usuario, @fecha);
                SET @id_evento = SCOPE_IDENTITY();
                INSERT INTO dbo.auditoria_evento_detalle (
                    id_evento, numero_linea
                )
                VALUES (@id_evento, @linea);

                INSERT INTO dbo.auditoria_valor
                (id_evento, id_campo, id_momento, valor)
                SELECT
                    @id_evento AS id_evento,
                    a.id_campo,
                    1 AS id_momento,
                    c.anterior
                FROM @cambios AS c
                INNER JOIN dbo.campo_auditoria AS a
                    ON a.id_entidad = 2 AND c.campo = a.nombre
                WHERE
                    c.id_registro = @id_factura AND c.numero_linea = @linea
                    AND c.anterior IS NOT NULL
                UNION ALL
                SELECT
                    @id_evento AS id_evento,
                    a.id_campo,
                    2 AS id_momento,
                    c.nuevo
                FROM @cambios AS c
                INNER JOIN dbo.campo_auditoria AS a
                    ON a.id_entidad = 2 AND c.campo = a.nombre
                WHERE
                    c.id_registro = @id_factura AND c.numero_linea = @linea
                    AND c.nuevo IS NOT NULL;

                FETCH NEXT FROM detalle_cursor
                INTO @id_factura, @linea, @operacion;
            END;
        CLOSE detalle_cursor;
        DEALLOCATE detalle_cursor;

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF CURSOR_STATUS('local', 'detalle_cursor') >= 0
            CLOSE detalle_cursor;
        IF CURSOR_STATUS('local', 'detalle_cursor') > -3
            DEALLOCATE detalle_cursor;
        IF XACT_STATE() <> 0 ROLLBACK TRANSACTION;
        DECLARE @mensaje VARCHAR(2048) = ERROR_MESSAGE();
        RAISERROR ('Error al auditar detalle_factura: %s', 16, 1, @mensaje);
    END CATCH;
END;
GO
