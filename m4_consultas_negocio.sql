-- Motor utilizado: SQL Server
-- Módulo 4: Pre-entrega - Consultas SQL de negocio

USE Ventas_Tech_DB;
GO

-- ============================================================================
-- CONSULTA 1: Resumen ejecutivo mensual
-- Total facturado, cantidad de pedidos y ticket promedio agrupados por mes
-- ============================================================================
SELECT 
    MONTH(fecha_venta) AS mes,
    COUNT(id_venta) AS cantidad_pedidos,
    SUM(cantidad * precio_unitario) AS total_facturado,
    CAST(AVG(cantidad * precio_unitario) AS DECIMAL(10,2)) AS ticket_promedio
FROM ventas
GROUP BY MONTH(fecha_venta)
ORDER BY mes;
GO

-- ============================================================================
-- CONSULTA 2: Top 5 de productos
-- Top 5 de id_producto por total facturado, mostrando unidades y total generado
-- ============================================================================
SELECT TOP 5
    id_producto,
    SUM(cantidad) AS unidades_vendidas,
    SUM(cantidad * precio_unitario) AS total_facturado
FROM ventas
GROUP BY id_producto
ORDER BY total_facturado DESC;
GO

-- ============================================================================
-- CONSULTA 3: Clientes recurrentes
-- Clientes con más de un pedido, cantidad de pedidos y total gastado
-- ============================================================================
SELECT 
    id_cliente,
    COUNT(id_venta) AS cantidad_pedidos,
    SUM(cantidad * precio_unitario) AS total_gastado
FROM ventas
GROUP BY id_cliente
HAVING COUNT(id_venta) > 1
ORDER BY total_gastado DESC;
GO

-- ============================================================================
-- CONSULTA 4: Productos por encima y por debajo del promedio
-- Compara la facturación total de cada producto contra el promedio por producto
-- ============================================================================
WITH VentasPorProducto AS (
    SELECT 
        id_producto,
        SUM(cantidad * precio_unitario) AS total_producto
    FROM ventas
    GROUP BY id_producto
)
SELECT 
    id_producto,
    total_producto,
    CASE 
        WHEN total_producto > (SELECT AVG(total_producto) FROM VentasPorProducto) THEN 'Por encima'
        ELSE 'Por debajo'
    END AS rendimiento_vs_promedio
FROM VentasPorProducto
ORDER BY total_producto DESC;
GO

-- ============================================================================
-- HALLAZGOS DE NEGOCIO
-- ============================================================================
-- #1 Alta concentración de ingresos en productos de ticket alto, pues solo 3 unidades vendidas del producto 1, representa el 61.3% del total facturado.
--
-- #2 Los productos de mayor volumen de venta es el producto más económico, que genera poco en el total facturado, ubicándose muy por debajo del promedio de facturación por producto ($979.00) 
--
-- #3 Los clientes que más compran tienden a hacer dos pedidos al mes. Es decir, llevaron dos o más productos al mes en dos momentos diferentes. Esto indica que hacen compras recurrentes durante el mes.