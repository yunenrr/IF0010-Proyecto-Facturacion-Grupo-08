USE facturacion;
GO

CREATE OR ALTER TRIGGER dbo.auditar_factura
ON dbo.factura
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
                    id_evento BIGINT NOT NULL,
                    id_registro BIGINT NOT NULL PRIMARY KEY
                );
                SELECT
                    id_factura,
                    identificador_comprobante,
                    id_empresa,
                    id_cliente,
                    id_tipo_documento,
                    id_moneda,
                    id_estado,
                    fecha_emision,
                    subtotal,
                    total_descuentos,
                    total_impuestos,
                    monto_total,
                    fecha_creacion,
                    fecha_modificacion
                INTO #facturas_insertadas FROM inserted;
                CREATE UNIQUE CLUSTERED INDEX ix_facturas_insertadas
                    ON #facturas_insertadas (id_factura);
                INSERT INTO dbo.auditoria_evento (
                    id_entidad, id_registro_principal, id_operacion,
                    id_usuario, fecha_hora_cambio
                )
                OUTPUT INSERTED.id_evento, INSERTED.id_registro_principal
                INTO #eventos_insert
                SELECT
                    1 AS id_entidad,
                    i.id_factura,
                    1 AS id_operacion,
                    @usuario_insert AS id_usuario,
                    @fecha_insert AS fecha_hora_cambio
                FROM #facturas_insertadas AS i;
                WITH valores_insert AS (
                    SELECT i.id_factura, v.campo, v.valor
                    FROM #facturas_insertadas AS i
                    CROSS APPLY (
                        VALUES
                            (
                                'identificador_comprobante',
                                CONVERT(
                                    VARCHAR(64), i.identificador_comprobante
                                )
                            ),
                            ('id_empresa', CONVERT(VARCHAR(64), i.id_empresa)),
                            ('id_cliente', CONVERT(VARCHAR(64), i.id_cliente)),
                            (
                                'id_tipo_documento',
                                CONVERT(VARCHAR(64), i.id_tipo_documento)
                            ),
                            ('id_moneda', CONVERT(VARCHAR(64), i.id_moneda)),
                            ('id_estado', CONVERT(VARCHAR(64), i.id_estado)),
                            (
                                'fecha_emision',
                                CONVERT(VARCHAR(64), i.fecha_emision, 126)
                            ),
                            ('subtotal', CONVERT(VARCHAR(64), i.subtotal)),
                            (
                                'total_descuentos',
                                CONVERT(VARCHAR(64), i.total_descuentos)
                            ),
                            (
                                'total_impuestos',
                                CONVERT(VARCHAR(64), i.total_impuestos)
                            ),
                            (
                                'monto_total',
                                CONVERT(VARCHAR(64), i.monto_total)
                            ),
                            (
                                'fecha_creacion',
                                CONVERT(VARCHAR(64), i.fecha_creacion, 126)
                            ),
                            (
                                'fecha_modificacion',
                                CONVERT(VARCHAR(64), i.fecha_modificacion, 126)
                            )
                    ) AS v(campo, valor)
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
                INNER JOIN #eventos_insert AS e ON v.id_factura = e.id_registro
                INNER JOIN dbo.campo_auditoria AS a
                    ON a.id_entidad = 1 AND v.campo = a.nombre
                ORDER BY e.id_evento, a.id_campo;
                COMMIT TRANSACTION;
            END TRY
            BEGIN CATCH
                IF XACT_STATE() <> 0 ROLLBACK TRANSACTION;
                DECLARE @error_insert VARCHAR(2048) = ERROR_MESSAGE();
                RAISERROR (
                    'Error al auditar factura: %s', 16, 1, @error_insert
                );
            END CATCH;
            RETURN;
        END;

    CREATE TABLE #cambios
        (
            id_registro BIGINT NOT NULL,
            id_operacion INT NOT NULL,
            campo VARCHAR(64) COLLATE DATABASE_DEFAULT NOT NULL,
            anterior VARCHAR(64) COLLATE DATABASE_DEFAULT NULL,
            nuevo VARCHAR(64) COLLATE DATABASE_DEFAULT NULL,
            PRIMARY KEY (id_registro, campo)
        );

    WITH registros AS (
        SELECT
            COALESCE(i.id_factura, d.id_factura) AS id_registro,
            CASE
                WHEN d.id_factura IS NULL THEN 1
                WHEN i.id_factura IS NULL THEN 3 ELSE 2
            END AS id_operacion,
            CONVERT(VARCHAR(64), d.identificador_comprobante)
                AS identificador_comprobante_anterior,
            CONVERT(VARCHAR(64), i.identificador_comprobante)
                AS identificador_comprobante_nuevo,
            CONVERT(VARCHAR(64), d.id_empresa) AS id_empresa_anterior,
            CONVERT(VARCHAR(64), i.id_empresa) AS id_empresa_nuevo,
            CONVERT(VARCHAR(64), d.id_cliente) AS id_cliente_anterior,
            CONVERT(VARCHAR(64), i.id_cliente) AS id_cliente_nuevo,
            CONVERT(VARCHAR(64), d.id_tipo_documento)
                AS id_tipo_documento_anterior,
            CONVERT(VARCHAR(64), i.id_tipo_documento)
                AS id_tipo_documento_nuevo,
            CONVERT(VARCHAR(64), d.id_moneda) AS id_moneda_anterior,
            CONVERT(VARCHAR(64), i.id_moneda) AS id_moneda_nuevo,
            CONVERT(VARCHAR(64), d.id_estado) AS id_estado_anterior,
            CONVERT(VARCHAR(64), i.id_estado) AS id_estado_nuevo,
            CONVERT(VARCHAR(64), d.fecha_emision, 126)
                AS fecha_emision_anterior,
            CONVERT(VARCHAR(64), i.fecha_emision, 126) AS fecha_emision_nuevo,
            CONVERT(VARCHAR(64), d.subtotal) AS subtotal_anterior,
            CONVERT(VARCHAR(64), i.subtotal) AS subtotal_nuevo,
            CONVERT(VARCHAR(64), d.total_descuentos)
                AS total_descuentos_anterior,
            CONVERT(VARCHAR(64), i.total_descuentos)
                AS total_descuentos_nuevo,
            CONVERT(VARCHAR(64), d.total_impuestos)
                AS total_impuestos_anterior,
            CONVERT(VARCHAR(64), i.total_impuestos) AS total_impuestos_nuevo,
            CONVERT(VARCHAR(64), d.monto_total) AS monto_total_anterior,
            CONVERT(VARCHAR(64), i.monto_total) AS monto_total_nuevo,
            CONVERT(VARCHAR(64), d.fecha_creacion, 126)
                AS fecha_creacion_anterior,
            CONVERT(VARCHAR(64), i.fecha_creacion, 126)
                AS fecha_creacion_nuevo,
            CONVERT(VARCHAR(64), d.fecha_modificacion, 126)
                AS fecha_modificacion_anterior,
            CONVERT(VARCHAR(64), i.fecha_modificacion, 126)
                AS fecha_modificacion_nuevo
        FROM inserted AS i
        FULL OUTER JOIN deleted AS d ON i.id_factura = d.id_factura
    ),

    valores AS (
        SELECT
            r.id_registro,
            r.id_operacion,
            v.campo,
            v.anterior,
            v.nuevo
        FROM registros AS r
        CROSS APPLY (
            VALUES
                (
                    'identificador_comprobante',
                    r.identificador_comprobante_anterior,
                    r.identificador_comprobante_nuevo
                ),
                ('id_empresa', r.id_empresa_anterior, r.id_empresa_nuevo),
                ('id_cliente', r.id_cliente_anterior, r.id_cliente_nuevo),
                (
                    'id_tipo_documento',
                    r.id_tipo_documento_anterior,
                    r.id_tipo_documento_nuevo
                ),
                ('id_moneda', r.id_moneda_anterior, r.id_moneda_nuevo),
                ('id_estado', r.id_estado_anterior, r.id_estado_nuevo),
                (
                    'fecha_emision',
                    r.fecha_emision_anterior,
                    r.fecha_emision_nuevo
                ),
                ('subtotal', r.subtotal_anterior, r.subtotal_nuevo),
                (
                    'total_descuentos',
                    r.total_descuentos_anterior,
                    r.total_descuentos_nuevo
                ),
                (
                    'total_impuestos',
                    r.total_impuestos_anterior,
                    r.total_impuestos_nuevo
                ),
                ('monto_total', r.monto_total_anterior, r.monto_total_nuevo),
                (
                    'fecha_creacion',
                    r.fecha_creacion_anterior,
                    r.fecha_creacion_nuevo
                ),
                (
                    'fecha_modificacion',
                    r.fecha_modificacion_anterior,
                    r.fecha_modificacion_nuevo
                )
        ) AS v(campo, anterior, nuevo)
    )

    INSERT INTO #cambios (id_registro, id_operacion, campo, anterior, nuevo)
    SELECT
        v.id_registro,
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

        CREATE TABLE #eventos
            (
                id_evento BIGINT NOT NULL,
                id_registro BIGINT NOT NULL PRIMARY KEY
            );
        INSERT INTO dbo.auditoria_evento
        (
            id_entidad, id_registro_principal, id_operacion,
            id_usuario, fecha_hora_cambio
        )
        OUTPUT INSERTED.id_evento, INSERTED.id_registro_principal
        INTO #eventos
        SELECT DISTINCT
            1 AS id_entidad,
            c.id_registro,
            c.id_operacion,
            @id_usuario AS id_usuario,
            @fecha AS fecha_hora_cambio
        FROM #cambios AS c;

        INSERT INTO dbo.auditoria_valor
        (id_evento, id_campo, id_momento, valor)
        SELECT
            e.id_evento,
            a.id_campo,
            1 AS id_momento,
            c.anterior
        FROM #cambios AS c
        INNER JOIN #eventos AS e ON c.id_registro = e.id_registro
        INNER JOIN dbo.campo_auditoria AS a
            ON a.id_entidad = 1 AND c.campo = a.nombre
        WHERE c.anterior IS NOT NULL
        UNION ALL
        SELECT
            e.id_evento,
            a.id_campo,
            2 AS id_momento,
            c.nuevo
        FROM #cambios AS c
        INNER JOIN #eventos AS e ON c.id_registro = e.id_registro
        INNER JOIN dbo.campo_auditoria AS a
            ON a.id_entidad = 1 AND c.campo = a.nombre
        WHERE c.nuevo IS NOT NULL;

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF XACT_STATE() <> 0 ROLLBACK TRANSACTION;
        DECLARE @mensaje VARCHAR(2048) = ERROR_MESSAGE();
        RAISERROR ('Error al auditar factura: %s', 16, 1, @mensaje);
    END CATCH;
END;
GO
