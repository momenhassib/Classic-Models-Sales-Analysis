create or replace view sales_data_for_powerBI  as 
select 
orderdate,
ord.ordernumber,
p.productname,
p.productline,
cu.customername,
cu.country as customer_country,
o.country as office_country,
buyprice,
priceeach,
quantityordered,
quantityordered * priceeach as sales_value,
quantityordered * buyprice as cost_of_sales
from orders ord
inner join orderdetails orddet
on ord.orderNumber = orddet.ordernumber
inner join customers cu 
on ord.customernumber = cu.customernumber
inner join products p
on orddet.productcode = p.productcode
inner join employees emp
on cu.salesrepemployeenumber = emp.employeenumber
inner join offices o 
on emp.officecode = o.officecode