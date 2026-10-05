USE facturacion;
GO

CREATE OR ALTER PROCEDURE dbo.cargar_facturas_detalles_tmp

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
        IF EXISTS (SELECT 1 FROM dbo.factura)
            THROW 51001, 'La carga requiere facturas vacias.', 1;
        IF
            (SELECT COUNT(*) FROM dbo.empresa_emisora) <> 100
            OR (SELECT COUNT(*) FROM dbo.cliente) <> 50000
            OR (SELECT COUNT(*) FROM dbo.producto_servicio) <> 1100
            THROW 51002, 'Cargue primero los maestros completos.', 1;
        DECLARE
            @inicio DATETIME2(0)
            = DATEADD(YEAR, -1, CAST(SYSDATETIME() AS DATE));
        DECLARE
            @segundos BIGINT
            = DATEDIFF(SECOND, @inicio, CAST(SYSDATETIME() AS DATE));
        DECLARE @ahora DATETIME2(7) = SYSDATETIME();
        WITH digito AS (
            SELECT d.valor
            FROM
                (VALUES (0), (1), (2), (3), (4), (5), (6), (7), (8), (9))
                    AS d (valor)
        )

        SELECT
            a.valor
            + 10 * b.valor
            + 100 * c.valor
            + 1000 * d.valor
            + 10000 * e.valor
            + 100000 * f.valor
            + 1 AS numero
        INTO #numeros
        FROM digito AS a
        CROSS JOIN digito AS b
        CROSS JOIN digito AS c
        CROSS JOIN digito AS d CROSS JOIN digito AS e CROSS JOIN digito AS f
        WHERE
            a.valor + 10 * b.valor + 100 * c.valor + 1000 * d.valor
            + 10000 * e.valor + 100000 * f.valor < 500000;
        SELECT
            n.numero,
            e.id_empresa
        INTO #empresas
        FROM #numeros AS n
        INNER JOIN dbo.empresa_emisora AS e
            ON
                e.cedula
                = CAST(3101000000 + CAST(n.numero AS BIGINT) AS VARCHAR(20))
        WHERE n.numero <= 100;
        SELECT
            n.numero,
            c.id_cliente
        INTO #clientes
        FROM #numeros AS n
        INNER JOIN dbo.cliente AS c
            ON c.cedula = CAST(
                CASE
                    WHEN n.numero % 5 = 0 THEN CAST(3102000000 AS BIGINT)
                    ELSE 100000000
                END + n.numero AS VARCHAR(20
                )
            )
        WHERE n.numero <= 50000;
        SELECT
            n.numero,
            p.id_producto_servicio,
            p.id_descripcion,
            p.precio_unitario_lista,
            p.porcentaje_impuesto
        INTO #catalogo
        FROM #numeros AS n INNER JOIN dbo.producto_servicio AS p
            ON
                p.codigo_interno
                = CONCAT('DEMO-', RIGHT(CONCAT('0000', n.numero), 4))
        WHERE n.numero <= 1100;
        IF
            (SELECT COUNT(*) FROM #empresas) <> 100
            OR (SELECT COUNT(*) FROM #clientes) <> 50000
            OR (SELECT COUNT(*) FROM #catalogo) <> 1100
            THROW 51003,
            'Los identificadores de maestros no corresponden a la carga.',
            1;
        IF
            EXISTS (
                SELECT 1 FROM dbo.empresa_emisora
                WHERE activo <> 1
            )
            OR EXISTS (
                SELECT 1
                FROM dbo.producto_servicio
                WHERE
                    activo <> 1
                    OR precio_unitario_lista <= 0
                    OR porcentaje_impuesto NOT BETWEEN 0 AND 100
            )
            THROW 51004,
            'Los maestros tienen valores invalidos para facturar.',
            1;
        DECLARE @desde INT = 1;
        WHILE @desde <= 500000
            BEGIN
                SELECT
                    n.numero,
                    e.id_empresa,
                    c.id_cliente,
                    CAST(
                        1
                        + ((n.numero - 1) / 8 + (n.numero - 1) / 50000)
                        % 2 AS INT
                    ) AS id_tipo_documento,
                    CAST(
                        1
                        + ((n.numero - 1) / 4 + (n.numero - 1) / 50000)
                        % 2 AS INT
                    ) AS id_moneda,
                    CAST(
                        1
                        + ((n.numero - 1) + (n.numero - 1) / 50000)
                        % 4 AS INT
                    ) AS id_estado,
                    DATEADD(
                        SECOND,
                        CAST(
                            (CAST(n.numero AS BIGINT) - 1)
                            * @segundos
                            / 500000 AS INT
                        ),
                        @inicio
                    ) AS fecha_emision
                INTO #plan FROM #numeros AS n
                INNER JOIN
                    #empresas AS e
                    ON
                        e.numero
                        = ((n.numero - 1) + 17 * ((n.numero - 1) / 50000)) % 100
                        + 1
                INNER JOIN
                    #clientes AS c
                    ON c.numero = (n.numero - 1) % 50000 + 1
                WHERE n.numero BETWEEN @desde AND @desde + 4999;
                SELECT
                    p.numero,
                    p.id_empresa,
                    p.id_cliente,
                    p.id_tipo_documento,
                    p.id_moneda,
                    p.id_estado,
                    p.fecha_emision,
                    CONCAT(
                        CONVERT(CHAR(8), p.fecha_emision, 112),
                        REPLACE(
                            CONVERT(CHAR(8), p.fecha_emision, 108), ':', ''
                        ),
                        '-', t.codigo_tipo_documento
                    ) AS comprobante
                INTO #cabeceras FROM #plan AS p
                INNER JOIN
                    dbo.tipo_documento AS t
                    ON p.id_tipo_documento = t.id_tipo_documento;
                SELECT
                    c.numero,
                    l.numero_linea,
                    p.id_producto_servicio,
                    p.id_descripcion,
                    CAST(
                        1 + (c.numero + l.numero_linea) % 4 AS DECIMAL(18, 4)
                    ) AS cantidad,
                    p.precio_unitario_lista AS precio_unitario,
                    p.porcentaje_impuesto,
                    CAST(
                        (1 + (c.numero + l.numero_linea) % 4)
                        * p.precio_unitario_lista AS DECIMAL(19, 4)
                    ) AS subtotal_linea
                INTO #bases FROM #cabeceras AS c
                CROSS JOIN (VALUES (1), (2), (3), (4), (5)) AS l (numero_linea)
                INNER JOIN
                    #catalogo AS p
                    ON
                        p.numero
                        = ((c.numero - 1) * 5 + l.numero_linea - 1) % 1100 + 1
                WHERE l.numero_linea <= 3 + (c.numero - 1) % 3;
                SELECT
                    b.numero,
                    b.numero_linea,
                    b.id_producto_servicio,
                    b.id_descripcion,
                    b.cantidad,
                    b.precio_unitario,
                    b.porcentaje_impuesto,
                    b.subtotal_linea,
                    CAST(
                        CASE
                            WHEN
                                (b.numero + b.numero_linea) % 10 = 0
                                THEN b.subtotal_linea * 0.05
                            ELSE 0
                        END AS DECIMAL(19, 4)
                    ) AS descuento
                INTO #descuentos FROM #bases AS b;
                SELECT
                    d.numero,
                    d.numero_linea,
                    d.id_producto_servicio,
                    d.id_descripcion,
                    d.cantidad,
                    d.precio_unitario,
                    d.porcentaje_impuesto,
                    d.subtotal_linea,
                    d.descuento,
                    CAST(
                        ROUND(
                            (d.subtotal_linea - d.descuento)
                            * d.porcentaje_impuesto
                            / 100,
                            4
                        ) AS DECIMAL(19, 4)
                    ) AS impuesto
                INTO #lineas FROM #descuentos AS d;
                INSERT INTO dbo.factura (
                    identificador_comprobante, id_empresa, id_cliente,
                    id_tipo_documento, id_moneda, id_estado, fecha_emision,
                    subtotal, total_descuentos, total_impuestos, monto_total,
                    fecha_creacion, fecha_modificacion
                )
                SELECT
                    c.comprobante,
                    c.id_empresa,
                    c.id_cliente,
                    c.id_tipo_documento,
                    c.id_moneda,
                    c.id_estado,
                    c.fecha_emision,
                    SUM(l.subtotal_linea) AS subtotal,
                    SUM(l.descuento) AS total_descuentos,
                    SUM(l.impuesto) AS total_impuestos,
                    SUM(l.subtotal_linea - l.descuento + l.impuesto)
                        AS monto_total,
                    @ahora AS fecha_creacion,
                    @ahora AS fecha_modificacion
                FROM #cabeceras AS c
                INNER JOIN #lineas AS l ON c.numero = l.numero
                GROUP BY
                    c.comprobante,
                    c.id_empresa,
                    c.id_cliente,
                    c.id_tipo_documento,
                    c.id_moneda, c.id_estado, c.fecha_emision;
                INSERT INTO dbo.detalle_factura (
                    id_factura, numero_linea, id_producto_servicio,
                    id_descripcion,
                    cantidad,
                    precio_unitario,
                    porcentaje_impuesto,
                    monto_descuento,
                    subtotal_linea,
                    monto_impuesto,
                    monto_total_linea
                )
                SELECT
                    f.id_factura,
                    l.numero_linea,
                    l.id_producto_servicio,
                    l.id_descripcion,
                    l.cantidad,
                    l.precio_unitario,
                    l.porcentaje_impuesto,
                    l.descuento,
                    l.subtotal_linea,
                    l.impuesto,
                    l.subtotal_linea
                    - l.descuento
                    + l.impuesto AS monto_total_linea
                FROM #cabeceras AS c INNER JOIN dbo.factura AS f
                    ON c.comprobante = f.identificador_comprobante
                INNER JOIN #lineas AS l ON c.numero = l.numero;
                DROP TABLE #lineas;
                DROP TABLE #descuentos;
                DROP TABLE #bases;
                DROP TABLE #cabeceras;
                DROP TABLE #plan;
                SET @desde += 5000;
            END;

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
    EXEC dbo.cargar_facturas_detalles_tmp
        @codigo_error = @error OUTPUT, @mensaje_error = @mensaje OUTPUT;
END TRY
BEGIN CATCH
    DROP PROCEDURE dbo.cargar_facturas_detalles_tmp;
    THROW;
END CATCH;
DROP PROCEDURE dbo.cargar_facturas_detalles_tmp;
IF @error <> 0 THROW 51999, @mensaje, 1;
GO
