/*
    Customer Sales Analysis with Previous Purchase Comparison
    ---------------------------------------------------------
    Goal:
    - Show each customer's sales transactions
    - Calculate the value of each order
    - Compare each order to the customer's previous order
    - Identify whether first-time customers tend to spend more

    Key Calculations:
    - order_value:
        Total value of the order
        = quantityOrdered * priceEach

    - previous_order_value:
        Value of the customer's previous purchase

    - difference_from_previous:
        Current order value - previous order value

    Notes:
    - LAG() window function is used to access the previous order
    - First purchases will have NULL as previous_order_value
    - This query works in MySQL 8+ because it uses window functions
*/

-- Step 1: Calculate total value for each order
WITH customer_orders AS (

    SELECT
        o.orderNumber,
        o.orderDate,
        c.customerNumber,
        c.customerName,

        -- Total order value
        SUM(od.quantityOrdered * od.priceEach) AS order_value

    FROM orders o

    -- Join customers table
    INNER JOIN customers c
        ON o.customerNumber = c.customerNumber

    -- Join order details table
    INNER JOIN orderdetails od
        ON o.orderNumber = od.orderNumber

    GROUP BY
        o.orderNumber,
        o.orderDate,
        c.customerNumber,
        c.customerName
)

-- Step 2: Compare each order with the previous order
SELECT
    customerNumber,
    customerName,
    orderNumber,
    orderDate,
    order_value,

    -- Previous order value for the same customer
    LAG(order_value) OVER (
        PARTITION BY customerNumber
        ORDER BY orderDate, orderNumber
    ) AS previous_order_value,

    -- Difference between current and previous purchase
    order_value -
    LAG(order_value) OVER (
        PARTITION BY customerNumber
        ORDER BY orderDate, orderNumber
    ) AS difference_from_previous,

    -- Flag first purchase
    CASE
        WHEN LAG(order_value) OVER (
            PARTITION BY customerNumber
            ORDER BY orderDate, orderNumber
        ) IS NULL
        THEN 'First Purchase'
        ELSE 'Repeat Purchase'
    END AS customer_purchase_type

FROM customer_orders

-- Sort customers and purchase history
ORDER BY
    customerNumber,
    orderDate,
    orderNumber;