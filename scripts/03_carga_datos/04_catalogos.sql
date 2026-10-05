USE facturacion;
GO

CREATE OR ALTER PROCEDURE dbo.cargar_catalogos_tmp

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
        IF EXISTS (SELECT 1 FROM dbo.tipo_persona)
            THROW 51001, 'El catalogo tipo_persona ya contiene datos.', 1;
        INSERT INTO dbo.tipo_persona (id_tipo_persona, descripcion) VALUES
        (1, N'FISICA'),
        (2, N'JURIDICA');
        IF EXISTS (SELECT 1 FROM dbo.tipo_articulo)
            THROW 51001, 'El catalogo tipo_articulo ya contiene datos.', 1;
        INSERT INTO dbo.tipo_articulo (id_tipo_articulo, descripcion) VALUES
        (1, N'PRODUCTO'),
        (2, N'SERVICIO');
        IF EXISTS (SELECT 1 FROM dbo.unidad_cobro)
            THROW 51001, 'El catalogo unidad_cobro ya contiene datos.', 1;
        INSERT INTO dbo.unidad_cobro (id_unidad_cobro, descripcion) VALUES
        (1, N'sesión'),
        (2, N'taller'),
        (3, N'jornada');
        IF EXISTS (SELECT 1 FROM dbo.tipo_documento)
            THROW 51001, 'El catalogo tipo_documento ya contiene datos.', 1;
        INSERT INTO dbo.tipo_documento (
            id_tipo_documento, codigo_tipo_documento, descripcion
        ) VALUES
        (1, N'FAC', N'Factura'),
        (2, N'TIQ', N'Tiquete');
        IF EXISTS (SELECT 1 FROM dbo.moneda)
            THROW 51001, 'El catalogo moneda ya contiene datos.', 1;
        INSERT INTO dbo.moneda (
            id_moneda, codigo_moneda, simbolo, descripcion
        ) VALUES
        (1, N'CRC', N'₡', N'Colón costarricense'),
        (2, N'USD', N'$', N'Dólar estadounidense');
        IF EXISTS (SELECT 1 FROM dbo.estado_factura)
            THROW 51001, 'El catalogo estado_factura ya contiene datos.', 1;
        INSERT INTO dbo.estado_factura (
            id_estado, codigo_estado, descripcion
        ) VALUES
        (1, N'BORRADOR', N'Comprobante en preparación'),
        (2, N'EMITIDA', N'Comprobante emitido'),
        (3, N'PAGADA', N'Comprobante pagado'),
        (4, N'CANCELADA', N'Comprobante cancelado');
        IF EXISTS (SELECT 1 FROM dbo.entidad_auditoria)
            THROW 51001, 'El catalogo entidad_auditoria ya contiene datos.', 1;
        INSERT INTO dbo.entidad_auditoria (id_entidad, nombre) VALUES
        (1, N'FACTURA'),
        (2, N'DETALLE_FACTURA'),
        (3, N'CLIENTE'),
        (4, N'PRODUCTO_SERVICIO'),
        (5, N'PRODUCTO'),
        (6, N'SERVICIO');
        IF EXISTS (SELECT 1 FROM dbo.operacion_auditoria)
            THROW 51001,
            'El catalogo operacion_auditoria ya contiene datos.',
            1;
        INSERT INTO dbo.operacion_auditoria (id_operacion, nombre) VALUES
        (1, N'INSERT'),
        (2, N'UPDATE'),
        (3, N'DELETE');
        IF EXISTS (SELECT 1 FROM dbo.momento_auditoria)
            THROW 51001, 'El catalogo momento_auditoria ya contiene datos.', 1;
        INSERT INTO dbo.momento_auditoria (id_momento, nombre) VALUES
        (1, N'ANTERIOR'),
        (2, N'NUEVO');

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
    EXEC dbo.cargar_catalogos_tmp
        @codigo_error = @error OUTPUT, @mensaje_error = @mensaje OUTPUT;
END TRY
BEGIN CATCH
    DROP PROCEDURE dbo.cargar_catalogos_tmp;
    THROW;
END CATCH;
DROP PROCEDURE dbo.cargar_catalogos_tmp;
IF @error <> 0 THROW 51999, @mensaje, 1;
GO
