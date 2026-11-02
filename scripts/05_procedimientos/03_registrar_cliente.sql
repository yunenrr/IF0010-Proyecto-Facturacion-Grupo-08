USE facturacion;
GO

CREATE OR ALTER PROCEDURE dbo.registrar_cliente
    @id_direccion BIGINT, @cedula VARCHAR(20),
    @id_tipo_persona INT, @nombre VARCHAR(250),
    @telefono VARCHAR(20), @correo_electronico VARCHAR(254),
    @id_cliente INT OUTPUT,
    @codigo_error INT OUTPUT,
    @mensaje_error VARCHAR(4000) OUTPUT,
    @primer_apellido VARCHAR(100) = NULL,
    @segundo_apellido VARCHAR(100) = NULL,
    @nombre_comercial VARCHAR(200) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    SET @codigo_error = 0;
    SET @mensaje_error = N'';
    SET @id_cliente = NULL;
    DECLARE @entrada INT = @@TRANCOUNT;
    DECLARE @guardado BIT = 0;
    BEGIN TRY

        IF @entrada = 0
            BEGIN TRANSACTION;
        ELSE
            BEGIN
                SAVE TRANSACTION registrar_cliente;
                SET @guardado = 1;
            END;
        IF
            @telefono IS NULL OR TRIM(@telefono) = ''
            OR @correo_electronico IS NULL OR TRIM(@correo_electronico) = ''
            THROW 50013, 'Telefono y correo son obligatorios.', 1;
        IF
            NOT EXISTS (
                SELECT 1 FROM dbo.direccion
                WHERE id_direccion = @id_direccion
            )
            THROW 50014, 'La direccion no existe.', 1;

        IF
            @cedula IS NULL OR TRIM(@cedula) = '' OR @nombre IS NULL
            OR TRIM(@nombre) = N'' OR @id_tipo_persona IS NULL
            OR @id_tipo_persona NOT IN (1, 2)
            THROW 50015,
            'Nombre, cedula y tipo de persona validos son obligatorios.',
            1;
        IF
            EXISTS (
                SELECT 1 FROM dbo.cliente WITH (UPDLOCK, HOLDLOCK)
                WHERE cedula = TRIM(@cedula)
            )
            THROW 50016, 'La cedula de cliente ya existe.', 1;
        IF
            EXISTS (
                SELECT 1 FROM dbo.cliente WITH (UPDLOCK, HOLDLOCK)
                WHERE id_direccion = @id_direccion
            )
            THROW 50019, 'Direccion asignada a otro cliente.', 1;
        IF
            @id_tipo_persona = 1
            AND (
                @primer_apellido IS NULL OR TRIM(@primer_apellido) = ''
                OR @segundo_apellido IS NULL OR TRIM(@segundo_apellido) = ''
            )
            THROW 50028, 'Indique ambos apellidos del cliente fisico.', 1;
        IF
            @id_tipo_persona = 1
            AND RIGHT(TRIM(@nombre), LEN(CONCAT(
                ' ', TRIM(@primer_apellido), ' ', TRIM(@segundo_apellido)
            ))) <> CONCAT(
                ' ', TRIM(@primer_apellido), ' ', TRIM(@segundo_apellido)
            )
            THROW 50029,
            'El nombre completo debe incluir ambos apellidos.',
            1;
        IF
            @id_tipo_persona = 2
            AND (@nombre_comercial IS NULL OR TRIM(@nombre_comercial) = '')
            THROW 50030,
            'Indique el nombre comercial del cliente juridico.',
            1;
        DECLARE @ahora DATETIME2(7) = SYSDATETIME();
        INSERT INTO dbo.cliente (
            id_direccion, id_tipo_persona, cedula, telefono,
            correo_electronico, fecha_registro, fecha_ultima_actualizacion
        )
        VALUES (
            @id_direccion, @id_tipo_persona, TRIM(@cedula), TRIM(@telefono),
            TRIM(@correo_electronico), @ahora, @ahora
        );
        SET @id_cliente = SCOPE_IDENTITY();
        IF @id_tipo_persona = 1
            INSERT INTO dbo.persona_fisica
            (id_cliente, nombre_persona, primer_apellido, segundo_apellido)
            VALUES (
                @id_cliente, TRIM(@nombre),
                TRIM(@primer_apellido), TRIM(@segundo_apellido)
            );
        ELSE
            INSERT INTO dbo.persona_juridica
            (id_cliente, razon_social, nombre_comercial)
            VALUES (@id_cliente, TRIM(@nombre), TRIM(@nombre_comercial));

        IF @entrada = 0 COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        SET @codigo_error = ERROR_NUMBER();
        SET @mensaje_error = ERROR_MESSAGE();
        SET @id_cliente = NULL;
        IF @entrada = 0 AND XACT_STATE() <> 0
            ROLLBACK TRANSACTION;
        ELSE IF @guardado = 1 AND XACT_STATE() = 1
            ROLLBACK TRANSACTION registrar_cliente;
    END CATCH;
    RETURN @codigo_error;
END;
GO
