/*
    Customer Sales & Credit Limit Analysis
    --------------------------------------
    Goal:
    - Show each customer and their total sales
    - Show total payments made
    - Calculate money still owed
    - Compare money owed against the customer's credit limit
    - Identify customers who exceeded their credit limit

    Key Calculations:
    - total_sales:
        Sum of all customer orders

    - total_payments:
        Sum of all payments made by the customer

    - money_owed:
        total_sales - total_payments

    - credit_status:
        Indicates whether customer exceeded credit limit

    Notes:
    - LEFT JOIN is used so customers still appear
      even if they have no payments
*/

-- Step 1: Calculate total sales per customer
WITH customer_sales AS (

    SELECT
        c.customerNumber,
        c.customerName,
        c.country,
        c.city,
        c.creditLimit,

        -- Total sales value from all orders
        SUM(od.quantityOrdered * od.priceEach) AS total_sales

    FROM customers c

    -- Join orders
    INNER JOIN orders o
        ON c.customerNumber = o.customerNumber

    -- Join order details
    INNER JOIN orderdetails od
        ON o.orderNumber = od.orderNumber

    GROUP BY
        c.customerNumber,
        c.customerName,
        c.country,
        c.city,
        c.creditLimit
),

-- Step 2: Calculate total payments per customer
customer_payments AS (

    SELECT
        customerNumber,

        -- Total amount paid by customer
        SUM(amount) AS total_payments

    FROM payments

    GROUP BY customerNumber
)

-- Step 3: Combine sales and payments
SELECT
    cs.customerNumber,
    cs.customerName,
    cs.country,
    cs.city,

    cs.creditLimit,

    -- Total customer sales
    ROUND(cs.total_sales, 2) AS total_sales,

    -- Total payments made
    ROUND(IFNULL(cp.total_payments, 0), 2) AS total_payments,

    -- Remaining balance owed
    ROUND(
        cs.total_sales - IFNULL(cp.total_payments, 0),
        2
    ) AS money_owed,

    -- Difference between credit limit and owed amount
    ROUND(
        cs.creditLimit -
        (cs.total_sales - IFNULL(cp.total_payments, 0)),
        2
    ) AS remaining_credit,

    -- Credit status flag
    CASE
        WHEN (
            cs.total_sales - IFNULL(cp.total_payments, 0)
        ) > cs.creditLimit
        THEN 'Over Credit Limit'

        ELSE 'Within Credit Limit'
    END AS credit_status

FROM customer_sales cs

-- Join payment totals
LEFT JOIN customer_payments cp
    ON cs.customerNumber = cp.customerNumber

-- Show highest owed customers first
ORDER BY money_owed DESC;