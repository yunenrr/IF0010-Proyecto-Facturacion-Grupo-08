USE facturacion;
GO

CREATE OR ALTER TRIGGER dbo.auditar_detalle_factura
ON dbo.detalle_factura
AFTER INSERT, UPDATE, DELETE
AS
BEGIN
    SET NOCOUNT ON;

    IF NOT EXISTS (SELECT 1 FROM deleted)
        BEGIN
            IF NOT EXISTS (SELECT 1 FROM inserted) RETURN;
            BEGIN TRY
                BEGIN TRANSACTION;
                DECLARE @usuario_insert INT;
                DECLARE @nombre_insert VARCHAR(128) = ORIGINAL_LOGIN();
                DECLARE @fecha_insert DATETIME2(7) = SYSDATETIME();
                SELECT @usuario_insert = id_usuario
                FROM dbo.usuario_auditoria WITH (UPDLOCK, HOLDLOCK)
                WHERE nombre = @nombre_insert;
                IF @usuario_insert IS NULL
                    BEGIN
                        INSERT INTO dbo.usuario_auditoria (nombre)
                        VALUES (@nombre_insert);
                        SET @usuario_insert = SCOPE_IDENTITY();
                    END;
                CREATE TABLE #eventos_insert (
                    id_evento BIGINT NOT NULL,
                    id_registro BIGINT NOT NULL PRIMARY KEY
                );
                SELECT
                    id_factura,
                    numero_linea,
                    id_producto_servicio,
                    id_descripcion,
                    cantidad,
                    precio_unitario,
                    porcentaje_impuesto,
                    monto_descuento,
                    subtotal_linea,
                    monto_impuesto,
                    monto_total_linea
                INTO #insertados FROM inserted;
                CREATE UNIQUE CLUSTERED INDEX ix_insertados
                    ON #insertados (numero_linea, id_factura);
                DECLARE @linea_insert SMALLINT;
                DECLARE insercion_cursor CURSOR LOCAL FAST_FORWARD FOR
                SELECT DISTINCT numero_linea FROM #insertados;
                OPEN insercion_cursor;
                FETCH NEXT FROM insercion_cursor INTO @linea_insert;
                WHILE @@FETCH_STATUS = 0
                    BEGIN
                        DELETE FROM #eventos_insert;
                        INSERT INTO dbo.auditoria_evento (
                            id_entidad, id_registro_principal, id_operacion,
                            id_usuario, fecha_hora_cambio
                        )
                        OUTPUT
                            INSERTED.id_evento, INSERTED.id_registro_principal
                        INTO #eventos_insert
                        SELECT
                            2 AS id_entidad,
                            i.id_factura,
                            1 AS id_operacion,
                            @usuario_insert AS id_usuario,
                            @fecha_insert AS fecha_hora_cambio
                        FROM #insertados AS i
                        WHERE i.numero_linea = @linea_insert;
                        INSERT INTO dbo.auditoria_evento_detalle (
                            id_evento, numero_linea
                        )
                        SELECT
                            id_evento,
                            @linea_insert AS numero_linea
                        FROM #eventos_insert
                        ;
                        WITH valores_insert AS (
                            SELECT
                                i.id_factura,
                                'id_producto_servicio' AS campo,
                                CONVERT(VARCHAR(64), i.id_producto_servicio)
                                    AS valor
                            FROM #insertados AS i
                            WHERE i.numero_linea = @linea_insert
                            UNION ALL
                            SELECT
                                i.id_factura,
                                'id_descripcion' AS campo,
                                CONVERT(VARCHAR(64), i.id_descripcion) AS valor
                            FROM #insertados AS i
                            WHERE i.numero_linea = @linea_insert
                            UNION ALL
                            SELECT
                                i.id_factura,
                                'cantidad' AS campo,
                                CONVERT(VARCHAR(64), i.cantidad) AS valor
                            FROM #insertados AS i
                            WHERE i.numero_linea = @linea_insert
                            UNION ALL
                            SELECT
                                i.id_factura,
                                'precio_unitario' AS campo,
                                CONVERT(VARCHAR(64), i.precio_unitario) AS valor
                            FROM #insertados AS i
                            WHERE i.numero_linea = @linea_insert
                            UNION ALL
                            SELECT
                                i.id_factura,
                                'porcentaje_impuesto' AS campo,
                                CONVERT(VARCHAR(64), i.porcentaje_impuesto)
                                    AS valor
                            FROM #insertados AS i
                            WHERE i.numero_linea = @linea_insert
                            UNION ALL
                            SELECT
                                i.id_factura,
                                'monto_descuento' AS campo,
                                CONVERT(VARCHAR(64), i.monto_descuento) AS valor
                            FROM #insertados AS i
                            WHERE i.numero_linea = @linea_insert
                            UNION ALL
                            SELECT
                                i.id_factura,
                                'subtotal_linea' AS campo,
                                CONVERT(VARCHAR(64), i.subtotal_linea) AS valor
                            FROM #insertados AS i
                            WHERE i.numero_linea = @linea_insert
                            UNION ALL
                            SELECT
                                i.id_factura,
                                'monto_impuesto' AS campo,
                                CONVERT(VARCHAR(64), i.monto_impuesto) AS valor
                            FROM #insertados AS i
                            WHERE i.numero_linea = @linea_insert
                            UNION ALL
                            SELECT
                                i.id_factura,
                                'monto_total_linea' AS campo,
                                CONVERT(VARCHAR(64), i.monto_total_linea)
                                    AS valor
                            FROM #insertados AS i
                            WHERE i.numero_linea = @linea_insert
                        )

                        INSERT INTO dbo.auditoria_valor WITH (TABLOCK) (
                            id_evento, id_campo, id_momento, valor
                        )
                        SELECT
                            e.id_evento,
                            a.id_campo,
                            2 AS id_momento,
                            v.valor
                        FROM valores_insert AS v
                        INNER JOIN
                            #eventos_insert AS e
                            ON v.id_factura = e.id_registro
                        INNER JOIN dbo.campo_auditoria AS a
                            ON a.id_entidad = 2 AND v.campo = a.nombre
                        ORDER BY e.id_evento, a.id_campo;
                        FETCH NEXT FROM insercion_cursor INTO @linea_insert;
                    END;
                CLOSE insercion_cursor;
                DEALLOCATE insercion_cursor;
                COMMIT TRANSACTION;
            END TRY
            BEGIN CATCH
                IF CURSOR_STATUS('local', 'insercion_cursor') >= 0
                    CLOSE insercion_cursor;
                IF CURSOR_STATUS('local', 'insercion_cursor') > -3
                    DEALLOCATE insercion_cursor;
                IF XACT_STATE() <> 0 ROLLBACK TRANSACTION;
                DECLARE @error_insert VARCHAR(2048) = ERROR_MESSAGE();
                RAISERROR (
                    'Error al auditar detalle_factura: %s', 16, 1, @error_insert
                );
            END CATCH;
            RETURN;
        END;

    DECLARE
        @cambios TABLE
        (
            id_registro BIGINT NOT NULL,
            numero_linea SMALLINT NOT NULL,
            id_operacion INT NOT NULL,
            campo VARCHAR(64) NOT NULL,
            anterior VARCHAR(64) NULL,
            nuevo VARCHAR(64) NULL,
            PRIMARY KEY (numero_linea, id_registro, campo)
        );

    WITH registros AS (
        SELECT
            COALESCE(i.id_factura, d.id_factura) AS id_registro,
            COALESCE(i.numero_linea, d.numero_linea) AS numero_linea,
            CASE
                WHEN d.id_factura IS NULL THEN 1
                WHEN i.id_factura IS NULL THEN 3 ELSE 2
            END AS id_operacion,
            CONVERT(VARCHAR(64), d.id_producto_servicio)
                AS id_producto_servicio_anterior,
            CONVERT(VARCHAR(64), i.id_producto_servicio)
                AS id_producto_servicio_nuevo,
            CONVERT(VARCHAR(64), d.id_descripcion) AS id_descripcion_anterior,
            CONVERT(VARCHAR(64), i.id_descripcion) AS id_descripcion_nuevo,
            CONVERT(VARCHAR(64), d.cantidad) AS cantidad_anterior,
            CONVERT(VARCHAR(64), i.cantidad) AS cantidad_nuevo,
            CONVERT(VARCHAR(64), d.precio_unitario)
                AS precio_unitario_anterior,
            CONVERT(VARCHAR(64), i.precio_unitario) AS precio_unitario_nuevo,
            CONVERT(VARCHAR(64), d.porcentaje_impuesto)
                AS porcentaje_impuesto_anterior,
            CONVERT(VARCHAR(64), i.porcentaje_impuesto)
                AS porcentaje_impuesto_nuevo,
            CONVERT(VARCHAR(64), d.monto_descuento)
                AS monto_descuento_anterior,
            CONVERT(VARCHAR(64), i.monto_descuento) AS monto_descuento_nuevo,
            CONVERT(VARCHAR(64), d.subtotal_linea) AS subtotal_linea_anterior,
            CONVERT(VARCHAR(64), i.subtotal_linea) AS subtotal_linea_nuevo,
            CONVERT(VARCHAR(64), d.monto_impuesto) AS monto_impuesto_anterior,
            CONVERT(VARCHAR(64), i.monto_impuesto) AS monto_impuesto_nuevo,
            CONVERT(VARCHAR(64), d.monto_total_linea)
                AS monto_total_linea_anterior,
            CONVERT(VARCHAR(64), i.monto_total_linea)
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

        DECLARE @linea SMALLINT;
        DECLARE @eventos TABLE (
            id_evento BIGINT NOT NULL,
            id_factura BIGINT NOT NULL PRIMARY KEY
        );
        DECLARE detalle_cursor CURSOR LOCAL FAST_FORWARD FOR
        SELECT DISTINCT numero_linea FROM @cambios;
        OPEN detalle_cursor;
        FETCH NEXT FROM detalle_cursor INTO @linea;
        WHILE @@FETCH_STATUS = 0
            BEGIN
                DELETE FROM @eventos;
                INSERT INTO dbo.auditoria_evento (
                    id_entidad, id_registro_principal, id_operacion,
                    id_usuario, fecha_hora_cambio
                )
                OUTPUT INSERTED.id_evento, INSERTED.id_registro_principal
                INTO @eventos
                SELECT DISTINCT
                    2 AS id_entidad,
                    c.id_registro,
                    c.id_operacion,
                    @id_usuario AS id_usuario,
                    @fecha AS fecha_hora_cambio
                FROM @cambios AS c
                WHERE c.numero_linea = @linea;

                INSERT INTO dbo.auditoria_evento_detalle (
                    id_evento, numero_linea
                )
                SELECT
                    id_evento,
                    @linea AS numero_linea
                FROM @eventos;

                INSERT INTO dbo.auditoria_valor
                (id_evento, id_campo, id_momento, valor)
                SELECT
                    e.id_evento,
                    a.id_campo,
                    1 AS id_momento,
                    c.anterior
                FROM @cambios AS c
                INNER JOIN @eventos AS e ON c.id_registro = e.id_factura
                INNER JOIN dbo.campo_auditoria AS a
                    ON a.id_entidad = 2 AND c.campo = a.nombre
                WHERE c.numero_linea = @linea AND c.anterior IS NOT NULL
                UNION ALL
                SELECT
                    e.id_evento,
                    a.id_campo,
                    2 AS id_momento,
                    c.nuevo
                FROM @cambios AS c
                INNER JOIN @eventos AS e ON c.id_registro = e.id_factura
                INNER JOIN dbo.campo_auditoria AS a
                    ON a.id_entidad = 2 AND c.campo = a.nombre
                WHERE c.numero_linea = @linea AND c.nuevo IS NOT NULL;

                FETCH NEXT FROM detalle_cursor INTO @linea;
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
