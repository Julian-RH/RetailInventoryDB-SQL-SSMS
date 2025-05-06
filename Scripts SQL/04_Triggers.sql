									--			T R I G G E R S			--
		

			-- TRIGGER QUE PROCESA LAS DEVOLUCIONES


CREATE TRIGGER trg_ProcesarDevolucion
ON Devoluciones
AFTER INSERT
AS
BEGIN
    SET NOCOUNT ON;

    -- Procesar cada fila insertada
    DECLARE @VentaID INT, @ProductoID INT, @Cantidad INT, @TiendaID INT;

    DECLARE devolucion_cursor CURSOR FOR
        SELECT VentaID, ProductoID, Cantidad
        FROM INSERTED;

    OPEN devolucion_cursor;
    FETCH NEXT FROM devolucion_cursor INTO @VentaID, @ProductoID, @Cantidad;

    WHILE @@FETCH_STATUS = 0
    BEGIN
        -- Obtener el TiendaID correspondiente
        SELECT @TiendaID = v.TiendaID
        FROM Ventas v
        WHERE v.VentaID = @VentaID;

        -- Actualizar inventario
        UPDATE Inventario
        SET CantidadActual = CantidadActual + @Cantidad
        WHERE TiendaID = @TiendaID AND ProductoID = @ProductoID;

        -- Reducir la cantidad en DetalleVenta
        UPDATE DetalleVenta
        SET Cantidad = Cantidad - @Cantidad
        WHERE VentaID = @VentaID AND ProductoID = @ProductoID;

        -- Si después de la devolución la cantidad quedó en 0, eliminar el detalle
        DELETE FROM DetalleVenta
        WHERE VentaID = @VentaID AND ProductoID = @ProductoID AND Cantidad <= 0;

        -- Si ya no hay detalles para la venta, eliminar la venta
        IF NOT EXISTS (SELECT 1 FROM DetalleVenta WHERE VentaID = @VentaID)
        BEGIN
            DELETE FROM Ventas WHERE VentaID = @VentaID;
        END

        FETCH NEXT FROM devolucion_cursor INTO @VentaID, @ProductoID, @Cantidad;
    END

    CLOSE devolucion_cursor;
    DEALLOCATE devolucion_cursor;
END;



			-- TRIGER QUE APLICA DESCUENTO A LOS PRODUCTOS QUE APLICAN


CREATE TRIGGER trg_AplicarDescuento
ON DetalleVenta
AFTER INSERT
AS
BEGIN
    SET NOCOUNT ON;

    -- Actualiza PrecioUnitario con el descuento si hay promoción vigente
    UPDATE dv
    SET PrecioUnitario = 
        CASE 
            WHEN pr.PromocionID IS NOT NULL 
                THEN p.PrecioVenta * (1 - pr.DescuentoPorc / 100.0)
            ELSE p.PrecioVenta
        END
    FROM DetalleVenta dv
    INNER JOIN INSERTED i ON dv.DetalleID = i.DetalleID
    INNER JOIN Productos p ON i.ProductoID = p.ProductoID
    LEFT JOIN Promociones pr 
        ON pr.ProductoID = i.ProductoID 
        AND CAST(GETDATE() AS DATE) BETWEEN pr.FechaInicio AND pr.FechaFin
    WHERE dv.DetalleID = i.DetalleID;
END;



			-- TRIGGER QUE REDUCE EL INVENTARIO DE LA TIENDA CORRESPONDIENTE DESPUÉS DE UNA VENTA


CREATE TRIGGER trg_ReducirInventario
ON DetalleVenta
AFTER INSERT
AS
BEGIN
    SET NOCOUNT ON;

    -- Actualizar el inventario restando la cantidad vendida
    UPDATE inv
    SET inv.CantidadActual = inv.CantidadActual - i.Cantidad
    FROM Inventario inv
    INNER JOIN INSERTED i ON inv.ProductoID = i.ProductoID
    INNER JOIN Ventas v ON v.VentaID = i.VentaID
    WHERE inv.TiendaID = v.TiendaID;
END;



			-- TRIGGER QUE VALIDE LAS DEVOLUCIONES


CREATE TRIGGER trg_ValidarDevolucion
ON Devoluciones
INSTEAD OF INSERT
AS
BEGIN
    SET NOCOUNT ON;

    IF EXISTS (
        SELECT 1
        FROM INSERTED i
        LEFT JOIN Ventas v ON i.VentaID = v.VentaID
        WHERE v.VentaID IS NULL
    )
    BEGIN
        RAISERROR('La venta no existe.', 16, 1);
        RETURN;
    END

    IF EXISTS (
        SELECT 1
        FROM INSERTED i
        LEFT JOIN DetalleVenta dv ON i.VentaID = dv.VentaID AND i.ProductoID = dv.ProductoID
        WHERE dv.VentaID IS NULL
    )
    BEGIN
        RAISERROR('El producto no forma parte de la venta especificada.', 16, 1);
        RETURN;
    END

    IF EXISTS (
        SELECT 1
        FROM INSERTED i
        INNER JOIN (
            SELECT VentaID, ProductoID, SUM(Cantidad) AS CantDevuelta
            FROM Devoluciones
            GROUP BY VentaID, ProductoID
        ) d ON i.VentaID = d.VentaID AND i.ProductoID = d.ProductoID
        INNER JOIN DetalleVenta dv ON i.VentaID = dv.VentaID AND i.ProductoID = dv.ProductoID
        WHERE ISNULL(d.CantDevuelta, 0) + i.Cantidad > dv.Cantidad
    )
    BEGIN
        RAISERROR('La cantidad devuelta excede la cantidad vendida.', 16, 1);
        RETURN;
    END

    -- Si todo está bien, insertar la devolución
    INSERT INTO Devoluciones (VentaID, ProductoID, Cantidad, Motivo)
    SELECT VentaID, ProductoID, Cantidad, Motivo
    FROM INSERTED;
END;

