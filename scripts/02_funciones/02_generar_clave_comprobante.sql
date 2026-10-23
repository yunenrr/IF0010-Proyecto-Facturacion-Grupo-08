USE facturacion;
GO

CREATE OR ALTER FUNCTION dbo.generar_clave_comprobante(
    @fecha DATETIME2(0),
    @tipo_documento VARCHAR(10)
)
RETURNS VARCHAR(40)
AS
BEGIN
    RETURN CONVERT(CHAR(8), @fecha, 112)
    + REPLACE(CONVERT(CHAR(8), @fecha, 108), ':', '')
    + '-' + @tipo_documento;
END;
GO
