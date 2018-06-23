--Costumers without orders
SELECT * 
FROM Customers c LEFT JOIN orders o
ON (c.customer_id = o.customer_id)
WHERE o.order_id IS NULL

SELECT COUNT(*)
FROM
orders o 
WHERE o.customer_id = 'PARIS' OR o.customer_id = 'FISSA'

--Orders number by Costumer
SELECT cos.customer_id, cos.contact_name, count(o.*) as order_number
FROM orders o 
INNER JOIN order_details od on (o.order_id = od.order_id)
RIGHT JOIN customers cos on (o.customer_id = cos.customer_id)
GROUP BY cos.customer_id
ORDER By order_number desc

--Orders number to Costumer with more than 100 orders
SELECT cos.customer_id, cos.contact_name, count(o.*) as order_number
FROM orders o 
INNER JOIN order_details od on (o.order_id = od.order_id)
RIGHT JOIN customers cos on (o.customer_id = cos.customer_id)
GROUP BY cos.customer_id
HAVING count(o.*) > 100
ORDER By order_number desc


--Orders number to costumer with orders between 45 and 50
SELECT * 
FROM (
	SELECT cos.customer_id, cos.contact_name, count(o.*) as order_number
	FROM orders o 
	INNER JOIN order_details od on (o.order_id = od.order_id)
	RIGHT JOIN customers cos on (o.customer_id = cos.customer_id)
	GROUP BY cos.customer_id
	ORDER By order_number desc
) AS numberOrders
WHERE order_number BETWEEN 45 AND 50

-- Showing that to use agragation functions in a sub select you need to use 
-- the group by with all the fields select in the nested query
SELECT numberOrders.customer_id, numberOrders.contact_name, order_number
FROM (
	SELECT cos.customer_id, cos.contact_name, count(o.*) as order_number
	FROM orders o 
	INNER JOIN order_details od on (o.order_id = od.order_id)
	RIGHT JOIN customers cos on (o.customer_id = cos.customer_id)
	GROUP BY cos.customer_id
	ORDER By order_number desc
) AS numberOrders
WHERE order_number BETWEEN 45 AND 50
GROUP BY numberOrders.customer_id, numberOrders.contact_name, numberOrders.order_number
HAVING order_number = 48


--Orders Value by Costumer
SELECT cos.customer_id, cos.contact_name , COALESCE(round(cast(((od.quantity * unit_price) - discount) as numeric), 2), 0) as total
FROM orders o 
INNER JOIN order_details od on (o.order_id = od.order_id)
RIGHT JOIN customers cos on (o.customer_id = cos.customer_id)
ORDER BY cos.contact_name desc;

--Returning customers with orders that costs more tham 4000 and have more than 2 Orders above this value
SELECT distinct oderPartitioned.customer_id, oderPartitioned.contact_name
FROM
(

	SELECT 
		odersByClient.customer_id, 
		odersByClient.contact_name,
		odersByClient.total,
		ROW_NUMBER() OVER(partition by odersByClient.customer_id order by odersByClient.total desc) as rn
	FROM
		(
		SELECT cos.customer_id, cos.contact_name , COALESCE(round(cast(((od.quantity * unit_price) - discount) as numeric), 2), 0) as total
		FROM orders o 
		INNER JOIN order_details od on (o.order_id = od.order_id)
		RIGHT JOIN customers cos on (o.customer_id = cos.customer_id)
		ORDER BY cos.contact_name desc
		) AS odersByClient
	WHERE total > 4000

) AS oderPartitioned
WHERE oderPartitioned.rn > 2


--Expensive Orders by costumer
select cos.customer_id, cos.contact_name , COALESCE(MAX(ROUND(cast(((od.quantity * unit_price) - discount) as numeric), 2)), 0) as total
from orders o 
inner join order_details od on (o.order_id = od.order_id)
right join customers cos on (o.customer_id = cos.customer_id)
group by cos.customer_id
order by customer_id desc;


--Expensive Order done so far
SELECT MAX(expensiveOrders.total)
FROM
	(
	select cos.customer_id as id, cos.contact_name as customer_name , COALESCE(MAX(ROUND(cast(((od.quantity * unit_price) - discount) as numeric), 2)), 0) as total
	from orders o 
	inner join order_details od on (o.order_id = od.order_id)
	right join customers cos on (o.customer_id = cos.customer_id)
	group by cos.customer_id
	order by total desc
	) AS expensiveOrders

--Second Expensive Order done so far
SELECT * 
FROM
(
select cos.customer_id, cos.contact_name , COALESCE(MAX(ROUND(cast(((od.quantity * unit_price) - discount) as numeric), 2)), 0) as total
from orders o 
inner join order_details od on (o.order_id = od.order_id)
right join customers cos on (o.customer_id = cos.customer_id)
group by cos.customer_id
order by total desc
)Expensives
ORDER BY total desc
LIMIT 2
	

--Cheap Orders by client
select cos.customer_id, cos.contact_name , COALESCE(MIN(ROUND(cast(((od.quantity * unit_price) - discount) as numeric), 2)), 0) as total
from orders o 
inner join order_details od on (o.order_id = od.order_id)
right join customers cos on (o.customer_id = cos.customer_id)
group by cos.customer_id
order by total desc;

--All order from the client with ID 'Bolid'
Select COALESCE(round(cast(((od.quantity * unit_price) - discount) as numeric), 2), 0) as total
From orders o 
INNER JOIN order_details od on (o.order_id = od.order_id)
where o.customer_id = 'BOLID'
ORDER BY total ASC

--Select an order detail that from every orders from a given user
select order_id, product_id
from order_details 
where order_id 
IN (
Select order_id from orders o where o.customer_id = 'LAZYK'
)

--Select an order detail that from every orders from a given user
select order_id, product_id
from order_details 
where order_id IN (
Select order_id from orders o where o.customer_id = 'LAZYK'
)