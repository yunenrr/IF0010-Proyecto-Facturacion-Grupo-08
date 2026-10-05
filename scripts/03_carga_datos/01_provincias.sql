USE facturacion;
GO

CREATE OR ALTER PROCEDURE dbo.cargar_provincias_tmp

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

        DECLARE
            @provincia TABLE
            (
                id_provincia INT NOT NULL,
                nombre_provincia VARCHAR(100) NOT NULL
            );
        INSERT INTO @provincia (id_provincia, nombre_provincia)
        VALUES
        (1, N'San José'),
        (2, N'Alajuela'),
        (3, N'Cartago'),
        (4, N'Heredia'),
        (5, N'Guanacaste'),
        (6, N'Puntarenas'),
        (7, N'Limón');

        IF
            EXISTS (
                SELECT 1 FROM @provincia AS s
                INNER JOIN dbo.provincia AS t ON s.id_provincia = t.id_provincia
                WHERE
                    t.nombre_provincia COLLATE latin1_general_100_bin2_utf8
                    <> s.nombre_provincia COLLATE latin1_general_100_bin2_utf8
            )
            THROW 51001,
            'Codigo geografico con otro nombre.',
            1;

        INSERT INTO dbo.provincia (id_provincia, nombre_provincia)
        SELECT
            s.id_provincia,
            s.nombre_provincia
        FROM @provincia AS s
        WHERE
            NOT EXISTS (
                SELECT 1 FROM dbo.provincia AS t
                WHERE t.id_provincia = s.id_provincia
            );

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
    EXEC dbo.cargar_provincias_tmp
        @codigo_error = @error OUTPUT, @mensaje_error = @mensaje OUTPUT;
END TRY
BEGIN CATCH
    DROP PROCEDURE dbo.cargar_provincias_tmp;
    THROW;
END CATCH;
DROP PROCEDURE dbo.cargar_provincias_tmp;
IF @error <> 0 THROW 51999, @mensaje, 1;
GO
