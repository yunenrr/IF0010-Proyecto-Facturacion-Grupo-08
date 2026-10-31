USE facturacion;
GO

CREATE OR ALTER TRIGGER dbo.auditar_producto_servicio
ON dbo.producto_servicio
AFTER INSERT, UPDATE, DELETE
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE
        @cambios TABLE
        (
            id_registro BIGINT NOT NULL,
            id_operacion INT NOT NULL,
            campo VARCHAR(128) NOT NULL,
            anterior VARCHAR(4000) NULL,
            nuevo VARCHAR(4000) NULL
        );

    WITH registros AS (
        SELECT
            COALESCE(i.id_producto_servicio, d.id_producto_servicio)
                AS id_registro,
            CASE
                WHEN d.id_producto_servicio IS NULL THEN 1
                WHEN i.id_producto_servicio IS NULL THEN 3 ELSE 2
            END AS id_operacion,
            CONVERT(VARCHAR(4000), d.id_tipo_articulo)
                AS id_tipo_articulo_anterior,
            CONVERT(VARCHAR(4000), i.id_tipo_articulo)
                AS id_tipo_articulo_nuevo,
            CONVERT(VARCHAR(4000), d.codigo_interno) AS codigo_interno_anterior,
            CONVERT(VARCHAR(4000), i.codigo_interno) AS codigo_interno_nuevo,
            CONVERT(VARCHAR(4000), d.id_descripcion) AS id_descripcion_anterior,
            CONVERT(VARCHAR(4000), i.id_descripcion) AS id_descripcion_nuevo,
            CONVERT(VARCHAR(4000), d.precio_unitario_lista)
                AS precio_unitario_lista_anterior,
            CONVERT(VARCHAR(4000), i.precio_unitario_lista)
                AS precio_unitario_lista_nuevo,
            CONVERT(VARCHAR(4000), d.porcentaje_impuesto)
                AS porcentaje_impuesto_anterior,
            CONVERT(VARCHAR(4000), i.porcentaje_impuesto)
                AS porcentaje_impuesto_nuevo,
            CONVERT(VARCHAR(4000), d.activo) AS activo_anterior,
            CONVERT(VARCHAR(4000), i.activo) AS activo_nuevo,
            CONVERT(VARCHAR(4000), d.fecha_creacion, 126)
                AS fecha_creacion_anterior,
            CONVERT(VARCHAR(4000), i.fecha_creacion, 126)
                AS fecha_creacion_nuevo
        FROM inserted AS i
        FULL OUTER JOIN
            deleted AS d
            ON i.id_producto_servicio = d.id_producto_servicio
    ),

    valores AS (
        SELECT
            id_registro,
            id_operacion,
            'id_tipo_articulo' AS campo,
            id_tipo_articulo_anterior AS anterior,
            id_tipo_articulo_nuevo AS nuevo
        FROM registros
        UNION ALL
        SELECT
            id_registro,
            id_operacion,
            'codigo_interno' AS campo,
            codigo_interno_anterior AS anterior,
            codigo_interno_nuevo AS nuevo
        FROM registros
        UNION ALL
        SELECT
            id_registro,
            id_operacion,
            'id_descripcion' AS campo,
            id_descripcion_anterior AS anterior,
            id_descripcion_nuevo AS nuevo
        FROM registros
        UNION ALL
        SELECT
            id_registro,
            id_operacion,
            'precio_unitario_lista' AS campo,
            precio_unitario_lista_anterior AS anterior,
            precio_unitario_lista_nuevo AS nuevo
        FROM registros
        UNION ALL
        SELECT
            id_registro,
            id_operacion,
            'porcentaje_impuesto' AS campo,
            porcentaje_impuesto_anterior AS anterior,
            porcentaje_impuesto_nuevo AS nuevo
        FROM registros
        UNION ALL
        SELECT
            id_registro,
            id_operacion,
            'activo' AS campo,
            activo_anterior AS anterior,
            activo_nuevo AS nuevo
        FROM registros
        UNION ALL
        SELECT
            id_registro,
            id_operacion,
            'fecha_creacion' AS campo,
            fecha_creacion_anterior AS anterior,
            fecha_creacion_nuevo AS nuevo
        FROM registros
    )

    INSERT INTO @cambios (id_registro, id_operacion, campo, anterior, nuevo)
    SELECT
        v.id_registro,
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

        DECLARE
            @eventos TABLE
            (
                id_evento BIGINT NOT NULL,
                id_registro BIGINT NOT NULL
            );
        INSERT INTO dbo.auditoria_evento
        (
            id_entidad, id_registro_principal, id_operacion,
            id_usuario, fecha_hora_cambio
        )
        OUTPUT INSERTED.id_evento, INSERTED.id_registro_principal
        INTO @eventos
        SELECT DISTINCT
            4 AS id_entidad,
            c.id_registro,
            c.id_operacion,
            @id_usuario AS id_usuario,
            @fecha AS fecha_hora_cambio
        FROM @cambios AS c;

        INSERT INTO dbo.auditoria_valor
        (id_evento, id_campo, id_momento, valor)
        SELECT
            e.id_evento,
            a.id_campo,
            1 AS id_momento,
            c.anterior
        FROM @cambios AS c
        INNER JOIN @eventos AS e ON c.id_registro = e.id_registro
        INNER JOIN dbo.campo_auditoria AS a
            ON a.id_entidad = 4 AND c.campo = a.nombre
        WHERE c.anterior IS NOT NULL
        UNION ALL
        SELECT
            e.id_evento,
            a.id_campo,
            2 AS id_momento,
            c.nuevo
        FROM @cambios AS c
        INNER JOIN @eventos AS e ON c.id_registro = e.id_registro
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
