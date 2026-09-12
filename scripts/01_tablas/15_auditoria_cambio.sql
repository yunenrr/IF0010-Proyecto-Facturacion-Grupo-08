USE facturacion;
GO

SET NOCOUNT ON;
SET XACT_ABORT ON;
GO

IF OBJECT_ID(N'dbo.auditoria_cambio', N'U') IS NULL
    BEGIN
        CREATE TABLE dbo.auditoria_cambio
        (
            id_evento BIGINT NOT NULL,
            nombre_campo SYSNAME NOT NULL,
            valor_anterior NVARCHAR(4000) NULL,
            valor_nuevo NVARCHAR(4000) NULL,

            CONSTRAINT [PK_auditoria_cambio]
            PRIMARY KEY CLUSTERED (id_evento, nombre_campo),
            CONSTRAINT [FK_auditoria_cambio_evento]
            FOREIGN KEY (id_evento)
            REFERENCES dbo.auditoria_evento (id_evento),
            CONSTRAINT [CK_auditoria_cambio_nombre_no_vacio]
            CHECK (LTRIM(RTRIM(nombre_campo)) <> N''),
            CONSTRAINT [CK_auditoria_cambio_algun_valor]
            CHECK (valor_anterior IS NOT NULL OR valor_nuevo IS NOT NULL)
        );
    END;
GO
