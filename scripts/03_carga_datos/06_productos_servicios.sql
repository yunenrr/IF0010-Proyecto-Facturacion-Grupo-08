USE facturacion;
GO

CREATE OR ALTER PROCEDURE dbo.cargar_productos_servicios_tmp

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
        IF EXISTS (SELECT 1 FROM dbo.producto_servicio)
            THROW 51001, 'La carga de articulos requiere el catalogo vacio.', 1;

        WITH digito AS (
            SELECT valor
            FROM
                (VALUES (0), (1), (2), (3), (4), (5), (6), (7), (8), (9))
                    AS d(valor)
        )

        SELECT
            a.valor + 10 * b.valor + 100 * c.valor
            + 1000 * d.valor + 1 AS numero
        INTO #numeros
        FROM digito AS a
        CROSS JOIN digito AS b
        CROSS JOIN digito AS c
        CROSS JOIN digito AS d
        WHERE
            a.valor + 10 * b.valor + 100 * c.valor
            + 1000 * d.valor < 1100;

        SELECT
            v.numero,
            v.texto
        INTO #tipos_producto
        FROM (
            VALUES
            (0, N'Cuaderno universitario de 100 hojas'),
            (1, N'Bolígrafo de tinta azul'),
            (2, N'Lápiz de grafito HB'),
            (3, N'Borrador de goma blanca'),
            (4, N'Marcador permanente negro'),
            (5, N'Resaltador amarillo'),
            (6, N'Carpeta de cartón tamaño carta'),
            (7, N'Sobre manila tamaño oficio'),
            (8, N'Bloc de notas adhesivas'),
            (9, N'Regla transparente de 30 cm'),
            (10, N'Tijera de oficina de 21 cm'),
            (11, N'Barra adhesiva de 20 g'),
            (12, N'Cinta adhesiva transparente'),
            (13, N'Corrector en cinta de 5 mm'),
            (14, N'Calculadora de escritorio'),
            (15, N'Grapadora metálica'),
            (16, N'Perforadora de dos orificios'),
            (17, N'Archivador de palanca'),
            (18, N'Portadocumentos plástico'),
            (19, N'Bandeja organizadora de escritorio'),
            (20, N'Sujetapapeles metálico de 32 mm'),
            (21, N'Sacapuntas metálico'),
            (22, N'Pincel plano para manualidades'),
            (23, N'Papel fotográfico tamaño carta'),
            (24, N'Cartulina blanca tamaño oficio')
        ) AS v(numero, texto);

        SELECT
            v.numero,
            v.texto
        INTO #marcas
        FROM (
            VALUES
            (0, N'Cedral'),
            (1, N'Alborada'),
            (2, N'Horizonte'),
            (3, N'Azahar')
        ) AS v(numero, texto);

        SELECT
            v.numero,
            v.texto
        INTO #presentaciones
        FROM (
            VALUES
            (0, N'unidad individual'),
            (1, N'paquete de 2 unidades'),
            (2, N'paquete de 3 unidades'),
            (3, N'paquete de 4 unidades'),
            (4, N'paquete de 5 unidades'),
            (5, N'paquete de 6 unidades'),
            (6, N'paquete de 8 unidades'),
            (7, N'paquete de 10 unidades'),
            (8, N'paquete de 12 unidades'),
            (9, N'caja de 24 unidades')
        ) AS v(numero, texto);

        SELECT
            v.numero,
            v.texto
        INTO #tipos_servicio
        FROM (
            VALUES
            (0, N'Configuración de correo empresarial'),
            (1, N'Instalación de software de oficina'),
            (2, N'Capacitación en hojas de cálculo'),
            (3, N'Asesoría en copias de seguridad'),
            (4, N'Configuración de videoconferencias'),
            (5, N'Diseño de plantillas de documentos'),
            (6, N'Organización de archivos digitales'),
            (7, N'Revisión de seguridad de cuentas'),
            (8, N'Configuración de almacenamiento compartido'),
            (9, N'Capacitación en presentaciones'),
            (10, N'Asesoría en gestión documental'),
            (11, N'Configuración de calendarios de trabajo'),
            (12, N'Soporte de aplicaciones de oficina'),
            (13, N'Migración de contactos empresariales'),
            (14, N'Revisión de permisos de carpetas'),
            (15, N'Capacitación en navegación segura'),
            (16, N'Asesoría en inventarios digitales'),
            (17, N'Diseño de formularios internos'),
            (18, N'Configuración de firma de correo'),
            (19, N'Capacitación en herramientas colaborativas')
        ) AS v(numero, texto);

        SELECT
            v.numero,
            v.texto
        INTO #modalidades
        FROM (
            VALUES
            (0, N'sesión introductoria de 30 minutos'),
            (1, N'sesión individual de una hora'),
            (2, N'taller de dos horas'),
            (3, N'taller grupal de cuatro horas'),
            (4, N'jornada de ocho horas')
        ) AS v(numero, texto);

        SELECT
            n.numero,
            CONCAT(t.texto, N', marca ', m.texto, N', ', v.texto) AS descripcion
        INTO #semilla_catalogo
        FROM #numeros AS n
        INNER JOIN #tipos_producto AS t ON t.numero = (n.numero - 1) % 25
        INNER JOIN #marcas AS m ON m.numero = ((n.numero - 1) / 25) % 4
        INNER JOIN #presentaciones AS v ON v.numero = (n.numero - 1) / 100
        WHERE n.numero <= 1000
        UNION ALL
        SELECT
            n.numero,
            CONCAT(t.texto, N', ', m.texto) AS descripcion
        FROM #numeros AS n
        INNER JOIN #tipos_servicio AS t ON t.numero = (n.numero - 1001) % 20
        INNER JOIN #modalidades AS m ON m.numero = (n.numero - 1001) / 20
        WHERE n.numero > 1000;

        INSERT INTO dbo.descripcion_articulo (descripcion)
        SELECT n.descripcion FROM #semilla_catalogo AS n;
        INSERT INTO dbo.producto_servicio
        (
            id_tipo_articulo,
            codigo_interno,
            id_descripcion,
            precio_unitario_lista,
            porcentaje_impuesto, activo, fecha_creacion
        )
        SELECT
            CASE WHEN n.numero <= 1000 THEN 1 ELSE 2 END AS id_tipo_articulo,
            CONCAT('DEMO-', RIGHT(CONCAT('0000', n.numero), 4))
                AS codigo_interno,
            d.id_descripcion,
            CAST(10 + (n.numero % 200) * 2.5 AS DECIMAL(19, 4))
                AS precio_unitario_lista,
            CASE WHEN n.numero % 5 = 0 THEN 0 ELSE 13 END
                AS porcentaje_impuesto,
            1 AS activo,
            DATEADD(YEAR, -1, CAST(SYSDATETIME() AS DATE)) AS fecha_creacion
        FROM #semilla_catalogo AS n
        INNER JOIN
            dbo.descripcion_articulo AS d
            ON n.descripcion = d.descripcion
        WHERE NOT EXISTS (
            SELECT 1 FROM dbo.producto_servicio AS p
            WHERE
                p.codigo_interno
                = CONCAT('DEMO-', RIGHT(CONCAT('0000', n.numero), 4))
        );

        INSERT INTO dbo.producto (id_producto_servicio, existencias)
        SELECT
            p.id_producto_servicio,
            10000 + n.numero % 100 AS existencias
        FROM dbo.producto_servicio AS p
        INNER JOIN #numeros AS n
            ON
                p.codigo_interno
                = CONCAT('DEMO-', RIGHT(CONCAT('0000', n.numero), 4))
        WHERE n.numero <= 1000 AND NOT EXISTS (
            SELECT 1 FROM dbo.producto AS pr
            WHERE pr.id_producto_servicio = p.id_producto_servicio
        );

        INSERT INTO dbo.servicio (id_producto_servicio, id_unidad_cobro)
        SELECT
            p.id_producto_servicio,
            CASE
                WHEN n.numero <= 1040 THEN 1
                WHEN n.numero <= 1080 THEN 2 ELSE 3
            END AS id_unidad_cobro
        FROM dbo.producto_servicio AS p
        INNER JOIN #numeros AS n
            ON
                p.codigo_interno
                = CONCAT('DEMO-', RIGHT(CONCAT('0000', n.numero), 4))
        WHERE n.numero > 1000 AND NOT EXISTS (
            SELECT 1 FROM dbo.servicio AS s
            WHERE s.id_producto_servicio = p.id_producto_servicio
        );

        DROP TABLE #semilla_catalogo;
        DROP TABLE #tipos_producto;
        DROP TABLE #marcas;
        DROP TABLE #presentaciones;
        DROP TABLE #tipos_servicio;
        DROP TABLE #modalidades;
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
    EXEC dbo.cargar_productos_servicios_tmp
        @codigo_error = @error OUTPUT, @mensaje_error = @mensaje OUTPUT;
END TRY
BEGIN CATCH
    DROP PROCEDURE dbo.cargar_productos_servicios_tmp;
    THROW;
END CATCH;
DROP PROCEDURE dbo.cargar_productos_servicios_tmp;
IF @error <> 0 THROW 51999, @mensaje, 1;
GO
