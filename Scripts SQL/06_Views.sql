									--			   V I E W S			--

		-- VISTA PARA VER LAS VENTAS REALIZADAS POR TIENDAS
CREATE VIEW vw_VentasPorTienda AS
SELECT t.Nombre AS Tienda, SUM(v.Total) AS TotalVentas
FROM Ventas v
JOIN Tiendas t ON v.TiendaID = t.TiendaID
GROUP BY t.Nombre;

SELECT * FROM vw_VentasPorTienda



		-- VISTA DEL HISTORIAL DE VENTAS DE TODAS LAS TIENDAS
CREATE VIEW vw_HistorialVentas AS
SELECT 
    v.VentaID,
    v.Fecha,
    t.Nombre AS Tienda,
    p.Nombre AS Producto,
    dv.Cantidad,
    dv.PrecioUnitario,
    dv.Cantidad * dv.PrecioUnitario AS Total
FROM Ventas v
JOIN Tiendas t ON v.TiendaID = t.TiendaID
JOIN DetalleVenta dv ON v.VentaID = dv.VentaID
JOIN Productos p ON dv.ProductoID = p.ProductoID;

SELECT * FROM vw_HistorialVentas



		-- VISTA PARA SABER LOS PRODUCTOS QUE TIENEN DESCUENTO Y VER LA DIFERENCIA DE PRECIOS
CREATE VIEW vw_ProductosConDescuento AS
SELECT 
    p.Nombre AS Producto,
    p.PrecioVenta AS PrecioOriginal,
    pr.DescuentoPorc AS PorcentajeDescuento,
    ROUND(p.PrecioVenta * (1 - pr.DescuentoPorc / 100), 2) AS PrecioConDescuento,
    pr.FechaInicio,
    pr.FechaFin
FROM 
    Productos p
JOIN 
    Promociones pr ON p.ProductoID = pr.ProductoID
WHERE 
    GETDATE() BETWEEN pr.FechaInicio AND pr.FechaFin;

SELECT * FROM vw_ProductosConDescuento



		-- VISTA DE PRODUCTOS CON BAJO STOCK
ALTER VIEW vw_ProductosBajoStock AS
SELECT 
    t.Nombre AS Tienda,
    p.Nombre AS Producto,
	p.ProductoID AS ProductoID,
    i.CantidadActual
FROM Inventario i
JOIN Tiendas t ON i.TiendaID = t.TiendaID
JOIN Productos p ON i.ProductoID = p.ProductoID
WHERE i.CantidadActual <= 5;

SELECT * FROM vw_ProductosBajoStock



		-- VISTA QUE MUESTRA EL INVENTARIO COMPLETO DE LAS TIENDAS
CREATE VIEW vw_InventarioActual AS
SELECT 
    t.Nombre AS Tienda,
    p.Nombre AS Producto,
    i.CantidadActual,
    i.FechaUltimaActualizacion
FROM Inventario i
JOIN Tiendas t ON i.TiendaID = t.TiendaID
JOIN Productos p ON i.ProductoID = p.ProductoID;

SELECT * FROM vw_InventarioActual



		-- VISTA QUE MUESTRA EL TOTAL DE VENTAS POR PRODUCTO
CREATE VIEW vw_VentasPorProducto AS
SELECT 
    p.ProductoID,
    p.Nombre AS Producto,
    SUM(dv.Cantidad) AS TotalVendido,
    SUM(dv.Cantidad * dv.PrecioUnitario) AS IngresoGenerado
FROM DetalleVenta dv
JOIN Productos p ON dv.ProductoID = p.ProductoID
GROUP BY p.ProductoID, p.Nombre;

SELECT * FROM vw_VentasPorProducto


