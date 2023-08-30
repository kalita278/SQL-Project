# Order Management Schema details
This document captures the scenario of simple order management functionality of an online retail store.
Typical purchase scenario: A customer places an order for N products specifying quantity for each line item
of the order. Every product belongs to a product class (or category). All products ordered in one order, are
shipped to customer’s address (in India or Outside) by a shipper in one shipment. Order can be paid using
either Cash, Credit Card or Net Banking.

There can be customers who may not have placed any order. Few customers would have cancelled their
orders (As a whole order, no cancellation of individual item allowed). Few orders may be ‘In process’
status. There can also be products that were never purchased.

Shippers use optimum sized cartons (boxes) to ship an order, based on the total volume of all products
and their quantities. Dimensions of each product (L, W, H) is also stored in the database. To keep it simple,
all products of an order are put in one single appropriately sized carton for shipping.

**Project Objective**

You are hired by a chain of online retail stores “Reliant retail limited”. They provided you with orders
database and seek answers to the following queries as the results from these queries will help the
company in making data driven decisions that will impact the overall growth of the online retail store.

----------------------------------------------------------------------------------------------------------------------------------------------------------------
**Q1. Write a query to display customer_id, customer full name with their title (Mr/Ms), both first name and
last name are in upper case, customer_email, customer_creation_year and display customer’s category
after applying below categorization rules:**

i. if CUSTOMER_CREATION_DATE year <2005 then category A

ii. if CUSTOMER_CREATION_DATE year >=2005 and <2011 then category B

iii. if CUSTOMER_CREATION_DATE year>= 2011 then category C

**Q2. Write a query to display the following information for the products which have not been sold:
product_id, product_desc, product_quantity_avail, product_price, inventory values (product_quantity_avail * product_price), New_Price after applying discount as per below criteria. Sort the output with respect to decreasing value of Inventory_Value.**

i) If Product Price > 20,000 then apply 20% discount

ii) If Product Price > 10,000 then apply 15% discount

iii) if Product Price =< 10,000 then apply 10% discount


**Q3. Write a query to display Product_class_code, Product_class_desc, Count of Product type in each
product class, Inventory Value (p.product_quantity_avail*p.product_price). Information should be
displayed for only those product_class_code which have more than 1,00,000 Inventory Value. Sort the
output with respect to decreasing value of Inventory_Value.**

**Q4. Write a query to display customer_id, full name, customer_email, customer_phone and country of
customers who have cancelled all the orders placed by them.**

**Q5. Write a query to display Shipper name, City to which it is catering, num of customer catered by the
shipper in the city , number of consignment delivered to that city for Shipper DHL.**
