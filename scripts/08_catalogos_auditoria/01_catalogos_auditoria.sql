USE facturacion;
GO

INSERT INTO dbo.entidad_auditoria (id_entidad, nombre) VALUES
(1, N'FACTURA'),
(2, N'DETALLE_FACTURA'),
(3, N'CLIENTE'),
(4, N'PRODUCTO_SERVICIO'),
(5, N'PRODUCTO'),
(6, N'SERVICIO');

INSERT INTO dbo.operacion_auditoria (id_operacion, nombre) VALUES
(1, N'INSERT'),
(2, N'UPDATE'),
(3, N'DELETE');

INSERT INTO dbo.momento_auditoria (id_momento, nombre) VALUES
(1, N'ANTERIOR'),
(2, N'NUEVO');

INSERT INTO dbo.entidad_auditoria (id_entidad, nombre)
VALUES (7, 'DIRECCION'), (8, 'PERSONA_FISICA'), (9, 'PERSONA_JURIDICA');

INSERT INTO dbo.campo_auditoria (id_entidad, nombre)
VALUES
(8, 'nombre_persona'),
(8, 'primer_apellido'),
(8, 'segundo_apellido'),
(9, 'razon_social'),
(9, 'nombre_comercial'),
(7, 'id_provincia'),
(7, 'id_canton'),
(7, 'id_distrito'),
(7, 'senas_exactas'),
(5, 'existencias'),
(6, 'id_unidad_cobro'),
(1, 'identificador_comprobante'),
(1, 'id_empresa'),
(1, 'id_cliente'),
(1, 'id_tipo_documento'),
(1, 'id_moneda'),
(1, 'id_estado'),
(1, 'fecha_emision'),
(1, 'subtotal'),
(1, 'total_descuentos'),
(1, 'total_impuestos'),
(1, 'monto_total'),
(1, 'fecha_creacion'),
(1, 'fecha_modificacion'),
(2, 'id_producto_servicio'),
(2, 'id_descripcion'),
(2, 'cantidad'),
(2, 'precio_unitario'),
(2, 'porcentaje_impuesto'),
(2, 'monto_descuento'),
(2, 'subtotal_linea'),
(2, 'monto_impuesto'),
(2, 'monto_total_linea'),
(3, 'id_direccion'),
(3, 'id_tipo_persona'),
(3, 'cedula'),
(3, 'telefono'),
(3, 'correo_electronico'),
(3, 'fecha_registro'),
(3, 'fecha_ultima_actualizacion'),
(4, 'id_tipo_articulo'),
(4, 'codigo_interno'),
(4, 'id_descripcion'),
(4, 'precio_unitario_lista'),
(4, 'porcentaje_impuesto'),
(4, 'activo'),
(4, 'fecha_creacion');
GO
