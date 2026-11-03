USE facturacion;
GO

CREATE OR ALTER TRIGGER dbo.auditar_detalle_factura
ON dbo.detalle_factura
AFTER INSERT, UPDATE, DELETE
AS
BEGIN
    SET NOCOUNT ON;
    -- Audita INSERT, UPDATE y DELETE, incluidas sentencias de varias filas.

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
                    id_evento BIGINT NOT NULL PRIMARY KEY,
                    id_registro BIGINT NOT NULL
                );
                -- Resolver el catalogo una vez por sentencia.
                SELECT
                    a.id_campo,
                    c.posicion
                INTO #campos_insert
                FROM dbo.campo_auditoria AS a
                INNER JOIN (
                    VALUES
                    (1, 'id_producto_servicio'),
                    (2, 'id_descripcion'),
                    (3, 'cantidad'),
                    (4, 'precio_unitario'),
                    (5, 'porcentaje_impuesto'),
                    (6, 'monto_descuento'),
                    (7, 'subtotal_linea'),
                    (8, 'monto_impuesto'),
                    (9, 'monto_total_linea')
                ) AS c (posicion, nombre) ON a.nombre = c.nombre
                WHERE a.id_entidad = 2;
                CREATE UNIQUE CLUSTERED INDEX ix_campos_insert
                    ON #campos_insert (id_campo);
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
                        -- Eventos y campos en orden de clave agrupada.
                        INSERT INTO dbo.auditoria_valor WITH (TABLOCK) (
                            id_evento, id_campo, id_momento, valor
                        )
                        SELECT
                            e.id_evento,
                            c.id_campo,
                            2 AS id_momento,
                            CASE c.posicion
                                WHEN
                                    1
                                    THEN
                                        CONVERT(
                                            VARCHAR(64), i.id_producto_servicio
                                        )
                                WHEN
                                    2
                                    THEN CONVERT(VARCHAR(64), i.id_descripcion)
                                WHEN 3 THEN CONVERT(VARCHAR(64), i.cantidad)
                                WHEN
                                    4
                                    THEN CONVERT(VARCHAR(64), i.precio_unitario)
                                WHEN
                                    5
                                    THEN
                                        CONVERT(
                                            VARCHAR(64), i.porcentaje_impuesto
                                        )
                                WHEN
                                    6
                                    THEN CONVERT(VARCHAR(64), i.monto_descuento)
                                WHEN
                                    7
                                    THEN CONVERT(VARCHAR(64), i.subtotal_linea)
                                WHEN
                                    8
                                    THEN CONVERT(VARCHAR(64), i.monto_impuesto)
                                WHEN
                                    9
                                    THEN
                                        CONVERT(
                                            VARCHAR(64), i.monto_total_linea
                                        )
                            END AS valor
                        FROM #eventos_insert AS e
                        INNER JOIN #insertados AS i
                            ON
                                e.id_registro = i.id_factura
                                AND i.numero_linea = @linea_insert
                        CROSS JOIN #campos_insert AS c
                        ORDER BY e.id_evento, c.id_campo
                        OPTION (FORCE ORDER, LOOP JOIN, MAXDOP 1);
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

    CREATE TABLE #cambios
    (
        id_registro BIGINT NOT NULL,
        numero_linea SMALLINT NOT NULL,
        id_operacion INT NOT NULL,
        campo VARCHAR(64) COLLATE database_default NOT NULL,
        anterior VARCHAR(64) COLLATE database_default NULL,
        nuevo VARCHAR(64) COLLATE database_default NULL,
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
            r.id_registro,
            r.numero_linea,
            r.id_operacion,
            v.campo,
            v.anterior,
            v.nuevo
        FROM registros AS r
        CROSS APPLY (
            VALUES
            (
                'id_producto_servicio',
                r.id_producto_servicio_anterior,
                r.id_producto_servicio_nuevo
            ),
            (
                'id_descripcion',
                r.id_descripcion_anterior,
                r.id_descripcion_nuevo
            ),
            ('cantidad', r.cantidad_anterior, r.cantidad_nuevo),
            (
                'precio_unitario',
                r.precio_unitario_anterior,
                r.precio_unitario_nuevo
            ),
            (
                'porcentaje_impuesto',
                r.porcentaje_impuesto_anterior,
                r.porcentaje_impuesto_nuevo
            ),
            (
                'monto_descuento',
                r.monto_descuento_anterior,
                r.monto_descuento_nuevo
            ),
            (
                'subtotal_linea',
                r.subtotal_linea_anterior,
                r.subtotal_linea_nuevo
            ),
            (
                'monto_impuesto',
                r.monto_impuesto_anterior,
                r.monto_impuesto_nuevo
            ),
            (
                'monto_total_linea',
                r.monto_total_linea_anterior,
                r.monto_total_linea_nuevo
            )
        ) AS v (campo, anterior, nuevo)
    )

    INSERT INTO #cambios (
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
        CONVERT(VARBINARY(4000), v.anterior)
        <> CONVERT(VARBINARY(4000), v.nuevo)
        OR (v.anterior IS NULL AND v.nuevo IS NOT NULL)
        OR (v.anterior IS NOT NULL AND v.nuevo IS NULL);

    IF NOT EXISTS (SELECT 1 FROM #cambios) RETURN;

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
        CREATE TABLE #eventos (
            id_evento BIGINT NOT NULL,
            id_factura BIGINT NOT NULL PRIMARY KEY
        );
        DECLARE detalle_cursor CURSOR LOCAL FAST_FORWARD FOR
        SELECT DISTINCT numero_linea FROM #cambios;
        OPEN detalle_cursor;
        FETCH NEXT FROM detalle_cursor INTO @linea;
        WHILE @@FETCH_STATUS = 0
            BEGIN
                DELETE FROM #eventos;
                INSERT INTO dbo.auditoria_evento (
                    id_entidad, id_registro_principal, id_operacion,
                    id_usuario, fecha_hora_cambio
                )
                OUTPUT INSERTED.id_evento, INSERTED.id_registro_principal
                INTO #eventos
                SELECT DISTINCT
                    2 AS id_entidad,
                    c.id_registro,
                    c.id_operacion,
                    @id_usuario AS id_usuario,
                    @fecha AS fecha_hora_cambio
                FROM #cambios AS c
                WHERE c.numero_linea = @linea;

                INSERT INTO dbo.auditoria_evento_detalle (
                    id_evento, numero_linea
                )
                SELECT
                    id_evento,
                    @linea AS numero_linea
                FROM #eventos;

                INSERT INTO dbo.auditoria_valor
                (id_evento, id_campo, id_momento, valor)
                SELECT
                    e.id_evento,
                    a.id_campo,
                    1 AS id_momento,
                    c.anterior
                FROM #cambios AS c
                INNER JOIN #eventos AS e ON c.id_registro = e.id_factura
                INNER JOIN dbo.campo_auditoria AS a
                    ON a.id_entidad = 2 AND c.campo = a.nombre
                WHERE c.numero_linea = @linea AND c.anterior IS NOT NULL
                UNION ALL
                SELECT
                    e.id_evento,
                    a.id_campo,
                    2 AS id_momento,
                    c.nuevo
                FROM #cambios AS c
                INNER JOIN #eventos AS e ON c.id_registro = e.id_factura
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
