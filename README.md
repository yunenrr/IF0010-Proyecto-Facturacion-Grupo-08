# IF0010 - Proyecto de Facturación - Grupo 08

## Descripción general

Base de datos en SQL Server para administrar empresas emisoras, clientes, productos, servicios y facturas. Incluye las tablas, la carga inicial de datos, los índices, los procedimientos almacenados, las funciones, las vistas y los triggers de auditoría.

## Integrantes del grupo

| Nombre completo | Carnet |
| --- | --- |
| David Romero Solano | C37020 |
| Anthonny Pasos Martinez | C25806 |
| Wilberth Abarca Trejos | C30027 |

## Requisitos

- SQL Server 2019 o superior.
- SQL Server Management Studio (SSMS).
- Permisos para crear la base de datos y sus objetos.

## Orden de ejecución

Dentro de `scripts`, ejecute las carpetas en este orden y los archivos de cada carpeta en orden numérico:

1. `01_tablas`: crea la base y las tablas.
2. `02_funciones`: crea las funciones.
3. `03_indices`: crea los índices.
4. `04_tipos`: crea el tipo de tabla para los detalles de una factura.
5. `05_procedimientos`: crea los procedimientos almacenados.
6. `06_roles`: crea los roles y asigna permisos sobre las funciones.
7. `07_vistas`: crea las vistas.
8. `08_catalogos_auditoria`: carga las entidades, operaciones, momentos y campos necesarios para la auditoría.
9. `09_triggers`: crea los triggers de auditoría.
10. `10_carga_datos`: carga los datos con los triggers activos.
11. `11_consultas`: contiene las consultas de clientes y facturas y las demostraciones de permisos. Se ejecutan por separado después de instalar el proyecto.

Ejecute cada archivo completo en SQL Server Management Studio. Si aparece un error, revíselo antes de continuar.

- Para instalar el proyecto, la base `facturacion` debe estar nueva y vacía. El primer script la crea si no existe.
- Si ya ejecutó la instalación y desea repetirla desde cero, elimine primero la base `facturacion`. Esto borra todos sus datos; guarde antes lo que necesite conservar.
- La carga de facturas confirma lotes de 10 000 facturas junto con sus detalles y auditoría. Si falla, los lotes anteriores quedan guardados; para repetir la instalación completa, utilice una base vacía.

## Consultas

Los archivos `01` y `02` de `11_consultas` demuestran los permisos por rol. Deben ejecutarse como `dbo` y revierten sus usuarios y datos de prueba al finalizar. Auditor y DBA pueden consultar el historial; Administrativo puede consultar los datos completos de clientes, mientras que Cajero y Consulta reciben teléfono y correo como `NULL`.

Las consultas `03` a `10` permiten buscar clientes y consultar sus facturas y totales. Los parámetros se modifican al inicio de cada archivo. Las búsquedas por nombre, razón social y nombre comercial coinciden desde el inicio del texto; los apellidos se comparan completos. El resumen anual utiliza el año del servidor y el rango de fechas incluye ambos días.

## Registro de clientes

En `registrar_cliente`, el parámetro `@nombre` recibe el nombre completo para personas físicas o la razón social para personas jurídicas. Indique también `@primer_apellido` y `@segundo_apellido` para una persona física, o `@nombre_comercial` para una jurídica.

## Auditoría

Los triggers están activos antes de la carga inicial, por lo que los datos cargados también generan registros de auditoría. Registran inserciones, modificaciones y eliminaciones de clientes, direcciones, productos, servicios y facturas. Guardan la operación, el usuario, la fecha y los valores anteriores y nuevos. Los registros de auditoría se revierten junto con la transacción. Los cambios únicamente de mayúsculas o espacios finales pueden no registrarse.
