select t1.orderDate, t1.ordernumber, quantityordered, priceEach, productName, productLine, buyPrice, city, country
from orders t1
inner join orderdetails t2
on t1.orderNumber = t2.orderNumber
inner join products t3
on t2.productcode = t3.productcode
inner join customers t4
on t1.customerNumber = t4.customerNumber
where year(orderdate) = 2004