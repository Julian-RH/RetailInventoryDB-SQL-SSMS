							--			S T O R E D    P R O C E D U R E S			--

			-- STORED PROCEDURE PARA CREAR UNA VENTA 

--Se define una plantilla de tabla que se usará como parámetro dentro del SP
CREATE TYPE DetalleVentaTipo AS TABLE ( 
    ProductoID INT,
    Cantidad INT
);

CREATE PROCEDURE CrearVenta
    @TiendaID INT,
    @Fecha DATETIME,
    @DetalleVentaDetalle DetalleVentaTipo READONLY
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        BEGIN TRANSACTION;

        -- 0. Validar que la tienda exista
        IF NOT EXISTS (
            SELECT 1
            FROM Tiendas
            WHERE TiendaID = @TiendaID
        )
        BEGIN
            RAISERROR('La tienda especificada no existe.', 16, 1);
            ROLLBACK TRANSACTION;
            RETURN;
        END

        -- 1. Validar inventario: que haya stock suficiente en la tienda para todos los productos
        IF EXISTS (
            SELECT 1
            FROM @DetalleVentaDetalle d
            LEFT JOIN Inventario inv 
                ON d.ProductoID = inv.ProductoID AND inv.TiendaID = @TiendaID
            WHERE inv.ProductoID IS NULL -- no hay inventario en esa tienda
               OR d.Cantidad > inv.CantidadActual -- no hay suficiente cantidad
        )
        BEGIN
            RAISERROR('Uno o más productos no tienen suficiente inventario en la tienda.', 16, 1);
            ROLLBACK TRANSACTION;
            RETURN;
        END

        DECLARE @VentaID INT;
        DECLARE @ProductoID INT;
        DECLARE @Cantidad INT;
        DECLARE @PrecioVenta DECIMAL(10,2);

        -- 2. Insertar la venta
        INSERT INTO Ventas (TiendaID, Fecha, Total)
        VALUES (@TiendaID, @Fecha, 0.00);

        SET @VentaID = SCOPE_IDENTITY();

        -- 3. Recorrer productos
        DECLARE detalle_cursor CURSOR FOR
            SELECT ProductoID, Cantidad FROM @DetalleVentaDetalle;

        OPEN detalle_cursor;
        FETCH NEXT FROM detalle_cursor INTO @ProductoID, @Cantidad;

        WHILE @@FETCH_STATUS = 0
        BEGIN
            SELECT @PrecioVenta = PrecioVenta 
            FROM Productos 
            WHERE ProductoID = @ProductoID;

            INSERT INTO DetalleVenta (VentaID, ProductoID, Cantidad, PrecioUnitario)
            VALUES (@VentaID, @ProductoID, @Cantidad, @PrecioVenta);

            FETCH NEXT FROM detalle_cursor INTO @ProductoID, @Cantidad;
        END

        CLOSE detalle_cursor;
        DEALLOCATE detalle_cursor;

        -- 4. Actualizar total
        UPDATE v
        SET Total = (
            SELECT SUM(Cantidad * PrecioUnitario)
            FROM DetalleVenta
            WHERE VentaID = v.VentaID
        )
        FROM Ventas v
        WHERE VentaID = @VentaID;

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;

        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        RAISERROR(@ErrorMessage, 16, 1);
    END CATCH
END;


-- PARA EJECUTAR EL SP se crea una tabla temporal del tipo de tabla que se definió previamente
DECLARE @Detalles DetalleVentaTipo;
-- Se agregan los productos y cantidades que se venden
INSERT INTO @Detalles VALUES (21, 1);  

 
 -- Ahora sí, se ejecuta el SP con los respectivos parámetros
DECLARE @fechaActual DATETIME = GETDATE(); -- Se establece la fecha actual antes de ejecutar

EXEC CrearVenta 
    @TiendaID = 3, 
    @Fecha = @fechaActual, 
    @DetalleVentaDetalle = @Detalles;



			-- STORED PROCEDURE PARA VER LA LISTA DE PRODUCTOS VENDIDOS EN BASE AL ID DE LA VENTA


CREATE PROCEDURE VerVentaPorID
    @VentaID INT
AS
BEGIN
    SET NOCOUNT ON;

    SELECT 
        v.VentaID,
        v.Fecha,
        t.Nombre AS Tienda,
        p.ProductoID,
        p.Nombre AS Producto,
        dv.Cantidad,
        dv.PrecioUnitario,
        (dv.Cantidad * dv.PrecioUnitario) AS Subtotal,
        CASE 
            WHEN pr.PromocionID IS NOT NULL THEN 'Sí'
            ELSE 'No'
        END AS DescuentoAplicado,
        pr.DescuentoPorc AS PorcentajeDescuento
    FROM Ventas v
    INNER JOIN Tiendas t ON v.TiendaID = t.TiendaID
    INNER JOIN DetalleVenta dv ON v.VentaID = dv.VentaID
    INNER JOIN Productos p ON dv.ProductoID = p.ProductoID
    LEFT JOIN Promociones pr ON 
        pr.ProductoID = p.ProductoID AND
        CAST(v.Fecha AS DATE) BETWEEN pr.FechaInicio AND pr.FechaFin
    WHERE v.VentaID = @VentaID;
END;

-- PARA SU EJECUCIÓN
EXEC VerVentaPorID @VentaID = 12



			-- STORED PROCEDURE QUE AGREGA MÁS INVENTARIO

	
CREATE PROCEDURE AgregarInventario 
    @TiendaID INT,
    @ProductoID INT,
    @Cantidad INT
AS
BEGIN
    SET NOCOUNT ON;

    -- Validar que exista la tienda
    IF NOT EXISTS (SELECT 1 FROM Tiendas WHERE TiendaID = @TiendaID)
    BEGIN
        RAISERROR('La tienda especificada no existe.', 16, 1);
        RETURN;
    END

    -- Validar que exista el producto
    IF NOT EXISTS (SELECT 1 FROM Productos WHERE ProductoID = @ProductoID)
    BEGIN
        RAISERROR('El producto especificado no existe.', 16, 1);
        RETURN;
    END

    -- Si pasa las validaciones, entonces insertar o actualizar inventario
    IF EXISTS (
        SELECT 1 FROM Inventario 
        WHERE TiendaID = @TiendaID AND ProductoID = @ProductoID
    )
    BEGIN
        -- Ya existe: actualiza la cantidad
        UPDATE Inventario
        SET CantidadActual = CantidadActual + @Cantidad
        WHERE TiendaID = @TiendaID AND ProductoID = @ProductoID;
    END
    ELSE
    BEGIN
        -- Nuevo registro
        INSERT INTO Inventario (TiendaID, ProductoID, CantidadActual)
        VALUES (@TiendaID, @ProductoID, @Cantidad);
    END
END;

-- PARA SU EJECUCIÓN
EXEC AgregarInventario @TiendaID = 1,@ProductoID = 4, @Cantidad = 3;



			-- STORED PROCEDURE QUE MUESTRA LOS PRODUCTOS QUE ESTAN POR AGOTARSE(MENOS DE 5 UNIDADES)


CREATE PROCEDURE ProductosProximosAgotarse
    @TiendaID INT,
    @Umbral INT = 5
AS
BEGIN
    SELECT 
        p.ProductoID,
        p.Nombre,
        i.CantidadActual,
        ISNULL(SUM(CASE WHEN v.TiendaID = @TiendaID THEN dv.Cantidad ELSE 0 END), 0) AS TotalVentasRegistradas
    FROM Inventario i
    JOIN Productos p ON i.ProductoID = p.ProductoID
    LEFT JOIN DetalleVenta dv ON p.ProductoID = dv.ProductoID
    LEFT JOIN Ventas v ON dv.VentaID = v.VentaID
    WHERE i.TiendaID = @TiendaID AND i.CantidadActual <= @Umbral
    GROUP BY p.ProductoID, p.Nombre, i.CantidadActual;
END;


-- PARA SU EJECUCIÓN SE PONE SOLAMENTE EL ID DE LA TIENDA
EXEC ProductosProximosAgotarse @TiendaID = 3



			-- STORED PROCEDURE QUE MUESTRA EL INVNETARIO ACTUAL EN BASE AL ID DE LA TIENDA


CREATE PROCEDURE InventarioPorTienda
    @TiendaID INT
AS
BEGIN
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
    WHERE i.TiendaID = @TiendaID
    ORDER BY i.ProductoID;
END;

-- PARA EJECUTARLO SOLO SE INGRESA EL ID DE LA TIENDA
EXEC InventarioPorTienda @TiendaID = 2

