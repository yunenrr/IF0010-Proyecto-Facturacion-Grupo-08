USE facturacion;
GO

CREATE OR ALTER PROCEDURE dbo.registrar_articulo
    @id_tipo_articulo INT, @codigo VARCHAR(30),
    @descripcion VARCHAR(500), @precio DECIMAL(19, 4),
    @impuesto DECIMAL(5, 2), @activo BIT, @id_articulo INT OUTPUT,
    @existencias DECIMAL(18, 4) = NULL, @id_unidad_cobro INT = NULL,
    @codigo_error INT OUTPUT,
    @mensaje_error VARCHAR(4000) OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    SET @codigo_error = 0;
    SET @mensaje_error = N'';
    SET @id_articulo = NULL;
    DECLARE @entrada INT = @@TRANCOUNT;
    DECLARE @guardado BIT = 0;
    BEGIN TRY

        IF @entrada = 0
            BEGIN TRANSACTION;
        ELSE
            BEGIN
                SAVE TRANSACTION registrar_articulo;
                SET @guardado = 1;
            END;
        IF
            @descripcion IS NULL OR TRIM(@descripcion) = N''
            OR @precio IS NULL OR @precio <= 0 OR @impuesto IS NULL
            OR @impuesto < 0 OR @impuesto > 100 OR @activo IS NULL
            THROW 50020,
            'Descripcion, precio, impuesto o estado invalidos.',
            1;

        IF
            @codigo IS NULL OR TRIM(@codigo) = '' OR @id_tipo_articulo IS NULL
            OR @id_tipo_articulo NOT IN (1, 2)
            THROW 50021, 'Codigo y tipo de articulo invalidos.', 1;
        IF
            @id_tipo_articulo = 1 AND (
                @existencias IS NULL OR @existencias < 0
                OR @id_unidad_cobro IS NOT NULL
            )
            THROW 50022,
            'El producto requiere existencias y no unidad de cobro.',
            1;
        IF
            @id_tipo_articulo = 2 AND (@existencias IS NOT NULL OR NOT EXISTS (
                SELECT 1
                FROM dbo.unidad_cobro
                WHERE id_unidad_cobro = @id_unidad_cobro
            ))
            THROW 50023,
            'El servicio requiere unidad de cobro y no existencias.',
            1;
        IF
            EXISTS (
                SELECT 1 FROM dbo.producto_servicio WITH (UPDLOCK, HOLDLOCK)
                WHERE codigo_interno = TRIM(@codigo)
            )
            THROW 50024, 'El codigo de articulo ya existe.', 1;
        DECLARE @id_descripcion INT;
        SELECT @id_descripcion = id_descripcion
        FROM
            dbo.descripcion_articulo
            WITH (UPDLOCK, HOLDLOCK)
        WHERE descripcion = TRIM(@descripcion);
        IF @id_descripcion IS NULL
            BEGIN
                INSERT INTO dbo.descripcion_articulo (descripcion)
                VALUES (TRIM(@descripcion));
                SET @id_descripcion = SCOPE_IDENTITY();
            END;

        INSERT INTO dbo.producto_servicio (
            id_tipo_articulo, codigo_interno,
            id_descripcion, precio_unitario_lista, porcentaje_impuesto, activo,
            fecha_creacion
        )
        VALUES (
            @id_tipo_articulo, TRIM(@codigo), @id_descripcion, @precio,
            @impuesto, @activo, SYSDATETIME()
        );
        SET @id_articulo = SCOPE_IDENTITY();
        IF @id_tipo_articulo = 1
            INSERT INTO dbo.producto (id_producto_servicio, existencias)
            VALUES (@id_articulo, @existencias);
        ELSE
            INSERT INTO dbo.servicio (id_producto_servicio, id_unidad_cobro)
            VALUES (@id_articulo, @id_unidad_cobro);

        IF @entrada = 0 COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        SET @codigo_error = ERROR_NUMBER();
        SET @mensaje_error = ERROR_MESSAGE();
        SET @id_articulo = NULL;
        IF @entrada = 0 AND XACT_STATE() <> 0
            ROLLBACK TRANSACTION;
        ELSE IF @guardado = 1 AND XACT_STATE() = 1
            ROLLBACK TRANSACTION registrar_articulo;
    END CATCH;
    RETURN @codigo_error;
END;
GO
