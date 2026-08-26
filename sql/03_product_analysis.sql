USE retail_analysis;


-- =========================================================
-- 1. PRODUCT PERFORMANCE
-- =========================================================
-- Measures units sold, revenue, COGS, gross profit,
-- gross margin and average selling price.

SELECT
    p.ProductKey,
    p.Product_Name,
    p.Brand,
    p.Category,
    p.Subcategory,

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
        AVG(p.Unit_Price_USD),
        2
    ) AS unit_price

FROM sales AS s

JOIN products AS p
    ON s.ProductKey = p.ProductKey

GROUP BY
    p.ProductKey,
    p.Product_Name,
    p.Brand,
    p.Category,
    p.Subcategory

ORDER BY
    revenue DESC;


-- =========================================================
-- 2. TOP 10 PRODUCTS BY REVENUE
-- =========================================================

SELECT
    p.ProductKey,
    p.Product_Name,

    SUM(s.Quantity) AS units_sold,

    ROUND(
        SUM(s.Quantity * p.Unit_Price_USD),
        2
    ) AS revenue

FROM sales AS s

JOIN products AS p
    ON s.ProductKey = p.ProductKey

GROUP BY
    p.ProductKey,
    p.Product_Name

ORDER BY
    revenue DESC

LIMIT 10;


-- =========================================================
-- 3. TOP 10 PRODUCTS BY GROSS PROFIT
-- =========================================================

SELECT
    p.ProductKey,
    p.Product_Name,

    SUM(s.Quantity) AS units_sold,

    ROUND(
        SUM(
            s.Quantity *
            (p.Unit_Price_USD - p.Unit_Cost_USD)
        ),
        2
    ) AS gross_profit

FROM sales AS s

JOIN products AS p
    ON s.ProductKey = p.ProductKey

GROUP BY
    p.ProductKey,
    p.Product_Name

ORDER BY
    gross_profit DESC

LIMIT 10;


-- =========================================================
-- 4. PRODUCT GROSS MARGIN
-- =========================================================
-- Identifies products with the strongest and weakest
-- profitability percentages.

SELECT
    p.ProductKey,
    p.Product_Name,

    SUM(s.Quantity) AS units_sold,

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
    p.ProductKey,
    p.Product_Name

HAVING
    SUM(s.Quantity * p.Unit_Price_USD) > 0

ORDER BY
    gross_margin DESC;


-- =========================================================
-- 5. PRODUCT REVENUE SHARE
-- =========================================================
-- Measures each product's contribution to total revenue.

WITH product_sales AS (
    SELECT
        p.ProductKey,
        p.Product_Name,
        SUM(
            s.Quantity * p.Unit_Price_USD
        ) AS revenue
    FROM sales AS s
    JOIN products AS p
        ON s.ProductKey = p.ProductKey
    GROUP BY
        p.ProductKey,
        p.Product_Name
)

SELECT
    ProductKey,
    Product_Name,

    ROUND(
        revenue,
        2
    ) AS revenue,

    ROUND(
        revenue
        /
        SUM(revenue) OVER ()
        * 100,
        2
    ) AS revenue_share

FROM product_sales

ORDER BY
    revenue DESC;


-- =========================================================
-- 6. CATEGORY PERFORMANCE
-- =========================================================

SELECT
    p.Category,

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
    ) AS gross_margin

FROM sales AS s

JOIN products AS p
    ON s.ProductKey = p.ProductKey

GROUP BY
    p.Category

ORDER BY
    revenue DESC;


-- =========================================================
-- 7. SUBCATEGORY PERFORMANCE
-- =========================================================

SELECT
    p.Category,
    p.Subcategory,

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
    ) AS gross_margin

FROM sales AS s

JOIN products AS p
    ON s.ProductKey = p.ProductKey

GROUP BY
    p.Category,
    p.Subcategory

ORDER BY
    revenue DESC;


-- =========================================================
-- 8. BRAND PERFORMANCE
-- =========================================================

SELECT
    p.Brand,

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
    ) AS gross_margin

FROM sales AS s

JOIN products AS p
    ON s.ProductKey = p.ProductKey

GROUP BY
    p.Brand

ORDER BY
    revenue DESC;


-- =========================================================
-- 9. LOW-VOLUME HIGH-MARGIN PRODUCTS
-- =========================================================
-- Identifies products that sell relatively few units but
-- generate strong margins.

SELECT
    p.ProductKey,
    p.Product_Name,

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
    p.ProductKey,
    p.Product_Name

HAVING
    SUM(s.Quantity) < 100
    AND
    SUM(s.Quantity * p.Unit_Price_USD) > 0

ORDER BY
    gross_margin DESC;


-- =========================================================
-- 10. HIGH-REVENUE LOW-MARGIN PRODUCTS
-- =========================================================
-- Identifies products where strong sales volume may be
-- accompanied by weaker profitability.

SELECT
    p.ProductKey,
    p.Product_Name,

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
    ) AS gross_margin

FROM sales AS s

JOIN products AS p
    ON s.ProductKey = p.ProductKey

GROUP BY
    p.ProductKey,
    p.Product_Name

HAVING
    SUM(s.Quantity * p.Unit_Price_USD) > 100000

ORDER BY
    gross_margin ASC;
