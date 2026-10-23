# IF0010 - Proyecto de Facturación - Grupo 08

## Descripción general

Base de datos en SQL Server para administrar empresas emisoras, clientes, productos, servicios y facturas. Incluye las tablas, la carga inicial de datos, los índices, los procedimientos almacenados, las funciones y las vistas.

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
3. `03_carga_datos`: carga los datos iniciales.
4. `04_indices`: crea los índices.
5. `05_tipos`: crea el tipo de tabla para los detalles de una factura.
6. `06_procedimientos`: crea los procedimientos almacenados.
7. `07_roles`: crea los roles y asigna permisos sobre las funciones.
8. `08_vistas`: crea las vistas.
9. `09_consultas`: contiene las consultas de demostración; ejecútelas como `dbo` después de instalar el proyecto.

Ejecute cada archivo completo en SQL Server Management Studio. Si aparece un error, revíselo antes de continuar.

La consulta `01_demostrar_historial_por_rol.sql` muestra un registro para Auditor, uno para DBA y cero para un usuario sin esos roles. Sus usuarios y datos de demostración se deshacen al terminar. El instalador personal incluye hasta `08_vistas`; las demostraciones se ejecutan por separado.

La consulta `02_demostrar_clientes_por_rol.sql` consulta un cliente físico y uno jurídico: Administrativo ve los datos completos; Cajero y Consulta ven teléfono y correo como `NULL`; un usuario sin esos roles no obtiene filas. Los usuarios de demostración se deshacen al terminar.

## Notas importantes

- Para instalar el proyecto, la base `facturacion` debe estar nueva y vacía. El primer script la crea si no existe.
- Si ya ejecutó la instalación y desea repetirla desde cero, elimine primero la base `facturacion`. Esto borra todos sus datos; guarde antes lo que necesite conservar.

