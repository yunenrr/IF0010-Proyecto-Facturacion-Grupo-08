USE master;
GO
IF DB_ID(N'facturacion') IS NULL
    BEGIN
        CREATE DATABASE facturacion;
    END;
GO
IF
    EXISTS (
        SELECT 1 FROM facturacion.sys.tables
        WHERE is_ms_shipped = 0
    )
    THROW 51000, 'Instale en una base facturacion nueva y vacia.', 1;
ALTER DATABASE facturacion COLLATE latin1_general_100_ci_as_sc_utf8;
GO
USE facturacion;
GO
