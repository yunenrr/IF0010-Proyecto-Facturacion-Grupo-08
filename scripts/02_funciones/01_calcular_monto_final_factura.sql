USE facturacion;
GO

CREATE OR ALTER FUNCTION dbo.calcular_monto_final_factura(
    @id_factura BIGINT
)
RETURNS DECIMAL(19, 4)
AS
BEGIN
    DECLARE @monto_final DECIMAL(19, 4);

    SELECT @monto_final = subtotal - total_descuentos + total_impuestos
    FROM dbo.factura
    WHERE id_factura = @id_factura;

    RETURN @monto_final;
END;
GO
