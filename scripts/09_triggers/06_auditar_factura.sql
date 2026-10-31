USE facturacion;
GO

CREATE OR ALTER TRIGGER dbo.auditar_factura
ON dbo.factura
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
            COALESCE(i.id_factura, d.id_factura) AS id_registro,
            CASE
                WHEN d.id_factura IS NULL THEN 1
                WHEN i.id_factura IS NULL THEN 3 ELSE 2
            END AS id_operacion,
            CONVERT(VARCHAR(4000), d.identificador_comprobante)
                AS identificador_comprobante_anterior,
            CONVERT(VARCHAR(4000), i.identificador_comprobante)
                AS identificador_comprobante_nuevo,
            CONVERT(VARCHAR(4000), d.id_empresa) AS id_empresa_anterior,
            CONVERT(VARCHAR(4000), i.id_empresa) AS id_empresa_nuevo,
            CONVERT(VARCHAR(4000), d.id_cliente) AS id_cliente_anterior,
            CONVERT(VARCHAR(4000), i.id_cliente) AS id_cliente_nuevo,
            CONVERT(VARCHAR(4000), d.id_tipo_documento)
                AS id_tipo_documento_anterior,
            CONVERT(VARCHAR(4000), i.id_tipo_documento)
                AS id_tipo_documento_nuevo,
            CONVERT(VARCHAR(4000), d.id_moneda) AS id_moneda_anterior,
            CONVERT(VARCHAR(4000), i.id_moneda) AS id_moneda_nuevo,
            CONVERT(VARCHAR(4000), d.id_estado) AS id_estado_anterior,
            CONVERT(VARCHAR(4000), i.id_estado) AS id_estado_nuevo,
            CONVERT(VARCHAR(4000), d.fecha_emision, 126)
                AS fecha_emision_anterior,
            CONVERT(VARCHAR(4000), i.fecha_emision, 126) AS fecha_emision_nuevo,
            CONVERT(VARCHAR(4000), d.subtotal) AS subtotal_anterior,
            CONVERT(VARCHAR(4000), i.subtotal) AS subtotal_nuevo,
            CONVERT(VARCHAR(4000), d.total_descuentos)
                AS total_descuentos_anterior,
            CONVERT(VARCHAR(4000), i.total_descuentos)
                AS total_descuentos_nuevo,
            CONVERT(VARCHAR(4000), d.total_impuestos)
                AS total_impuestos_anterior,
            CONVERT(VARCHAR(4000), i.total_impuestos) AS total_impuestos_nuevo,
            CONVERT(VARCHAR(4000), d.monto_total) AS monto_total_anterior,
            CONVERT(VARCHAR(4000), i.monto_total) AS monto_total_nuevo,
            CONVERT(VARCHAR(4000), d.fecha_creacion, 126)
                AS fecha_creacion_anterior,
            CONVERT(VARCHAR(4000), i.fecha_creacion, 126)
                AS fecha_creacion_nuevo,
            CONVERT(VARCHAR(4000), d.fecha_modificacion, 126)
                AS fecha_modificacion_anterior,
            CONVERT(VARCHAR(4000), i.fecha_modificacion, 126)
                AS fecha_modificacion_nuevo
        FROM inserted AS i
        FULL OUTER JOIN deleted AS d ON i.id_factura = d.id_factura
    ),

    valores AS (
        SELECT
            id_registro,
            id_operacion,
            'identificador_comprobante' AS campo,
            identificador_comprobante_anterior AS anterior,
            identificador_comprobante_nuevo AS nuevo
        FROM registros
        UNION ALL
        SELECT
            id_registro,
            id_operacion,
            'id_empresa' AS campo,
            id_empresa_anterior AS anterior,
            id_empresa_nuevo AS nuevo
        FROM registros
        UNION ALL
        SELECT
            id_registro,
            id_operacion,
            'id_cliente' AS campo,
            id_cliente_anterior AS anterior,
            id_cliente_nuevo AS nuevo
        FROM registros
        UNION ALL
        SELECT
            id_registro,
            id_operacion,
            'id_tipo_documento' AS campo,
            id_tipo_documento_anterior AS anterior,
            id_tipo_documento_nuevo AS nuevo
        FROM registros
        UNION ALL
        SELECT
            id_registro,
            id_operacion,
            'id_moneda' AS campo,
            id_moneda_anterior AS anterior,
            id_moneda_nuevo AS nuevo
        FROM registros
        UNION ALL
        SELECT
            id_registro,
            id_operacion,
            'id_estado' AS campo,
            id_estado_anterior AS anterior,
            id_estado_nuevo AS nuevo
        FROM registros
        UNION ALL
        SELECT
            id_registro,
            id_operacion,
            'fecha_emision' AS campo,
            fecha_emision_anterior AS anterior,
            fecha_emision_nuevo AS nuevo
        FROM registros
        UNION ALL
        SELECT
            id_registro,
            id_operacion,
            'subtotal' AS campo,
            subtotal_anterior AS anterior,
            subtotal_nuevo AS nuevo
        FROM registros
        UNION ALL
        SELECT
            id_registro,
            id_operacion,
            'total_descuentos' AS campo,
            total_descuentos_anterior AS anterior,
            total_descuentos_nuevo AS nuevo
        FROM registros
        UNION ALL
        SELECT
            id_registro,
            id_operacion,
            'total_impuestos' AS campo,
            total_impuestos_anterior AS anterior,
            total_impuestos_nuevo AS nuevo
        FROM registros
        UNION ALL
        SELECT
            id_registro,
            id_operacion,
            'monto_total' AS campo,
            monto_total_anterior AS anterior,
            monto_total_nuevo AS nuevo
        FROM registros
        UNION ALL
        SELECT
            id_registro,
            id_operacion,
            'fecha_creacion' AS campo,
            fecha_creacion_anterior AS anterior,
            fecha_creacion_nuevo AS nuevo
        FROM registros
        UNION ALL
        SELECT
            id_registro,
            id_operacion,
            'fecha_modificacion' AS campo,
            fecha_modificacion_anterior AS anterior,
            fecha_modificacion_nuevo AS nuevo
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
            1 AS id_entidad,
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
            ON a.id_entidad = 1 AND c.campo = a.nombre
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
