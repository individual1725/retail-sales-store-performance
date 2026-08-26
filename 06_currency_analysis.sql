USE retail_analysis;


-- =========================================================
-- 1. EXCHANGE RATE OVERVIEW
-- =========================================================
-- Shows the available currencies and exchange-rate coverage.

SELECT
    Currency,
    COUNT(*) AS rate_records,
    MIN(Date) AS first_date,
    MAX(Date) AS last_date,
    ROUND(AVG(Exchange), 6) AS average_exchange_rate
FROM exchange_rates
GROUP BY
    Currency
ORDER BY
    Currency;


-- =========================================================
-- 2. SALES VOLUME BY CURRENCY
-- =========================================================

SELECT
    s.Currency_Code,

    COUNT(DISTINCT s.Order_Number) AS orders,

    SUM(s.Quantity) AS units_sold,

    COUNT(*) AS sales_lines

FROM sales AS s

GROUP BY
    s.Currency_Code

ORDER BY
    orders DESC;


-- =========================================================
-- 3. AVERAGE EXCHANGE RATE BY CURRENCY
-- =========================================================

SELECT
    Currency,

    ROUND(
        AVG(Exchange),
        6
    ) AS average_exchange_rate,

    ROUND(
        MIN(Exchange),
        6
    ) AS minimum_exchange_rate,

    ROUND(
        MAX(Exchange),
        6
    ) AS maximum_exchange_rate

FROM exchange_rates

GROUP BY
    Currency

ORDER BY
    Currency;


-- =========================================================
-- 4. MONTHLY EXCHANGE RATE TREND
-- =========================================================
-- Tracks how currencies move against USD over time.

SELECT
    DATE_FORMAT(Date, '%Y-%m') AS month,
    Currency,

    ROUND(
        AVG(Exchange),
        6
    ) AS average_exchange_rate

FROM exchange_rates

GROUP BY
    DATE_FORMAT(Date, '%Y-%m'),
    Currency

ORDER BY
    month,
    Currency;


-- =========================================================
-- 5. SALES WITH DAILY EXCHANGE RATE
-- =========================================================
-- Combines each sales line with its corresponding
-- exchange rate.

SELECT
    s.Order_Number,
    s.Order_Date,
    s.Currency_Code,
    s.Quantity,

    p.Product_Name,
    p.Unit_Price_USD,

    er.Exchange AS exchange_rate

FROM sales AS s

JOIN products AS p
    ON s.ProductKey = p.ProductKey

JOIN exchange_rates AS er
    ON s.Order_Date = er.Date
    AND s.Currency_Code = er.Currency

LIMIT 100;


-- =========================================================
-- 6. REVENUE IN LOCAL CURRENCY
-- =========================================================
-- Converts the USD product price into the transaction
-- currency using the daily exchange rate.
--
-- Exchange is treated as:
-- local currency value per USD.
--
-- Therefore:
-- USD price × exchange rate = local currency value.

SELECT
    s.Currency_Code,

    ROUND(
        SUM(
            s.Quantity *
            p.Unit_Price_USD *
            er.Exchange
        ),
        2
    ) AS local_currency_revenue

FROM sales AS s

JOIN products AS p
    ON s.ProductKey = p.ProductKey

JOIN exchange_rates AS er
    ON s.Order_Date = er.Date
    AND s.Currency_Code = er.Currency

GROUP BY
    s.Currency_Code

ORDER BY
    local_currency_revenue DESC;


-- =========================================================
-- 7. REVENUE CONVERTED TO USD
-- =========================================================
-- Converts transaction currency back to USD.
--
-- Because Exchange represents local currency per USD:
--
-- local currency revenue / exchange rate = USD revenue.

SELECT
    s.Currency_Code,

    ROUND(
        SUM(
            (
                s.Quantity *
                p.Unit_Price_USD *
                er.Exchange
            )
            / er.Exchange
        ),
        2
    ) AS usd_revenue

FROM sales AS s

JOIN products AS p
    ON s.ProductKey = p.ProductKey

JOIN exchange_rates AS er
    ON s.Order_Date = er.Date
    AND s.Currency_Code = er.Currency

GROUP BY
    s.Currency_Code

ORDER BY
    usd_revenue DESC;


-- =========================================================
-- 8. FX IMPACT BY CURRENCY
-- =========================================================
-- Compares local-currency revenue with its USD equivalent.

SELECT
    s.Currency_Code,

    ROUND(
        SUM(
            s.Quantity *
            p.Unit_Price_USD *
            er.Exchange
        ),
        2
    ) AS local_currency_revenue,

    ROUND(
        SUM(
            (
                s.Quantity *
                p.Unit_Price_USD *
                er.Exchange
            )
            / er.Exchange
        ),
        2
    ) AS usd_revenue

FROM sales AS s

JOIN products AS p
    ON s.ProductKey = p.ProductKey

JOIN exchange_rates AS er
    ON s.Order_Date = er.Date
    AND s.Currency_Code = er.Currency

GROUP BY
    s.Currency_Code

ORDER BY
    s.Currency_Code;


-- =========================================================
-- 9. CURRENCY SALES SHARE
-- =========================================================
-- Measures each currency's share of transaction volume.

WITH currency_sales AS (
    SELECT
        Currency_Code,
        COUNT(DISTINCT Order_Number) AS orders
    FROM sales
    GROUP BY Currency_Code
)

SELECT
    Currency_Code,
    orders,

    ROUND(
        orders
        /
        SUM(orders) OVER () * 100,
        2
    ) AS order_share

FROM currency_sales

ORDER BY
    orders DESC;


-- =========================================================
-- 10. EXCHANGE RATE VOLATILITY
-- =========================================================
-- Measures the range between the minimum and maximum
-- exchange rate observed for each currency.

SELECT
    Currency,

    ROUND(
        MIN(Exchange),
        6
    ) AS minimum_rate,

    ROUND(
        MAX(Exchange),
        6
    ) AS maximum_rate,

    ROUND(
        MAX(Exchange) - MIN(Exchange),
        6
    ) AS rate_range

FROM exchange_rates

GROUP BY
    Currency

ORDER BY
    rate_range DESC;