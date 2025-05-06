create database RetailInventoryDB
use RetailInventoryDB

-- TABLA TIENDAS
CREATE TABLE Tiendas (
    TiendaID INT IDENTITY PRIMARY KEY,
    Nombre VARCHAR(100) NOT NULL,
    Ciudad VARCHAR(50) NOT NULL,
    Estado VARCHAR(50) NOT NULL,
    FechaApertura DATE NOT NULL
);

-- TABLA PRODUCTOS
CREATE TABLE Productos (
    ProductoID INT IDENTITY PRIMARY KEY,
    Nombre VARCHAR(100) NOT NULL,
    Categoria VARCHAR(50) NOT NULL,
    PrecioVenta DECIMAL(10,2) NOT NULL,
    CostoUnitario DECIMAL(10,2) NOT NULL,
    Activo BIT DEFAULT 1
);

-- TABLA INVENTARIO
CREATE TABLE Inventario (
    InventarioID INT IDENTITY PRIMARY KEY,
    TiendaID INT NOT NULL,
    ProductoID INT NOT NULL,
    CantidadActual INT NOT NULL,
    FechaUltimaActualizacion DATETIME DEFAULT GETDATE(),
    FOREIGN KEY (TiendaID) REFERENCES Tiendas(TiendaID),
    FOREIGN KEY (ProductoID) REFERENCES Productos(ProductoID)
);

-- TABLA PROVEEDORES
CREATE TABLE Proveedores (
    ProveedorID INT IDENTITY PRIMARY KEY,
    Nombre VARCHAR(100) NOT NULL,
    Contacto VARCHAR(100),
    Telefono VARCHAR(20)
);

-- TABLA ORDENES COMPRA
CREATE TABLE OrdenesCompra (
    OrdenID INT IDENTITY PRIMARY KEY,
    ProveedorID INT NOT NULL,
    FechaOrden DATE NOT NULL,
    Estado VARCHAR(20) DEFAULT 'Pendiente',
    FOREIGN KEY (ProveedorID) REFERENCES Proveedores(ProveedorID)
);

-- TABLA DETALLE ORDEN
CREATE TABLE DetalleOrden (
    DetalleID INT IDENTITY PRIMARY KEY,
    OrdenID INT NOT NULL,
    ProductoID INT NOT NULL,
    Cantidad INT NOT NULL,
    PrecioUnitario DECIMAL(10,2) NOT NULL,
    FOREIGN KEY (OrdenID) REFERENCES OrdenesCompra(OrdenID),
    FOREIGN KEY (ProductoID) REFERENCES Productos(ProductoID)
);

-- TABLA VENTAS
CREATE TABLE Ventas (
    VentaID INT IDENTITY PRIMARY KEY,
    TiendaID INT NOT NULL,
    Fecha DATETIME DEFAULT GETDATE(),
    Total DECIMAL(10,2) NOT NULL,
    FOREIGN KEY (TiendaID) REFERENCES Tiendas(TiendaID)
);

-- TABLA DETALLE VENTA
CREATE TABLE DetalleVenta (
    DetalleID INT IDENTITY PRIMARY KEY,
    VentaID INT NOT NULL,
    ProductoID INT NOT NULL,
    Cantidad INT NOT NULL,
    PrecioUnitario DECIMAL(10,2) NOT NULL,
    FOREIGN KEY (VentaID) REFERENCES Ventas(VentaID),
    FOREIGN KEY (ProductoID) REFERENCES Productos(ProductoID)
);

-- TABLA PROMOCIONES
CREATE TABLE Promociones (
    PromocionID INT IDENTITY PRIMARY KEY,
    ProductoID INT NOT NULL,
    DescuentoPorc DECIMAL(5,2) NOT NULL,
    FechaInicio DATE NOT NULL,
    FechaFin DATE NOT NULL,
    FOREIGN KEY (ProductoID) REFERENCES Productos(ProductoID)
);

-- TABLA DEVOLUCIONES
CREATE TABLE Devoluciones (
    DevolucionID INT IDENTITY PRIMARY KEY,
    VentaID INT NOT NULL,
    ProductoID INT NOT NULL,
    Cantidad INT NOT NULL,
    Motivo VARCHAR(200) NOT NULL,
    Fecha DATETIME DEFAULT GETDATE(),
    FOREIGN KEY (VentaID) REFERENCES Ventas(VentaID),
    FOREIGN KEY (ProductoID) REFERENCES Productos(ProductoID)
);