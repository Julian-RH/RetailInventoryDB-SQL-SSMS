									--			C O N S U L T A S			--
	
	
	-- CONSULTA PARA SABER LOS PRODUCTOS MÁS VENDIDOS 
SELECT 
    P.Nombre AS Producto,
    SUM(DV.Cantidad) AS TotalVendido
FROM DetalleVenta DV
JOIN Productos P ON DV.ProductoID = P.ProductoID
GROUP BY P.Nombre
ORDER BY TotalVendido DESC;

	-- CONSULTA PARA OBTENER LAS GANANCIAS ACTUALES POR TIENDA
SELECT 
    T.Nombre AS Tienda,
    SUM(DV.Cantidad * (DV.PrecioUnitario - P.CostoUnitario)) AS GananciaTotal
FROM Ventas V
JOIN Tiendas T ON V.TiendaID = T.TiendaID
JOIN DetalleVenta DV ON V.VentaID = DV.VentaID
JOIN Productos P ON DV.ProductoID = P.ProductoID
GROUP BY T.Nombre
ORDER BY GananciaTotal DESC;

	-- CONSULTA QUE MUESTRA EL INVENTARIO DE TODAS LAS TIENDAS DE MANERA ORDENADA Y CON NOMBRES
SELECT 
    i.TiendaID,
    t.Nombre AS NombreTienda,
    i.ProductoID,
    p.Nombre AS NombreProducto,
    i.CantidadActual,
    i.FechaUltimaActualizacion
FROM Inventario i
JOIN Productos p ON i.ProductoID = p.ProductoID
JOIN Tiendas t ON i.TiendaID = t.TiendaID
ORDER BY i.TiendaID, i.ProductoID;
