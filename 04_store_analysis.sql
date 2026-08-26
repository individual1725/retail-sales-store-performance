USE retail_analysis;


-- =========================================================
-- 1. STORE PERFORMANCE
-- =========================================================
-- Measures orders, units, revenue, gross profit and
-- gross margin by store.

SELECT
    st.StoreKey,
    st.Country,
    st.State,
    st.`Square Meters`,
    st.`Open Date`,

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

JOIN stores AS st
    ON s.StoreKey = st.StoreKey

JOIN products AS p
    ON s.ProductKey = p.ProductKey

GROUP BY
    st.StoreKey,
    st.Country,
    st.State,
    st.`Square Meters`,
    st.`Open Date`

ORDER BY
    revenue DESC;


-- =========================================================
-- 2. COUNTRY PERFORMANCE
-- =========================================================
-- Compares geographic sales performance.

SELECT
    st.Country,

    COUNT(DISTINCT st.StoreKey) AS stores,

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

JOIN stores AS st
    ON s.StoreKey = st.StoreKey

JOIN products AS p
    ON s.ProductKey = p.ProductKey

GROUP BY
    st.Country

ORDER BY
    revenue DESC;


-- =========================================================
-- 3. REVENUE PER SQUARE METER
-- =========================================================
-- Measures store productivity relative to physical size.
--
-- StoreKey 0 represents Online and has no physical size,
-- so it is excluded.

SELECT
    st.StoreKey,
    st.Country,
    st.State,
    st.`Square Meters`,

    ROUND(
        SUM(
            s.Quantity * p.Unit_Price_USD
        ),
        2
    ) AS revenue,

    ROUND(
        SUM(
            s.Quantity * p.Unit_Price_USD
        )
        /
        st.`Square Meters`,
        2
    ) AS revenue_per_square_meter

FROM sales AS s

JOIN stores AS st
    ON s.StoreKey = st.StoreKey

JOIN products AS p
    ON s.ProductKey = p.ProductKey

WHERE
    st.StoreKey <> 0
    AND st.`Square Meters` > 0

GROUP BY
    st.StoreKey,
    st.Country,
    st.State,
    st.`Square Meters`

ORDER BY
    revenue_per_square_meter DESC;


-- =========================================================
-- 4. STORE SIZE VS REVENUE
-- =========================================================
-- Compares physical store size with revenue generation.

SELECT
    st.StoreKey,
    st.Country,
    st.State,
    st.`Square Meters`,

    ROUND(
        SUM(
            s.Quantity * p.Unit_Price_USD
        ),
        2
    ) AS revenue

FROM sales AS s

JOIN stores AS st
    ON s.StoreKey = st.StoreKey

JOIN products AS p
    ON s.ProductKey = p.ProductKey

WHERE
    st.StoreKey <> 0

GROUP BY
    st.StoreKey,
    st.Country,
    st.State,
    st.`Square Meters`

ORDER BY
    st.`Square Meters` DESC;


-- =========================================================
-- 5. ONLINE VS PHYSICAL SALES
-- =========================================================
-- StoreKey 0 represents the Online channel.

SELECT
    CASE
        WHEN st.StoreKey = 0 THEN 'Online'
        ELSE 'Physical Store'
    END AS sales_channel,

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
    CASE
        WHEN st.StoreKey = 0 THEN 'Online'
        ELSE 'Physical Store'
    END

ORDER BY
    revenue DESC;


-- =========================================================
-- 6. STORE ORDER VALUE
-- =========================================================

SELECT
    st.StoreKey,
    st.Country,
    st.State,

    COUNT(DISTINCT s.Order_Number) AS orders,

    ROUND(
        SUM(
            s.Quantity * p.Unit_Price_USD
        )
        /
        COUNT(DISTINCT s.Order_Number),
        2
    ) AS average_order_value

FROM sales AS s

JOIN stores AS st
    ON s.StoreKey = st.StoreKey

JOIN products AS p
    ON s.ProductKey = p.ProductKey

GROUP BY
    st.StoreKey,
    st.Country,
    st.State

ORDER BY
    average_order_value DESC;


-- =========================================================
-- 7. STORE SALES BY YEAR
-- =========================================================
-- Tracks store performance over time.

SELECT
    st.StoreKey,
    st.Country,
    YEAR(s.Order_Date) AS sales_year,

    COUNT(DISTINCT s.Order_Number) AS orders,

    SUM(s.Quantity) AS units_sold,

    ROUND(
        SUM(
            s.Quantity * p.Unit_Price_USD
        ),
        2
    ) AS revenue

FROM sales AS s

JOIN stores AS st
    ON s.StoreKey = st.StoreKey

JOIN products AS p
    ON s.ProductKey = p.ProductKey

GROUP BY
    st.StoreKey,
    st.Country,
    YEAR(s.Order_Date)

ORDER BY
    st.StoreKey,
    sales_year;


-- =========================================================
-- 8. STORE AGE AT END OF DATASET
-- =========================================================
-- Calculates how long each store had been open by the
-- final sales date.

SELECT
    StoreKey,
    Country,
    State,
    `Open Date`,

    TIMESTAMPDIFF(
        YEAR,
        `Open Date`,
        '2021-02-20'
    ) AS years_open

FROM stores

ORDER BY
    years_open DESC;


-- =========================================================
-- 9. REVENUE BY STORE OPENING PERIOD
-- =========================================================
-- Groups stores according to when they opened.

SELECT
    CASE
        WHEN YEAR(st.`Open Date`) < 2010
            THEN 'Before 2010'
        WHEN YEAR(st.`Open Date`) BETWEEN 2010 AND 2014
            THEN '2010-2014'
        WHEN YEAR(st.`Open Date`) BETWEEN 2015 AND 2019
            THEN '2015-2019'
        ELSE '2020+'
    END AS opening_period,

    COUNT(DISTINCT st.StoreKey) AS stores,

    ROUND(
        SUM(
            s.Quantity * p.Unit_Price_USD
        ),
        2
    ) AS revenue

FROM stores AS st

LEFT JOIN sales AS s
    ON st.StoreKey = s.StoreKey

LEFT JOIN products AS p
    ON s.ProductKey = p.ProductKey

WHERE
    st.StoreKey <> 0

GROUP BY
    CASE
        WHEN YEAR(st.`Open Date`) < 2010
            THEN 'Before 2010'
        WHEN YEAR(st.`Open Date`) BETWEEN 2010 AND 2014
            THEN '2010-2014'
        WHEN YEAR(st.`Open Date`) BETWEEN 2015 AND 2019
            THEN '2015-2019'
        ELSE '2020+'
    END

ORDER BY
    opening_period;