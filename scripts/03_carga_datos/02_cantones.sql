USE facturacion;
GO

CREATE OR ALTER PROCEDURE dbo.cargar_cantones_tmp

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
            @canton TABLE
            (
                id_provincia INT NOT NULL,
                id_canton SMALLINT NOT NULL,
                nombre_canton VARCHAR(100) NOT NULL
            );
        INSERT INTO @canton (id_provincia, id_canton, nombre_canton)
        VALUES
        (1, 1, N'San José'),
        (1, 2, N'Escazú'),
        (1, 3, N'Desamparados'),
        (1, 4, N'Puriscal'),
        (1, 5, N'Tarrazú'),
        (1, 6, N'Aserrí'),
        (1, 7, N'Mora'),
        (1, 8, N'Goicoechea'),
        (1, 9, N'Santa Ana'),
        (1, 10, N'Alajuelita'),
        (1, 11, N'Vásquez de Coronado'),
        (1, 12, N'Acosta'),
        (1, 13, N'Tibás'),
        (1, 14, N'Moravia'),
        (1, 15, N'Montes de Oca'),
        (1, 16, N'Turrubares'),
        (1, 17, N'Dota'),
        (1, 18, N'Curridabat'),
        (1, 19, N'Pérez Zeledón'),
        (1, 20, N'León Cortéz Castro'),
        (2, 1, N'Alajuela'),
        (2, 2, N'San Ramón'),
        (2, 3, N'Grecia'),
        (2, 4, N'San Mateo'),
        (2, 5, N'Atenas'),
        (2, 6, N'Naranjo'),
        (2, 7, N'Palmares'),
        (2, 8, N'Poás'),
        (2, 9, N'Orotina'),
        (2, 10, N'San Carlos'),
        (2, 11, N'Zarcero'),
        (2, 12, N'Valverde Vega'),
        (2, 13, N'Upala'),
        (2, 14, N'Los Chiles'),
        (2, 15, N'Guatuso'),
        (3, 1, N'Cartago'),
        (3, 2, N'Paraíso'),
        (3, 3, N'La Unión'),
        (3, 4, N'Jiménez'),
        (3, 5, N'Turrialba'),
        (3, 6, N'Alvarado'),
        (3, 7, N'Oreamuno'),
        (3, 8, N'El Guarco'),
        (4, 1, N'Heredia'),
        (4, 2, N'Barva'),
        (4, 3, N'Santo Domingo'),
        (4, 4, N'Santa Bárbara'),
        (4, 5, N'San Rafaél'),
        (4, 6, N'San Isidro'),
        (4, 7, N'Belén'),
        (4, 8, N'Flores'),
        (4, 9, N'San Pablo'),
        (4, 10, N'Sarapiquí'),
        (5, 1, N'Liberia'),
        (5, 2, N'Nicoya'),
        (5, 3, N'Santa Cruz'),
        (5, 4, N'Bagaces'),
        (5, 5, N'Carrillo'),
        (5, 6, N'Cañas'),
        (5, 7, N'Abangáres'),
        (5, 8, N'Tilarán'),
        (5, 9, N'Nandayure'),
        (5, 10, N'La Cruz'),
        (5, 11, N'Hojancha'),
        (6, 1, N'Puntarenas'),
        (6, 2, N'Esparza'),
        (6, 3, N'Buenos Aires'),
        (6, 4, N'Montes de Oro'),
        (6, 5, N'Osa'),
        (6, 6, N'Aguirre'),
        (6, 7, N'Golfito'),
        (6, 8, N'Coto Brus'),
        (6, 9, N'Parrita'),
        (6, 10, N'Corredores'),
        (6, 11, N'Garabito'),
        (7, 1, N'Limón'),
        (7, 2, N'Pococí'),
        (7, 3, N'Siquirres'),
        (7, 4, N'Talamanca'),
        (7, 5, N'Matina'),
        (7, 6, N'Guácimo');

        IF
            EXISTS (
                SELECT 1 FROM @canton AS s
                INNER JOIN
                    dbo.canton AS t
                    ON
                        s.id_provincia = t.id_provincia
                        AND s.id_canton = t.id_canton
                WHERE
                    t.nombre_canton COLLATE latin1_general_100_bin2_utf8
                    <> s.nombre_canton COLLATE latin1_general_100_bin2_utf8
            )
            THROW 51001,
            'Codigo geografico con otro nombre.',
            1;

        INSERT INTO dbo.canton (id_provincia, id_canton, nombre_canton)
        SELECT
            s.id_provincia,
            s.id_canton,
            s.nombre_canton
        FROM @canton AS s
        WHERE
            NOT EXISTS (
                SELECT 1 FROM dbo.canton AS t
                WHERE
                    t.id_provincia = s.id_provincia
                    AND t.id_canton = s.id_canton
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
    EXEC dbo.cargar_cantones_tmp
        @codigo_error = @error OUTPUT, @mensaje_error = @mensaje OUTPUT;
END TRY
BEGIN CATCH
    DROP PROCEDURE dbo.cargar_cantones_tmp;
    THROW;
END CATCH;
DROP PROCEDURE dbo.cargar_cantones_tmp;
IF @error <> 0 THROW 51999, @mensaje, 1;
GO
