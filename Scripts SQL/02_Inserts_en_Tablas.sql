-- LLENADO DE TABLAS
INSERT INTO Tiendas (Nombre, Ciudad, Estado, FechaApertura)
VALUES 
('Tienda Centro', 'Monterrey', 'Nuevo Le�n', '2015-06-01'),
('Tienda Norte', 'Saltillo', 'Coahuila', '2018-09-15'),
('Tienda Sur', 'Guadalajara', 'Jalisco', '2020-03-10');

INSERT INTO Productos (Nombre, Categoria, PrecioVenta, CostoUnitario, Activo)
VALUES 
('Laptop HP', 'Tecnolog�a', 15500.00, 12000.00, 1),
('Mouse Logitech', 'Accesorios', 350.00, 200.00, 1),
('Silla Ergon�mica', 'Muebles', 2100.00, 1600.00, 1),
('Monitor LG', 'Tecnolog�a', 4200.00, 3000.00, 1),
('Teclado Mec�nico', 'Accesorios', 850.00, 600.00, 1),
('Tablet Samsung', 'Tecnolog�a', 6500.00, 5000.00, 1),
('Aud�fonos Sony', 'Accesorios', 1200.00, 800.00, 1),
('Escritorio Ejecutivo', 'Muebles', 5200.00, 4000.00, 1),
('Impresora Epson', 'Tecnolog�a', 3900.00, 2900.00, 1),
('Mousepad Gamer', 'Accesorios', 250.00, 100.00, 1),
('L�mpara LED de Escritorio', 'Accesorios', 700.00, 450.00, 1),
('Gabinete para PC', 'Tecnolog�a', 2800.00, 2000.00, 1),
('Silla Gamer', 'Muebles', 4200.00, 3000.00, 1),
('C�mara Web Logitech', 'Accesorios', 1500.00, 1100.00, 1),
('Router TP-Link', 'Tecnolog�a', 1300.00, 950.00, 1),
('Teclado Inal�mbrico', 'Accesorios', 900.00, 600.00, 1),
('Disco Duro Externo 1TB', 'Tecnolog�a', 1800.00, 1300.00, 1),
('Panel Divisor de Oficina', 'Muebles', 2400.00, 1900.00, 1),
('Multicontacto con USB', 'Accesorios', 300.00, 180.00, 1),
('Monitor Curvo Samsung', 'Tecnolog�a', 5600.00, 4200.00, 1),
('Estaci�n de Caf�', 'Muebles', 3100.00, 2500.00, 1),
('Proyector BenQ', 'Tecnolog�a', 7200.00, 5800.00, 1);

INSERT INTO Inventario (TiendaID, ProductoID, CantidadActual)
VALUES 
(1, 3, 15),
(1, 4, 8),
(1, 6, 7),
(1, 7, 18),
(1, 8, 5),
(1, 10, 25),
(1, 12, 9),
(1, 13, 6),
(2, 2, 30),
(2, 5, 10),
(2, 6, 12),
(2, 9, 20),
(2, 11, 14),
(2, 14, 10),
(2, 15, 13),
(2, 17, 6),
(3, 1, 4),
(3, 2, 25),
(3, 4, 10),
(3, 6, 8),
(3, 7, 9),
(3, 10, 30),
(3, 11, 11),
(3, 16, 7),
(3, 18, 10),
(3, 20, 3),
(3, 21, 4);

INSERT INTO Proveedores (Nombre, Contacto, Telefono)
VALUES 
('TechSolutions MX', 'Mar�a Gonz�lez', '8112345678'),
('Distribuidora LogiMex', 'Luis Ram�rez', '8187654321'),
('Muebles Ergon�micos SA', 'Paola M�ndez', '8122334455'),
('Accesorios GDL', 'Carlos L�pez', '8188889999'),
('ElectroSmart', 'Laura Torres', '8199001122'),
('Mundo Oficina', 'Jorge Mart�nez', '8144556677'),
('DTN (Distribuciones Tecnol�gicas del Norte)', 'Ana Ch�vez', '8111223344'),
('InnovaAccesorios', 'Diego Herrera', '8155667788'),
('GamerZone Proveedores', 'Valeria R�os', '8133445566'),
('OfiPro MX', 'Roberto Ortega', '8122446688');

INSERT INTO OrdenesCompra (ProveedorID, FechaOrden, Estado)
VALUES 
(1, '2024-05-01', 'Completada'),
(2, '2024-05-03', 'Pendiente'),
(3, '2024-04-28', 'Completada'),
(4, '2024-05-04', 'Pendiente'),
(5, '2024-05-02', 'Completada'),
(6, '2024-04-30', 'Pendiente');

INSERT INTO DetalleOrden (OrdenID, ProductoID, Cantidad, PrecioUnitario)
VALUES 
(1, 1, 5, 12000.00),      -- Laptop HP
(1, 6, 3, 5000.00),       -- Tablet Samsung
(2, 2, 30, 200.00),       -- Mouse Logitech
(2, 10, 20, 100.00),      -- Mousepad Gamer
(3, 3, 10, 1600.00),      -- Silla Ergon�mica
(3, 13, 5, 3000.00),      -- Silla Gamer
(4, 5, 15, 600.00),       -- Teclado Mec�nico
(5, 4, 6, 3000.00),       -- Monitor LG
(6, 11, 10, 450.00);      -- L�mpara LED de Escritorio

INSERT INTO Promociones (ProductoID, DescuentoPorc, FechaInicio, FechaFin)
VALUES 
(1, 15.00, '2025-04-10', '2025-05-28'),   -- Laptop HP
(2, 10.00, '2025-04-10', '2025-05-28'),   -- Mouse Logitech
(4, 20.00, '2025-04-10', '2025-05-28'),   -- Monitor LG
(5, 15.00, '2025-04-10', '2025-05-28'),   -- Teclado Mec�nico
(7, 10.00, '2025-04-10', '2025-05-28'),   -- Aud�fonos Sony
(9, 12.00, '2025-04-10', '2025-05-28');   -- Impresora Epson

INSERT INTO Devoluciones (VentaID, ProductoID, Cantidad, Motivo)
VALUES 
(8,20, 2, 'No era compatible');



