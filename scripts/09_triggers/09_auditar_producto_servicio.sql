USE facturacion;
GO

CREATE OR ALTER TRIGGER dbo.auditar_producto_servicio
ON dbo.producto_servicio
AFTER INSERT, UPDATE, DELETE
AS
BEGIN
    SET NOCOUNT ON;
    -- Audita INSERT, UPDATE y DELETE, incluidas sentencias de varias filas.

    CREATE TABLE #cambios
    (
        id_registro BIGINT NOT NULL,
        id_operacion INT NOT NULL,
        campo VARCHAR(128) COLLATE database_default NOT NULL,
        anterior VARCHAR(64) COLLATE database_default NULL,
        nuevo VARCHAR(64) COLLATE database_default NULL,
        PRIMARY KEY (id_registro, campo)
    );

    WITH registros AS (
        SELECT
            COALESCE(i.id_producto_servicio, d.id_producto_servicio)
                AS id_registro,
            CASE
                WHEN d.id_producto_servicio IS NULL THEN 1
                WHEN i.id_producto_servicio IS NULL THEN 3 ELSE 2
            END AS id_operacion,
            CONVERT(VARCHAR(64), d.id_tipo_articulo)
                AS id_tipo_articulo_anterior,
            CONVERT(VARCHAR(64), i.id_tipo_articulo)
                AS id_tipo_articulo_nuevo,
            CONVERT(VARCHAR(64), d.codigo_interno) AS codigo_interno_anterior,
            CONVERT(VARCHAR(64), i.codigo_interno) AS codigo_interno_nuevo,
            CONVERT(VARCHAR(64), d.id_descripcion) AS id_descripcion_anterior,
            CONVERT(VARCHAR(64), i.id_descripcion) AS id_descripcion_nuevo,
            CONVERT(VARCHAR(64), d.precio_unitario_lista)
                AS precio_unitario_lista_anterior,
            CONVERT(VARCHAR(64), i.precio_unitario_lista)
                AS precio_unitario_lista_nuevo,
            CONVERT(VARCHAR(64), d.porcentaje_impuesto)
                AS porcentaje_impuesto_anterior,
            CONVERT(VARCHAR(64), i.porcentaje_impuesto)
                AS porcentaje_impuesto_nuevo,
            CONVERT(VARCHAR(64), d.activo) AS activo_anterior,
            CONVERT(VARCHAR(64), i.activo) AS activo_nuevo,
            CONVERT(VARCHAR(64), d.fecha_creacion, 126)
                AS fecha_creacion_anterior,
            CONVERT(VARCHAR(64), i.fecha_creacion, 126)
                AS fecha_creacion_nuevo
        FROM inserted AS i
        FULL OUTER JOIN
            deleted AS d
            ON i.id_producto_servicio = d.id_producto_servicio
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
                'id_tipo_articulo',
                r.id_tipo_articulo_anterior,
                r.id_tipo_articulo_nuevo
            ),
            (
                'codigo_interno',
                r.codigo_interno_anterior,
                r.codigo_interno_nuevo
            ),
            (
                'id_descripcion',
                r.id_descripcion_anterior,
                r.id_descripcion_nuevo
            ),
            (
                'precio_unitario_lista',
                r.precio_unitario_lista_anterior,
                r.precio_unitario_lista_nuevo
            ),
            (
                'porcentaje_impuesto',
                r.porcentaje_impuesto_anterior,
                r.porcentaje_impuesto_nuevo
            ),
            ('activo', r.activo_anterior, r.activo_nuevo),
            (
                'fecha_creacion',
                r.fecha_creacion_anterior,
                r.fecha_creacion_nuevo
            )
        ) AS v (campo, anterior, nuevo)
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
            4 AS id_entidad,
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
            ON a.id_entidad = 4 AND c.campo = a.nombre
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
            ON a.id_entidad = 4 AND c.campo = a.nombre
        WHERE c.nuevo IS NOT NULL;

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF XACT_STATE() <> 0 ROLLBACK TRANSACTION;
        DECLARE @mensaje VARCHAR(2048) = ERROR_MESSAGE();
        RAISERROR ('Error al auditar producto_servicio: %s', 16, 1, @mensaje);
    END CATCH;
END;
GO
