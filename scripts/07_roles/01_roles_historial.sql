USE facturacion;
GO

IF DATABASE_PRINCIPAL_ID('Auditor') IS NULL
    CREATE ROLE [Auditor];
GO

IF DATABASE_PRINCIPAL_ID('DBA') IS NULL
    CREATE ROLE dba;
GO

GRANT SELECT ON OBJECT::dbo.consultar_historial_cambios TO [Auditor];
GRANT SELECT ON OBJECT::dbo.consultar_historial_cambios TO dba;
GO
