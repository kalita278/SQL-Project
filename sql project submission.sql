
select CUSTOMER_ID, concat((select 
case
when CUSTOMER_GENDER = 'F' then 'Ms'
else  'Mr' 
end),' ',upper(CUSTOMER_FNAME),' ', upper(CUSTOMER_LNAME)) as CUSTOMER_FULL_NAME, CUSTOMER_EMAIL, extract(year from CUSTOMER_CREATION_DATE) as CUSTOMER_CREATION_YEAR,
case
when extract(year from CUSTOMER_CREATION_DATE) < 2005 then 'A'
when extract(year from CUSTOMER_CREATION_DATE) >= 2005 and extract(year from CUSTOMER_CREATION_DATE) < 2011 then 'B'
else 'C'
end as CUSTOMER_CATEGORY
from online_customer;

------------------------------------------------------------------------------------------------------------------------------------------------------------------

select PRODUCT_ID, PRODUCT_DESC, PRODUCT_QUANTITY_AVAIL, PRODUCT_PRICE, (PRODUCT_QUANTITY_AVAIL * PRODUCT_PRICE) as INVENTORY_VALUES,
case
when PRODUCT_PRICE > 20000 then round(PRODUCT_PRICE * 0.80,2)
when PRODUCT_PRICE > 10000 then round(PRODUCT_PRICE * 0.85,2)
else round(PRODUCT_PRICE * 0.90,2)
end as NEW_PRICE_AFTER_DISCOUNT
from product
where PRODUCT_ID not in (select distinct(PRODUCT_ID) from order_items)
order by (PRODUCT_QUANTITY_AVAIL * PRODUCT_PRICE) desc;

------------------------------------------------------------------------------------------------------------------------------------------------------------------

select p.PRODUCT_CLASS_CODE, pc.PRODUCT_CLASS_DESC, count(p.PRODUCT_ID)as COUNT_OF_PRODUCT_TYPE,
sum(p.PRODUCT_QUANTITY_AVAIL * p.PRODUCT_PRICE) AS INVENTORY_VALUE from product as p
join product_class as pc
on p.PRODUCT_CLASS_CODE = pc.PRODUCT_CLASS_CODE
group by p.PRODUCT_CLASS_CODE
having SUM(p.PRODUCT_QUANTITY_AVAIL * p.PRODUCT_PRICE) > 100000
order by sum(p.PRODUCT_QUANTITY_AVAIL * p.PRODUCT_PRICE) desc;

-----------------------------------------------------------------------------------------------------------------------------------------------------------------

select c.CUSTOMER_ID, concat(c.CUSTOMER_FNAME,' ',c.CUSTOMER_LNAME) as FULL_NAME,
c.CUSTOMER_EMAIL, c.CUSTOMER_PHONE, a.COUNTRY from online_customer as c
join address as a
on c.ADDRESS_ID = a.ADDRESS_ID
join order_header as o
on c.CUSTOMER_ID = o.CUSTOMER_ID
where c.CUSTOMER_ID in (select o.CUSTOMER_ID from order_header as o
                         where o.ORDER_STATUS = 'Cancelled')
	and c.CUSTOMER_ID not in (select o.CUSTOMER_ID from order_header as o
                         where o.ORDER_STATUS != 'Cancelled');

------------------------------------------------------------------------------------------------------------------------------------------------------------------

select s.SHIPPER_NAME, a.CITY as CATERING_CITY, count(c.CUSTOMER_ID) as NO_OF_CUSTOMER_CATERED, count(o.ORDER_ID) as NO_OF_CONSIGNMENT FROM shipper as s
join order_header as o
on s.SHIPPER_ID = o.SHIPPER_ID
join online_customer as c
on o.CUSTOMER_ID = c.CUSTOMER_ID
join address as a 
on c.ADDRESS_ID = a.ADDRESS_ID
where s.SHIPPER_NAME = 'DHL'
group by s.SHIPPER_NAME, a.CITY;

------------------------------------------------------------------------------------------------------------------------------------------------------------------

select p.PRODUCT_ID, p.PRODUCT_DESC, p.PRODUCT_QUANTITY_AVAIL, sum(o.PRODUCT_QUANTITY) as QUANTITY_SOLD,
case
when pc.PRODUCT_CLASS_DESC in ('Electronics','Computer') and sum(o.PRODUCT_QUANTITY) is null then 'No Sales in past, give discount to reduce inventory'
when pc.PRODUCT_CLASS_DESC in ('Electronics','Computer') and p.PRODUCT_QUANTITY_AVAIL < sum(o.PRODUCT_QUANTITY) * 0.10 then 'Low inventory, need to add inventory'
when pc.PRODUCT_CLASS_DESC in ('Electronics','Computer') and p.PRODUCT_QUANTITY_AVAIL < sum(o.PRODUCT_QUANTITY) * 0.50 then 'Medium inventory, need to add some inventory'
when pc.PRODUCT_CLASS_DESC in ('Electronics','Computer') and p.PRODUCT_QUANTITY_AVAIL >=  sum(o.PRODUCT_QUANTITY) * 0.50 then 'Sufficient inventory'
when pc.PRODUCT_CLASS_DESC in ('Mobiles','Watches') and sum(o.PRODUCT_QUANTITY) is null then 'No Sales in past, give discount to reduce inventory'
when pc.PRODUCT_CLASS_DESC in ('Mobiles','Watches') and p.PRODUCT_QUANTITY_AVAIL < sum(o.PRODUCT_QUANTITY) * 0.20 then 'Low inventory, need to add inventory'
when pc.PRODUCT_CLASS_DESC in ('Mobiles','Watches') and p.PRODUCT_QUANTITY_AVAIL < sum(o.PRODUCT_QUANTITY) * 0.60 then 'Medium inventory, need to add some inventory'
when pc.PRODUCT_CLASS_DESC in ('Mobiles','Watches') and p.PRODUCT_QUANTITY_AVAIL >=  sum(o.PRODUCT_QUANTITY) * 0.60 then 'Sufficient inventory'
when pc.PRODUCT_CLASS_DESC not in ('Mobiles','Watches','Electronics','Computer') and sum(o.PRODUCT_QUANTITY) is null then 'No Sales in past, give discount to reduce inventory'
when pc.PRODUCT_CLASS_DESC not in ('Mobiles','Watches','Electronics','Computer') and p.PRODUCT_QUANTITY_AVAIL < sum(o.PRODUCT_QUANTITY) * 0.30 then 'Low inventory, need to add inventory'
when pc.PRODUCT_CLASS_DESC not in ('Mobiles','Watches','Electronics','Computer') and p.PRODUCT_QUANTITY_AVAIL < sum(o.PRODUCT_QUANTITY) * 0.70 then 'Medium inventory, need to add some inventory'
when pc.PRODUCT_CLASS_DESC not in ('Mobiles','Watches','Electronics','Computer') and p.PRODUCT_QUANTITY_AVAIL >=  sum(o.PRODUCT_QUANTITY) * 0.70 then 'Sufficient inventory'
end as INVENTORY_STATUS
from product as p
inner join product_class as pc
on p.PRODUCT_CLASS_CODE = pc.PRODUCT_CLASS_CODE
left join order_items as o
on p.PRODUCT_ID = o.PRODUCT_ID
group by p.PRODUCT_ID,p.PRODUCT_DESC,p.PRODUCT_QUANTITY_AVAIL,pc.PRODUCT_CLASS_DESC;

-------------------------------------------------------------------------------------------------------------------------------------------------------------------

select o.ORDER_ID, sum(p.LEN * p.WIDTH * p.HEIGHT * o.PRODUCT_QUANTITY) as VOLUME_OF_PRODUCT from PRODUCT as p
join order_items as o
on p.PRODUCT_ID = o.PRODUCT_ID
group by o.ORDER_ID
having sum(p.LEN * p.WIDTH * p.HEIGHT * o.PRODUCT_QUANTITY) < (select (c.LEN * c.WIDTH *c.HEIGHT) from carton as c where c.CARTON_ID = 10)
ORDER BY sum(p.LEN * p.WIDTH * p.HEIGHT * o.PRODUCT_QUANTITY) DESC
LIMIT 1;

-------------------------------------------------------------------------------------------------------------------------------------------------------------------

select c.CUSTOMER_ID, concat(c.CUSTOMER_FNAME, ' ',c.CUSTOMER_LNAME) as CUSTOMER_FULLNAME, sum(o.PRODUCT_QUANTITY) as TOTAL_QUANTITY,
sum(o.PRODUCT_QUANTITY * p.PRODUCT_PRICE) as TOTAL_VALUE from online_customer as c
join order_header as oh
on c.CUSTOMER_ID = oh.CUSTOMER_ID
join order_items as o
on oh.ORDER_ID = o.ORDER_ID
join product as p
on o.PRODUCT_ID = p.PRODUCT_ID
where oh.ORDER_STATUS = 'Shipped' and oh.PAYMENT_MODE = 'Cash' and c.CUSTOMER_LNAME like 'G%'
group by c.CUSTOMER_ID;

------------------------------------------------------------------------------------------------------------------------------------------------------------------

select p.PRODUCT_ID, p.PRODUCT_DESC, sum(o.PRODUCT_QUANTITY) as TOTAL_QUANTITY from product as p
join order_items as o
on p.PRODUCT_ID = o.PRODUCT_ID
join order_header as oh
on oh.ORDER_ID = o.ORDER_ID
join online_customer as c
on oh.CUSTOMER_ID = c.CUSTOMER_ID
join address as a
on c.ADDRESS_ID = a.ADDRESS_ID
where o.ORDER_ID in (select ot.ORDER_ID from order_items as ot group by ot.ORDER_ID having count(ot.PRODUCT_ID) > 1)
and o.ORDER_ID in (select ot.ORDER_ID from order_items as ot where ot.PRODUCT_ID = 201)
and oh.ORDER_STATUS = 'Shipped'
and p.PRODUCT_ID not in (201)
and a.CITY not in ('Bangalore','New Delhi')
group by p.PRODUCT_ID
order by sum(o.PRODUCT_QUANTITY) desc;

------------------------------------------------------------------------------------------------------------------------------------------------------------------

select o.ORDER_ID, c.CUSTOMER_ID, concat(c.	CUSTOMER_FNAME,' ',c.CUSTOMER_LNAME) as CUSTOMER_FULLNAME, sum(ot.PRODUCT_QUANTITY) as TOTAL_QUANTITY_SHIPPED from online_customer as c
join order_header as o
on c.CUSTOMER_ID = o.CUSTOMER_ID
join order_items as ot
on o.ORDER_ID = ot.ORDER_ID
join address as a 
on c.ADDRESS_ID = a.ADDRESS_ID
where o.ORDER_STATUS = 'Shipped' and mod(o.ORDER_ID,2) = 0 and a.PINCODE not like '5%'
group by o.ORDER_ID
order by sum(ot.PRODUCT_QUANTITY) desc;

-------------------------------------------------------------------------------------------------------------------------------------------------------------------










