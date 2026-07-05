/* 
   Sales Overview for 2004
   -----------------------------------
   This query joins:
   - orders
   - orderdetails
   - customers
   - products

   It calculates:
   - Sales Value  = quantityOrdered * priceEach
   - Cost of Sales = quantityOrdered * buyPrice
   - Net Profit   = Sales Value - Cost of Sales

   Results are grouped by:
   - Product
   - Country
   - City
*/

SELECT
    -- Product information
    p.productCode,
    p.productName,

    -- Customer location
    c.country,
    c.city,

    -- Total quantity sold
    SUM(od.quantityOrdered) AS total_quantity_sold,

    -- Total sales revenue
    SUM(od.quantityOrdered * od.priceEach) AS sales_value,

    -- Total cost of goods sold
    SUM(od.quantityOrdered * p.buyPrice) AS cost_of_sales,

    -- Net profit calculation
    SUM(
        (od.quantityOrdered * od.priceEach)
        - (od.quantityOrdered * p.buyPrice)
    ) AS net_profit

FROM orders o

-- Join order details to get products sold
INNER JOIN orderdetails od
    ON o.orderNumber = od.orderNumber

-- Join customers to get country and city
INNER JOIN customers c
    ON o.customerNumber = c.customerNumber

-- Join products to get product cost
INNER JOIN products p
    ON od.productCode = p.productCode

-- Filter only orders from 2004
WHERE YEAR(o.orderDate) = 2004

-- Group data by product and location
GROUP BY
    p.productCode,
    p.productName,
    c.country,
    c.city

-- Sort by highest sales value
ORDER BY sales_value DESC;