USE facturacion;
GO

CREATE OR ALTER FUNCTION dbo.factura_es_borrador
(
    @identificador_comprobante VARCHAR(40)
)
RETURNS BIT
AS
BEGIN
    IF EXISTS (
        SELECT 1
        FROM dbo.factura AS f
        INNER JOIN dbo.estado_factura AS e ON f.id_estado = e.id_estado
        WHERE f.identificador_comprobante = @identificador_comprobante
            AND e.codigo_estado = 'BORRADOR'
    )
        RETURN 1;

    RETURN 0;
END;
GO
