USE retail_analysis;


-- =========================================================
-- 1. TABLE ROW COUNTS
-- =========================================================

SELECT
    'sales' AS table_name,
    COUNT(*) AS row_count
FROM sales

UNION ALL

SELECT
    'customers',
    COUNT(*)
FROM customers

UNION ALL

SELECT
    'products',
    COUNT(*)
FROM products

UNION ALL

SELECT
    'stores',
    COUNT(*)
FROM stores

UNION ALL

SELECT
    'exchange_rates',
    COUNT(*)
FROM exchange_rates;


-- =========================================================
-- 2. SALES DATE RANGE
-- =========================================================

SELECT
    MIN(Order_Date) AS first_order_date,
    MAX(Order_Date) AS last_order_date
FROM sales;


-- =========================================================
-- 3. DELIVERY PERFORMANCE
-- =========================================================

SELECT
    MIN(Delivery_Date) AS first_delivery_date,
    MAX(Delivery_Date) AS last_delivery_date
FROM sales;


-- =========================================================
-- 4. TOTAL ORDERS
-- =========================================================

SELECT
    COUNT(DISTINCT Order_Number) AS total_orders
FROM sales;


-- =========================================================
-- 5. TOTAL CUSTOMERS
-- =========================================================

SELECT
    COUNT(*) AS total_customers
FROM customers;


-- =========================================================
-- 6. PRODUCT OVERVIEW
-- =========================================================

SELECT
    ProductKey,
    Product_Name,
    Brand,
    Category,
    Subcategory,
    Unit_Cost_USD,
    Unit_Price_USD
FROM products
ORDER BY ProductKey;


-- =========================================================
-- 7. STORE OVERVIEW
-- =========================================================

SELECT
    StoreKey,
    Country,
    State,
    `Square Meters`,
    `Open Date`
FROM stores
ORDER BY StoreKey;


-- =========================================================
-- 8. SALES BY CURRENCY
-- =========================================================

SELECT
    Currency_Code,
    COUNT(*) AS sales_lines,
    SUM(Quantity) AS units_sold
FROM sales
GROUP BY Currency_Code
ORDER BY sales_lines DESC;


-- =========================================================
-- 9. SALES BY COUNTRY
-- =========================================================

SELECT
    st.Country,
    COUNT(DISTINCT s.Order_Number) AS orders,
    SUM(s.Quantity) AS units_sold
FROM sales AS s
JOIN stores AS st
    ON s.StoreKey = st.StoreKey
GROUP BY st.Country
ORDER BY orders DESC;


-- =========================================================
-- 10. SALES BY PRODUCT CATEGORY
-- =========================================================

SELECT
    p.Category,
    COUNT(DISTINCT s.Order_Number) AS orders,
    SUM(s.Quantity) AS units_sold
FROM sales AS s
JOIN products AS p
    ON s.ProductKey = p.ProductKey
GROUP BY p.Category
ORDER BY units_sold DESC;