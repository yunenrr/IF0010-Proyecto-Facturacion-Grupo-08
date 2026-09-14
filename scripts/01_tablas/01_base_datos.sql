-- Ejecutar primero. Crea la base solamente si todavia no existe.
USE master;
GO

IF DB_ID(N'facturacion') IS NULL
    BEGIN
        CREATE DATABASE facturacion;
    END;
GO

USE facturacion;
GO
