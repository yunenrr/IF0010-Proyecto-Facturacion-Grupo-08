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
ALTER DATABASE facturacion SET RECOVERY SIMPLE;
ALTER DATABASE facturacion MODIFY FILE
(NAME = N'facturacion', SIZE = 1024MB, FILEGROWTH = 512MB);
ALTER DATABASE facturacion MODIFY FILE
(NAME = N'facturacion_log', SIZE = 512MB, FILEGROWTH = 256MB);
GO
USE facturacion;
GO
