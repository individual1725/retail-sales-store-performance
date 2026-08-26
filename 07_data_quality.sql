USE retail_analysis;


-- =========================================================
-- 1. DUPLICATE ORDER NUMBERS + LINE ITEMS
-- =========================================================
-- An order can legitimately contain multiple line items.
-- Therefore we check the combination of Order_Number and
-- Line_Item rather than Order_Number alone.

SELECT
    Order_Number,
    Line_Item,
    COUNT(*) AS row_count
FROM sales
GROUP BY
    Order_Number,
    Line_Item
HAVING COUNT(*) > 1;


-- =========================================================
-- 2. DUPLICATE CUSTOMER KEYS
-- =========================================================

SELECT
    CustomerKey,
    COUNT(*) AS row_count
FROM customers
GROUP BY CustomerKey
HAVING COUNT(*) > 1;


-- =========================================================
-- 3. DUPLICATE PRODUCT KEYS
-- =========================================================

SELECT
    ProductKey,
    COUNT(*) AS row_count
FROM products
GROUP BY ProductKey
HAVING COUNT(*) > 1;


-- =========================================================
-- 4. DUPLICATE STORE KEYS
-- =========================================================

SELECT
    StoreKey,
    COUNT(*) AS row_count
FROM stores
GROUP BY StoreKey
HAVING COUNT(*) > 1;


-- =========================================================
-- 5. DUPLICATE EXCHANGE-RATE RECORDS
-- =========================================================
-- There should be one exchange rate per Date + Currency.

SELECT
    Date,
    Currency,
    COUNT(*) AS row_count
FROM exchange_rates
GROUP BY
    Date,
    Currency
HAVING COUNT(*) > 1;


-- =========================================================
-- 6. SALES WITHOUT A CUSTOMER
-- =========================================================

SELECT
    COUNT(*) AS orphaned_customer_records
FROM sales AS s
LEFT JOIN customers AS c
    ON s.CustomerKey = c.CustomerKey
WHERE c.CustomerKey IS NULL;


-- =========================================================
-- 7. SALES WITHOUT A PRODUCT
-- =========================================================

SELECT
    COUNT(*) AS orphaned_product_records
FROM sales AS s
LEFT JOIN products AS p
    ON s.ProductKey = p.ProductKey
WHERE p.ProductKey IS NULL;


-- =========================================================
-- 8. SALES WITHOUT A STORE
-- =========================================================

SELECT
    COUNT(*) AS orphaned_store_records
FROM sales AS s
LEFT JOIN stores AS st
    ON s.StoreKey = st.StoreKey
WHERE st.StoreKey IS NULL;


-- =========================================================
-- 9. SALES WITHOUT AN EXCHANGE RATE
-- =========================================================

SELECT
    COUNT(*) AS orphaned_exchange_records
FROM sales AS s
LEFT JOIN exchange_rates AS er
    ON s.Order_Date = er.Date
    AND s.Currency_Code = er.Currency
WHERE er.Date IS NULL;


-- =========================================================
-- 10. NULL VALUES IN SALES
-- =========================================================

SELECT
    SUM(Order_Number IS NULL) AS null_order_number,
    SUM(Line_Item IS NULL) AS null_line_item,
    SUM(Order_Date IS NULL) AS null_order_date,
    SUM(Delivery_Date IS NULL) AS null_delivery_date,
    SUM(CustomerKey IS NULL) AS null_customer_key,
    SUM(StoreKey IS NULL) AS null_store_key,
    SUM(ProductKey IS NULL) AS null_product_key,
    SUM(Quantity IS NULL) AS null_quantity,
    SUM(Currency_Code IS NULL) AS null_currency
FROM sales;


-- =========================================================
-- 11. INVALID QUANTITIES
-- =========================================================

SELECT
    COUNT(*) AS invalid_quantity_records
FROM sales
WHERE Quantity <= 0
   OR Quantity IS NULL;


-- =========================================================
-- 12. INVALID DELIVERY DATES
-- =========================================================
-- Delivery should not occur before the order.

SELECT
    COUNT(*) AS invalid_delivery_dates
FROM sales
WHERE Delivery_Date < Order_Date;


-- =========================================================
-- 13. NULL VALUES IN PRODUCTS
-- =========================================================

SELECT
    SUM(ProductKey IS NULL) AS null_product_key,
    SUM(Product_Name IS NULL) AS null_product_name,
    SUM(Unit_Cost_USD IS NULL) AS null_unit_cost,
    SUM(Unit_Price_USD IS NULL) AS null_unit_price,
    SUM(CategoryKey IS NULL) AS null_category_key,
    SUM(Category IS NULL) AS null_category
FROM products;


-- =========================================================
-- 14. INVALID PRODUCT PRICES
-- =========================================================
-- Unit cost should not exceed unit price for a normal sale.

SELECT
    COUNT(*) AS invalid_product_prices
FROM products
WHERE Unit_Cost_USD < 0
   OR Unit_Price_USD < 0
   OR Unit_Cost_USD > Unit_Price_USD;


-- =========================================================
-- 15. NULL VALUES IN CUSTOMERS
-- =========================================================

SELECT
    SUM(CustomerKey IS NULL) AS null_customer_key,
    SUM(Name IS NULL) AS null_name,
    SUM(Country IS NULL) AS null_country,
    SUM(Birthday IS NULL) AS null_birthday
FROM customers;


-- =========================================================
-- 16. NULL VALUES IN STORES
-- =========================================================

SELECT
    SUM(StoreKey IS NULL) AS null_store_key,
    SUM(Country IS NULL) AS null_country,
    SUM(State IS NULL) AS null_state,
    SUM(`Open Date` IS NULL) AS null_open_date
FROM stores;


-- =========================================================
-- 17. INVALID STORE SIZES
-- =========================================================
-- Online StoreKey 0 does not have a physical square-meter
-- value, so it is excluded.

SELECT
    COUNT(*) AS invalid_store_sizes
FROM stores
WHERE StoreKey <> 0
  AND `Square Meters` <= 0;


-- =========================================================
-- 18. EXCHANGE-RATE NULL VALUES
-- =========================================================

SELECT
    SUM(Date IS NULL) AS null_date,
    SUM(Currency IS NULL) AS null_currency,
    SUM(Exchange IS NULL) AS null_exchange
FROM exchange_rates;


-- =========================================================
-- 19. INVALID EXCHANGE RATES
-- =========================================================

SELECT
    COUNT(*) AS invalid_exchange_rates
FROM exchange_rates
WHERE Exchange <= 0;


-- =========================================================
-- 20. SALES DATE RANGE VALIDATION
-- =========================================================

SELECT
    MIN(Order_Date) AS first_order_date,
    MAX(Order_Date) AS last_order_date,

    MIN(Delivery_Date) AS first_delivery_date,
    MAX(Delivery_Date) AS last_delivery_date

FROM sales;


-- =========================================================
-- 21. FINAL DATASET SUMMARY
-- =========================================================

SELECT
    (SELECT COUNT(*) FROM sales) AS sales_rows,
    (SELECT COUNT(*) FROM customers) AS customers,
    (SELECT COUNT(*) FROM products) AS products,
    (SELECT COUNT(*) FROM stores) AS stores,
    (SELECT COUNT(*) FROM exchange_rates) AS exchange_rates;