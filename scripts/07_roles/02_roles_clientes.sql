USE facturacion;
GO

IF DATABASE_PRINCIPAL_ID('Administrativo') IS NULL
    CREATE ROLE [Administrativo];
GO

IF DATABASE_PRINCIPAL_ID('Cajero') IS NULL
    CREATE ROLE [Cajero];
GO

IF DATABASE_PRINCIPAL_ID('Consulta') IS NULL
    CREATE ROLE [Consulta];
GO

GRANT SELECT ON OBJECT::dbo.consultar_informacion_cliente TO [Administrativo];
GRANT SELECT ON OBJECT::dbo.consultar_informacion_cliente TO [Cajero];
GRANT SELECT ON OBJECT::dbo.consultar_informacion_cliente TO [Consulta];
GO
