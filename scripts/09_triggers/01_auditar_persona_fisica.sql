USE facturacion;
GO

CREATE OR ALTER TRIGGER dbo.auditar_persona_fisica
ON dbo.persona_fisica
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
            COALESCE(i.id_cliente, d.id_cliente) AS id_registro,
            CASE
                WHEN d.id_cliente IS NULL THEN 1
                WHEN i.id_cliente IS NULL THEN 3 ELSE 2
            END AS id_operacion,
            CONVERT(VARCHAR(4000), d.nombre_persona) AS nombre_persona_anterior,
            CONVERT(VARCHAR(4000), i.nombre_persona) AS nombre_persona_nuevo,
            CONVERT(VARCHAR(4000), d.primer_apellido)
                AS primer_apellido_anterior,
            CONVERT(VARCHAR(4000), i.primer_apellido) AS primer_apellido_nuevo,
            CONVERT(VARCHAR(4000), d.segundo_apellido)
                AS segundo_apellido_anterior,
            CONVERT(VARCHAR(4000), i.segundo_apellido) AS segundo_apellido_nuevo
        FROM inserted AS i
        FULL OUTER JOIN deleted AS d ON i.id_cliente = d.id_cliente
    ),

    valores AS (
        SELECT
            id_registro,
            id_operacion,
            'nombre_persona' AS campo,
            nombre_persona_anterior AS anterior,
            nombre_persona_nuevo AS nuevo
        FROM registros
        UNION ALL
        SELECT
            id_registro,
            id_operacion,
            'primer_apellido' AS campo,
            primer_apellido_anterior AS anterior,
            primer_apellido_nuevo AS nuevo
        FROM registros
        UNION ALL
        SELECT
            id_registro,
            id_operacion,
            'segundo_apellido' AS campo,
            segundo_apellido_anterior AS anterior,
            segundo_apellido_nuevo AS nuevo
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
            8 AS id_entidad,
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
            ON a.id_entidad = 8 AND c.campo = a.nombre
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
            ON a.id_entidad = 8 AND c.campo = a.nombre
        WHERE c.nuevo IS NOT NULL;

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF XACT_STATE() <> 0 ROLLBACK TRANSACTION;
        DECLARE @mensaje VARCHAR(2048) = ERROR_MESSAGE();
        RAISERROR ('Error al auditar persona_fisica: %s', 16, 1, @mensaje);
    END CATCH;
END;
GO
