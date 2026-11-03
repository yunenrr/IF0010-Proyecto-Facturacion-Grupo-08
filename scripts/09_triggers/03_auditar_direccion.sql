USE facturacion;
GO

CREATE OR ALTER TRIGGER dbo.auditar_direccion
ON dbo.direccion
AFTER INSERT, UPDATE, DELETE
AS
BEGIN
    SET NOCOUNT ON;

    CREATE TABLE #cambios
    (
        id_registro BIGINT NOT NULL,
        id_operacion INT NOT NULL,
        campo VARCHAR(128) COLLATE database_default NOT NULL,
        anterior VARCHAR(500) COLLATE database_default NULL,
        nuevo VARCHAR(500) COLLATE database_default NULL,
        PRIMARY KEY (id_registro, campo)
    );

    WITH registros AS (
        SELECT
            COALESCE(i.id_direccion, d.id_direccion) AS id_registro,
            CASE
                WHEN d.id_direccion IS NULL THEN 1
                WHEN i.id_direccion IS NULL THEN 3 ELSE 2
            END AS id_operacion,
            CONVERT(VARCHAR(500), d.id_provincia) AS id_provincia_anterior,
            CONVERT(VARCHAR(500), i.id_provincia) AS id_provincia_nuevo,
            CONVERT(VARCHAR(500), d.id_canton) AS id_canton_anterior,
            CONVERT(VARCHAR(500), i.id_canton) AS id_canton_nuevo,
            CONVERT(VARCHAR(500), d.id_distrito) AS id_distrito_anterior,
            CONVERT(VARCHAR(500), i.id_distrito) AS id_distrito_nuevo,
            CONVERT(VARCHAR(500), d.senas_exactas) AS senas_exactas_anterior,
            CONVERT(VARCHAR(500), i.senas_exactas) AS senas_exactas_nuevo
        FROM inserted AS i
        FULL OUTER JOIN deleted AS d ON i.id_direccion = d.id_direccion
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
                'id_provincia',
                r.id_provincia_anterior,
                r.id_provincia_nuevo
            ),
            ('id_canton', r.id_canton_anterior, r.id_canton_nuevo),
            ('id_distrito', r.id_distrito_anterior, r.id_distrito_nuevo),
            (
                'senas_exactas',
                r.senas_exactas_anterior,
                r.senas_exactas_nuevo
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
            7 AS id_entidad,
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
            ON a.id_entidad = 7 AND c.campo = a.nombre
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
            ON a.id_entidad = 7 AND c.campo = a.nombre
        WHERE c.nuevo IS NOT NULL;

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF XACT_STATE() <> 0 ROLLBACK TRANSACTION;
        DECLARE @mensaje VARCHAR(2048) = ERROR_MESSAGE();
        RAISERROR ('Error al auditar direccion: %s', 16, 1, @mensaje);
    END CATCH;
END;
GO
