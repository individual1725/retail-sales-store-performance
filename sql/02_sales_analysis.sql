USE retail_analysis;


-- =========================================================
-- 1. OVERALL SALES KPIs
-- =========================================================
-- Measures orders, units sold, revenue, COGS, gross profit,
-- gross margin and average order value.
--
-- Revenue is calculated using the USD unit price from Products.
-- Sales transactions may be recorded in multiple currencies,
-- so this analysis uses the product's USD price as the common
-- financial basis.

SELECT
    COUNT(DISTINCT s.Order_Number) AS total_orders,

    SUM(s.Quantity) AS units_sold,

    ROUND(
        SUM(s.Quantity * p.Unit_Price_USD),
        2
    ) AS total_revenue,

    ROUND(
        SUM(s.Quantity * p.Unit_Cost_USD),
        2
    ) AS total_cogs,

    ROUND(
        SUM(
            s.Quantity *
            (p.Unit_Price_USD - p.Unit_Cost_USD)
        ),
        2
    ) AS gross_profit,

    ROUND(
        SUM(
            s.Quantity *
            (p.Unit_Price_USD - p.Unit_Cost_USD)
        )
        /
        SUM(
            s.Quantity * p.Unit_Price_USD
        ) * 100,
        2
    ) AS gross_margin,

    ROUND(
        SUM(
            s.Quantity * p.Unit_Price_USD
        )
        /
        COUNT(DISTINCT s.Order_Number),
        2
    ) AS average_order_value

FROM sales AS s

JOIN products AS p
    ON s.ProductKey = p.ProductKey;


-- =========================================================
-- 2. MONTHLY SALES PERFORMANCE
-- =========================================================
-- Tracks orders, units, revenue, COGS and gross profit
-- over time.

SELECT
    DATE_FORMAT(s.Order_Date, '%Y-%m') AS month,

    COUNT(DISTINCT s.Order_Number) AS orders,

    SUM(s.Quantity) AS units_sold,

    ROUND(
        SUM(s.Quantity * p.Unit_Price_USD),
        2
    ) AS revenue,

    ROUND(
        SUM(s.Quantity * p.Unit_Cost_USD),
        2
    ) AS cogs,

    ROUND(
        SUM(
            s.Quantity *
            (p.Unit_Price_USD - p.Unit_Cost_USD)
        ),
        2
    ) AS gross_profit,

    ROUND(
        SUM(
            s.Quantity * p.Unit_Price_USD
        )
        /
        COUNT(DISTINCT s.Order_Number),
        2
    ) AS average_order_value

FROM sales AS s

JOIN products AS p
    ON s.ProductKey = p.ProductKey

GROUP BY
    DATE_FORMAT(s.Order_Date, '%Y-%m')

ORDER BY
    month;


-- =========================================================
-- 3. MONTHLY GROSS MARGIN
-- =========================================================
-- Measures profitability percentage by month.

SELECT
    DATE_FORMAT(s.Order_Date, '%Y-%m') AS month,

    ROUND(
        SUM(
            s.Quantity *
            (p.Unit_Price_USD - p.Unit_Cost_USD)
        )
        /
        SUM(
            s.Quantity * p.Unit_Price_USD
        ) * 100,
        2
    ) AS gross_margin

FROM sales AS s

JOIN products AS p
    ON s.ProductKey = p.ProductKey

GROUP BY
    DATE_FORMAT(s.Order_Date, '%Y-%m')

ORDER BY
    month;


-- =========================================================
-- 4. SALES BY COUNTRY
-- =========================================================
-- Compares geographic sales performance.

SELECT
    st.Country,

    COUNT(DISTINCT s.Order_Number) AS orders,

    SUM(s.Quantity) AS units_sold,

    ROUND(
        SUM(
            s.Quantity * p.Unit_Price_USD
        ),
        2
    ) AS revenue,

    ROUND(
        SUM(
            s.Quantity *
            (p.Unit_Price_USD - p.Unit_Cost_USD)
        ),
        2
    ) AS gross_profit

FROM sales AS s

JOIN stores AS st
    ON s.StoreKey = st.StoreKey

JOIN products AS p
    ON s.ProductKey = p.ProductKey

GROUP BY
    st.Country

ORDER BY
    revenue DESC;


-- =========================================================
-- 5. SALES BY CURRENCY
-- =========================================================
-- Compares transaction volume across currencies.
-- Exchange rates are not used here because the product
-- prices are already represented in USD.

SELECT
    s.Currency_Code,

    COUNT(DISTINCT s.Order_Number) AS orders,

    SUM(s.Quantity) AS units_sold,

    ROUND(
        SUM(
            s.Quantity * p.Unit_Price_USD
        ),
        2
    ) AS revenue

FROM sales AS s

JOIN products AS p
    ON s.ProductKey = p.ProductKey

GROUP BY
    s.Currency_Code

ORDER BY
    revenue DESC;


-- =========================================================
-- 6. AVERAGE UNITS PER ORDER
-- =========================================================

SELECT
    ROUND(
        SUM(Quantity)
        /
        COUNT(DISTINCT Order_Number),
        2
    ) AS average_units_per_order
FROM sales;


-- =========================================================
-- 7. ORDER LINE DISTRIBUTION
-- =========================================================
-- Shows whether customers tend to purchase one or multiple
-- products within an order.

WITH order_summary AS (
    SELECT
        Order_Number,
        COUNT(*) AS line_items
    FROM sales
    GROUP BY Order_Number
)

SELECT
    line_items,
    COUNT(*) AS orders
FROM order_summary
GROUP BY line_items
ORDER BY line_items;


-- =========================================================
-- 8. DELIVERY TIME
-- =========================================================
-- Measures the number of days between order and delivery.

SELECT
    ROUND(
        AVG(
            DATEDIFF(
                Delivery_Date,
                Order_Date
            )
        ),
        2
    ) AS average_delivery_days,

    MIN(
        DATEDIFF(
            Delivery_Date,
            Order_Date
        )
    ) AS minimum_delivery_days,

    MAX(
        DATEDIFF(
            Delivery_Date,
            Order_Date
        )
    ) AS maximum_delivery_days

FROM sales;


-- =========================================================
-- 9. DELIVERY PERFORMANCE BY COUNTRY
-- =========================================================

SELECT
    st.Country,

    ROUND(
        AVG(
            DATEDIFF(
                s.Delivery_Date,
                s.Order_Date
            )
        ),
        2
    ) AS average_delivery_days

FROM sales AS s

JOIN stores AS st
    ON s.StoreKey = st.StoreKey

GROUP BY
    st.Country

ORDER BY
    average_delivery_days;
