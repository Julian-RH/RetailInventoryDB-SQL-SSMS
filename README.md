Este proyecto es una base de datos relacional para la gestión de inventario y ventas en una cadena de tiendas minoristas. Fue creado con el objetivo de demostrar mis habilidades en SQL, incluyendo la creación de estructuras de base de datos, vistas, procedimientos almacenados, triggers y consultas útiles para reportes.

Descripción del Proyecto

RetailInventoryDB simula un sistema de inventario y ventas para múltiples tiendas. Incluye módulos para:

  . Gestión de productos y tiendas.

  . Registro de ventas y detalles asociados.

  . Control de inventario por tienda.

  . Promociones con fechas de validez.

  . Automatización con triggers y procedimientos.

Tecnologías Usadas

  . SQL Server

  . T-SQL (Transact-SQL)


Orden de Ejecución

01_Creacion_Base_datos_y_Tablas.sql -->
Crea la base de datos y todas las tablas necesarias.

02_Inserts_en_Tablas.sql -->
Llena las tablas con datos de prueba.

04_Triggers.sql -->
Define acciones automáticas como la actualización del inventario después de una venta.

05_Stored_Procedures.sql -->
Contiene procedimientos para tareas frecuentes como registrar ventas, reportar productos por agotarse, etc.

06_Views.sql -->
Crea vistas útiles para reportes como ventas por tienda, productos más vendidos, productos con descuento, etc.

03_Consultas.sql (opcional) -->
Incluye consultas SELECT útiles para exploración de datos o generación de reportes.



Diagrama Entidad-Relación

El diagrama ER del modelo fue generado con SQL Server Management Studio y se encuentra en la carpeta /docs.
