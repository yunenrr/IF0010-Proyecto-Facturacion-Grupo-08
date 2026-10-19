USE facturacion;
GO

CREATE OR ALTER PROCEDURE dbo.cargar_empresas_clientes_tmp

    @codigo_error INT OUTPUT,
    @mensaje_error VARCHAR(4000) OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    SET @codigo_error = 0;
    SET @mensaje_error = N'';

    DECLARE @entrada INT = @@TRANCOUNT;
    BEGIN TRY
        IF
            @entrada <> 0
            THROW 51000, 'Ejecute esta carga sin transaccion externa.', 1;
        BEGIN TRANSACTION;
        IF
            EXISTS (SELECT 1 FROM dbo.cliente)
            OR EXISTS (SELECT 1 FROM dbo.empresa_emisora)
            THROW 51001, 'La carga de maestros requiere tablas vacias.', 1;
        IF (SELECT COUNT(*) FROM dbo.distrito) <> 475
            THROW 51001, 'Cargue primero la geografia.', 1;

        DECLARE
            @fecha_inicio DATETIME2(0)
            = DATEADD(YEAR, -1, CAST(SYSDATETIME() AS DATE));

        WITH digito AS (
            SELECT valor
            FROM
                (VALUES (0), (1), (2), (3), (4), (5), (6), (7), (8), (9))
                    AS d (valor)
        )

        SELECT
            a.valor + 10 * b.valor + 100 * c.valor
            + 1000 * d.valor + 10000 * e.valor + 1 AS numero
        INTO #numeros
        FROM digito AS a
        CROSS JOIN digito AS b
        CROSS JOIN digito AS c
        CROSS JOIN digito AS d
        CROSS JOIN digito AS e
        WHERE
            a.valor + 10 * b.valor + 100 * c.valor
            + 1000 * d.valor + 10000 * e.valor < 50000;

        SELECT
            CAST(
                ROW_NUMBER()
                    OVER (ORDER BY id_provincia, id_canton, id_distrito)
                AS INT
            ) AS numero,
            id_provincia,
            id_canton,
            id_distrito
        INTO #geografia
        FROM dbo.distrito;

        SELECT
            v.numero,
            v.texto
        INTO #nombres
        FROM (
            VALUES
            (0, N'Ana'),
            (1, N'María'),
            (2, N'Laura'),
            (3, N'Sofía'),
            (4, N'Valeria'),
            (5, N'Daniela'),
            (6, N'Gabriela'),
            (7, N'Camila'),
            (8, N'Lucía'),
            (9, N'Elena'),
            (10, N'Isabel'),
            (11, N'Adriana'),
            (12, N'Natalia'),
            (13, N'Paola'),
            (14, N'Carolina'),
            (15, N'Verónica'),
            (16, N'Andrea'),
            (17, N'Diana'),
            (18, N'Patricia'),
            (19, N'Mónica'),
            (20, N'Carlos'),
            (21, N'José'),
            (22, N'Luis'),
            (23, N'Daniel'),
            (24, N'Andrés'),
            (25, N'Jorge'),
            (26, N'Miguel'),
            (27, N'Pablo'),
            (28, N'Diego'),
            (29, N'David'),
            (30, N'Fernando'),
            (31, N'Ricardo'),
            (32, N'Gabriel'),
            (33, N'Alejandro'),
            (34, N'Esteban'),
            (35, N'Sebastián'),
            (36, N'Eduardo'),
            (37, N'Manuel'),
            (38, N'Francisco'),
            (39, N'Roberto')
        ) AS v (numero, texto);

        SELECT
            v.numero,
            v.texto
        INTO #apellidos
        FROM (
            VALUES
            (0, N'Solís'),
            (1, N'Vargas'),
            (2, N'Rodríguez'),
            (3, N'Jiménez'),
            (4, N'Mora'),
            (5, N'Gómez'),
            (6, N'Castro'),
            (7, N'Rojas'),
            (8, N'Hernández'),
            (9, N'López'),
            (10, N'Alvarado'),
            (11, N'Ramírez'),
            (12, N'Chaves'),
            (13, N'Araya'),
            (14, N'Pérez'),
            (15, N'González'),
            (16, N'Sánchez'),
            (17, N'Salazar'),
            (18, N'Quesada'),
            (19, N'Cordero'),
            (20, N'Aguilar'),
            (21, N'Campos'),
            (22, N'Navarro'),
            (23, N'Vega'),
            (24, N'León'),
            (25, N'Méndez'),
            (26, N'Villalobos'),
            (27, N'Arias'),
            (28, N'Calderón'),
            (29, N'Brenes'),
            (30, N'Soto'),
            (31, N'Segura'),
            (32, N'Montero'),
            (33, N'Valverde'),
            (34, N'Pineda'),
            (35, N'Fallas'),
            (36, N'Ureña'),
            (37, N'Esquivel'),
            (38, N'Zamora'),
            (39, N'Acosta')
        ) AS v (numero, texto);

        SELECT
            v.numero,
            v.texto
        INTO #actividades
        FROM (
            VALUES
            (0, N'Distribuidora'),
            (1, N'Comercializadora'),
            (2, N'Importadora'),
            (3, N'Papelería'),
            (4, N'Librería'),
            (5, N'Consultora'),
            (6, N'Proveeduría'),
            (7, N'Suministros'),
            (8, N'Soluciones'),
            (9, N'Equipamientos'),
            (10, N'Almacenes'),
            (11, N'Servicios'),
            (12, N'Inversiones'),
            (13, N'Tecnología'),
            (14, N'Logística'),
            (15, N'Oficinas'),
            (16, N'Impresiones'),
            (17, N'Asesorías'),
            (18, N'Diseños'),
            (19, N'Comunicaciones')
        ) AS v (numero, texto);

        SELECT
            v.numero,
            v.texto
        INTO #marcas
        FROM (
            VALUES
            (0, N'Alborada'),
            (1, N'Horizonte'),
            (2, N'Cedral'),
            (3, N'Mirador'),
            (4, N'Azahar'),
            (5, N'Laurel'),
            (6, N'Bambú'),
            (7, N'Encina'),
            (8, N'Roble'),
            (9, N'Brisa'),
            (10, N'Aurora'),
            (11, N'Ciprés'),
            (12, N'Ladera'),
            (13, N'Cumbre'),
            (14, N'Sendero'),
            (15, N'Estrella'),
            (16, N'Luciérnaga'),
            (17, N'Mariposa'),
            (18, N'Quetzal'),
            (19, N'Colibrí')
        ) AS v (numero, texto);

        SELECT
            v.numero,
            v.texto
        INTO #lugares
        FROM (
            VALUES
            (0, N'del Valle'),
            (1, N'del Norte'),
            (2, N'del Sur'),
            (3, N'del Este'),
            (4, N'del Oeste'),
            (5, N'del Pacífico'),
            (6, N'del Caribe'),
            (7, N'de la Montaña'),
            (8, N'del Bosque'),
            (9, N'de la Ribera'),
            (10, N'del Jardín'),
            (11, N'del Prado'),
            (12, N'de la Sabana'),
            (13, N'de la Colina'),
            (14, N'de la Arboleda'),
            (15, N'de la Alameda'),
            (16, N'del Portal'),
            (17, N'de la Campiña'),
            (18, N'de la Sierra'),
            (19, N'de la Llanura'),
            (20, N'del Encanto'),
            (21, N'de la Esperanza'),
            (22, N'de la Amistad'),
            (23, N'del Progreso'),
            (24, N'de la Concordia')
        ) AS v (numero, texto);

        SELECT
            v.numero,
            v.texto
        INTO #calles
        FROM (
            VALUES
            (0, N'Los Cedros'),
            (1, N'Las Palmas'),
            (2, N'Los Robles'),
            (3, N'Las Flores'),
            (4, N'Los Pinos'),
            (5, N'Las Acacias'),
            (6, N'Los Laureles'),
            (7, N'Los Cipreses'),
            (8, N'Los Mangos'),
            (9, N'Las Orquídeas')
        ) AS v (numero, texto);

        SELECT
            v.numero,
            v.texto
        INTO #referencias
        FROM (
            VALUES
            (0, N'parque central'),
            (1, N'escuela del distrito'),
            (2, N'salón comunal'),
            (3, N'plaza de deportes'),
            (4, N'biblioteca pública'),
            (5, N'oficina de correos'),
            (6, N'mercado municipal'),
            (7, N'centro cultural'),
            (8, N'estación de autobuses'),
            (9, N'centro de salud')
        ) AS v (numero, texto);

        SELECT
            n.numero,
            CONCAT(a.texto, N' ', m.texto) AS nombre_comercial,
            CONCAT(a.texto, N' ', m.texto, N' S.A.') AS razon_social,
            CONCAT(
                N'Avenida ', c.texto, N', local ', n.numero,
                N', ', 50 * (1 + n.numero % 12), N' metros del ', r.texto,
                N', entrada principal señalizada.'
            ) AS senas_exactas
        INTO #semilla_empresas
        FROM #numeros AS n
        INNER JOIN #actividades AS a ON a.numero = (n.numero - 1) % 10
        INNER JOIN #marcas AS m ON m.numero = (n.numero - 1) / 10
        INNER JOIN #calles AS c ON c.numero = (n.numero - 1) % 10
        INNER JOIN #referencias AS r ON r.numero = ((n.numero - 1) / 10) % 10
        WHERE n.numero <= 100;

        SELECT
            n.numero,
            CASE
                WHEN n.numero % 5 <> 0
                    THEN CONCAT(np.texto, N' ', ap.texto, N' ', sp.texto)
            END AS nombre_persona,
            CASE
                WHEN n.numero % 5 = 0
                    THEN CONCAT(a.texto, N' ', m.texto, N' ', l.texto, N' S.A.')
            END AS razon_social,
            CONCAT(
                N'Calle ', c.texto, N', ', 25 * (1 + n.numero % 20),
                N' metros ', CASE n.numero % 4
                    WHEN 0 THEN N'al norte'
                    WHEN 1 THEN N'al sur' WHEN 2 THEN N'al este' ELSE
                        N'al oeste'
                END,
                N' del ', r.texto, N', ',
                CASE
                    WHEN n.numero % 5 = 0 THEN N'local comercial ' ELSE N'casa '
                END,
                1 + (n.numero - 1) / 100,
                N', fachada ', CASE (
                    n.numero / 7) % 5
                    WHEN 0 THEN N'azul'
                    WHEN 1 THEN N'blanca' WHEN 2 THEN N'ocre'
                    WHEN 3 THEN N'verde' ELSE N'gris'
                END, N'.'
            ) AS senas_exactas
        INTO #semilla_clientes
        FROM #numeros AS n
        INNER JOIN
            #nombres AS np
            ON np.numero = (n.numero - n.numero / 5 - 1) % 40
        INNER JOIN
            #apellidos AS ap
            ON ap.numero = ((n.numero - n.numero / 5 - 1) / 40) % 40
        INNER JOIN
            #apellidos AS sp
            ON sp.numero = ((n.numero - n.numero / 5 - 1) / 1600) % 25
        INNER JOIN #actividades AS a ON a.numero = ((n.numero - 1) / 5) % 20
        INNER JOIN #marcas AS m ON m.numero = ((n.numero - 1) / 100) % 20
        INNER JOIN #lugares AS l ON l.numero = (n.numero - 1) / 2000
        INNER JOIN #calles AS c ON c.numero = (n.numero - 1) % 10
        INNER JOIN #referencias AS r ON r.numero = ((n.numero - 1) / 10) % 10;

        CREATE TABLE #direcciones
        (
            id_direccion BIGINT NOT NULL,
            senas_exactas VARCHAR(500) COLLATE database_default NOT NULL
        );

        INSERT INTO dbo.direccion
        (id_provincia, id_canton, id_distrito, senas_exactas)
        OUTPUT INSERTED.id_direccion, INSERTED.senas_exactas INTO #direcciones
        SELECT
            g.id_provincia,
            g.id_canton,
            g.id_distrito,
            n.senas_exactas
        FROM #semilla_empresas AS n
        INNER JOIN #geografia AS g ON g.numero = (n.numero * 47) % 475 + 1
        WHERE NOT EXISTS (
            SELECT 1 FROM dbo.empresa_emisora AS e
            WHERE
                e.cedula
                = CAST(3101000000 + CAST(n.numero AS BIGINT) AS VARCHAR(20))
        );

        INSERT INTO dbo.empresa_emisora
        (
            id_direccion, cedula, nombre_comercial, razon_social, telefono,
            correo_electronico, fecha_creacion, activo
        )
        SELECT
            d.id_direccion,
            CAST(3101000000 + CAST(n.numero AS BIGINT) AS VARCHAR(20))
                AS cedula,
            n.nombre_comercial,
            n.razon_social,
            CAST(22000000 + n.numero AS VARCHAR(20)) AS telefono,
            CONCAT('empresa', n.numero, '@example.com') AS correo_electronico,
            @fecha_inicio AS fecha_creacion,
            1 AS activo
        FROM #semilla_empresas AS n
        INNER JOIN #direcciones AS d
            ON n.senas_exactas = d.senas_exactas;

        DELETE FROM #direcciones;

        INSERT INTO dbo.direccion
        (id_provincia, id_canton, id_distrito, senas_exactas)
        OUTPUT INSERTED.id_direccion, INSERTED.senas_exactas INTO #direcciones
        SELECT
            g.id_provincia,
            g.id_canton,
            g.id_distrito,
            n.senas_exactas
        FROM #semilla_clientes AS n
        INNER JOIN #geografia AS g ON g.numero = (n.numero * 37) % 475 + 1
        WHERE NOT EXISTS (
            SELECT 1 FROM dbo.cliente AS c
            WHERE c.cedula = CAST(CASE
                WHEN n.numero % 5 = 0 THEN CAST(3102000000 AS BIGINT)
                ELSE 100000000
            END + n.numero AS VARCHAR(20
            ))
        );

        INSERT INTO dbo.cliente
        (
            id_direccion, cedula, id_tipo_persona,
            telefono,
            correo_electronico,
            fecha_registro,
            fecha_ultima_actualizacion
        )
        SELECT
            d.id_direccion,
            CAST(CASE
                WHEN n.numero % 5 = 0 THEN CAST(3102000000 AS BIGINT)
                ELSE 100000000
            END + n.numero AS VARCHAR(20
            )) AS cedula,
            CASE WHEN n.numero % 5 = 0 THEN 2 ELSE 1 END
                AS id_tipo_persona,
            CAST(80000000 + n.numero AS VARCHAR(20)) AS telefono,
            CONCAT('cliente', n.numero, '@example.com') AS correo_electronico,
            @fecha_inicio AS fecha_registro,
            @fecha_inicio AS fecha_ultima_actualizacion
        FROM #semilla_clientes AS n
        INNER JOIN #direcciones AS d
            ON
                n.senas_exactas
                = d.senas_exactas;

        INSERT INTO dbo.persona_fisica (id_cliente, nombre_persona)
        SELECT
            c.id_cliente,
            n.nombre_persona
        FROM #semilla_clientes AS n
        INNER JOIN
            dbo.cliente AS c
            ON c.cedula = CAST(100000000 + n.numero AS VARCHAR(20))
        WHERE n.numero % 5 <> 0;
        INSERT INTO dbo.persona_juridica (id_cliente, razon_social)
        SELECT
            c.id_cliente,
            n.razon_social
        FROM #semilla_clientes AS n
        INNER JOIN
            dbo.cliente AS c
            ON
                c.cedula
                = CAST(3102000000 + CAST(n.numero AS BIGINT) AS VARCHAR(20))
        WHERE n.numero % 5 = 0;
        DROP TABLE #semilla_empresas;
        DROP TABLE #semilla_clientes;
        DROP TABLE #nombres;
        DROP TABLE #apellidos;
        DROP TABLE #actividades;
        DROP TABLE #marcas;
        DROP TABLE #lugares;
        DROP TABLE #calles;
        DROP TABLE #referencias;
        DROP TABLE #geografia;
        DROP TABLE #direcciones;
        DROP TABLE #numeros;

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        SET @codigo_error = ERROR_NUMBER();
        SET @mensaje_error = ERROR_MESSAGE();

        IF @entrada = 0 AND XACT_STATE() <> 0
            ROLLBACK TRANSACTION;
    END CATCH;
    RETURN @codigo_error;
END;
GO

DECLARE @error INT, @mensaje VARCHAR(4000);
BEGIN TRY
    EXEC dbo.cargar_empresas_clientes_tmp
        @codigo_error = @error OUTPUT, @mensaje_error = @mensaje OUTPUT;
END TRY
BEGIN CATCH
    DROP PROCEDURE dbo.cargar_empresas_clientes_tmp;
    THROW;
END CATCH;
DROP PROCEDURE dbo.cargar_empresas_clientes_tmp;
IF @error <> 0 THROW 51999, @mensaje, 1;
GO
