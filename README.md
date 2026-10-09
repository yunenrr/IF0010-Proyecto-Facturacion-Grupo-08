# IF0010 - Proyecto de Facturación - Grupo 08

## Descripción general

Base de datos en SQL Server para administrar empresas emisoras, clientes, productos, servicios y facturas. Incluye las tablas, la carga inicial de datos, los índices y los procedimientos almacenados.

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
2. `02_carga_datos`: carga los datos iniciales.
3. `03_indices`: crea los índices.
4. `04_tipos`: crea el tipo de tabla para los detalles de una factura.
5. `05_procedimientos`: crea los procedimientos almacenados.

Ejecute cada archivo completo en SQL Server Management Studio. Si aparece un error, revíselo antes de continuar.

## Notas importantes

- Para instalar el proyecto, la base `facturacion` debe estar nueva y vacía. El primer script la crea si no existe.
- Si ya ejecutó la instalación y desea repetirla desde cero, elimine primero la base `facturacion`. Esto borra todos sus datos; guarde antes lo que necesite conservar.
