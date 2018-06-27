--Costumers without orders
SELECT * 
FROM Customers c LEFT JOIN orders o
ON (c.customer_id = o.customer_id)
WHERE o.order_id IS NULL

-- Number of order from user PARIS and FISSA
SELECT COUNT(*)
FROM
orders o 
WHERE o.customer_id = 'PARIS' OR o.customer_id = 'FISSA'

--Number of orders by Costumer
SELECT cos.customer_id, cos.contact_name, count(o.*) as order_number
FROM orders o 
INNER JOIN order_details od on (o.order_id = od.order_id)
RIGHT JOIN customers cos on (o.customer_id = cos.customer_id)
GROUP BY cos.customer_id
ORDER By order_number desc

--Orders number from Costumers with more than 100 orders
SELECT cos.customer_id, cos.contact_name, count(o.*) as order_number
FROM orders o 
INNER JOIN order_details od on (o.order_id = od.order_id)
RIGHT JOIN customers cos on (o.customer_id = cos.customer_id)
GROUP BY cos.customer_id
HAVING count(o.*) > 100
ORDER By order_number desc


--Orders number fom costumer with orders between 45 and 50
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


--Orders Value by Costumer (right join brings even clients without orders)
SELECT cos.customer_id, cos.contact_name , COALESCE(round(cast(((od.quantity * unit_price) - discount) as numeric), 2), 0) as order_value
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


--Second order done so far
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
WHERE expensiveOrders.total < (
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
				)

--The order more expensive from each client that is lower than the more expensive order done so far
SELECT MAX(expensiveOrders.total) as valor, expensiveOrders.id
FROM
	(
	select cos.customer_id as id, cos.contact_name as customer_name , COALESCE(MAX(ROUND(cast(((od.quantity * unit_price) - discount) as numeric), 2)), 0) as total
	from orders o 
	inner join order_details od on (o.order_id = od.order_id)
	right join customers cos on (o.customer_id = cos.customer_id)
	group by cos.customer_id
	order by total desc
	) AS expensiveOrders
WHERE expensiveOrders.total < (
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
				)
group by expensiveOrders.id
order by valor desc



Jandrei
--First,Second and third Expensives Order done so far
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
LIMIT 3
	

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
--Orders number by month in 1997
SELECT count(*), 
	to_char(to_timestamp(to_char(EXTRACT(MONTH FROM required_date), '999'), 'MM'), 'Mon') as month_order, 
	EXTRACT(MONTH FROM required_date) as month_id,
	EXTRACT(YEAR FROM required_date) as year_order
from orders o 
inner join order_details od on (o.order_id = od.order_id)
right join customers cos on (o.customer_id = cos.customer_id)
where EXTRACT(YEAR FROM required_date) = 1997
group by to_char(to_timestamp(to_char(EXTRACT(MONTH FROM required_date), '999'), 'MM'), 'Mon'),
	 EXTRACT(MONTH FROM required_date), 	
	 EXTRACT(YEAR FROM required_date)
order by month_id

--Orders number in January
SELECT count(*), EXTRACT(MONTH FROM required_date) as month_order
FROM orders o 
INNER JOIN order_details od on (o.order_id = od.order_id)
RIGHT JOIN customers cos on (o.customer_id = cos.customer_id)
WHERE EXTRACT(MONTH FROM required_date) = 1
AND EXTRACT(YEAR FROM required_date) = 1997
GROUP BY EXTRACT(MONTH FROM required_date)

--Show orders in 1997 an extract day of the week, month and year and set a decription to this day and month
SELECT 	required_date,EXTRACT(dow FROM required_date) as day_id,
	to_char(required_date, 'dy') as day_desc,
	EXTRACT(MONTH FROM required_date) as month_id,
	to_char(to_timestamp(to_char(EXTRACT(MONTH FROM required_date), '999'), 'MM'), 'Mon') as month_desc, 
	EXTRACT(YEAR FROM required_date) as year
FROM orders o 
INNER JOIN order_details od on (o.order_id = od.order_id)
right JOIN customers cos on (o.customer_id = cos.customer_id)
WHERE EXTRACT(YEAR FROM required_date) = 1997
order by month_desc

--Show number of orders by month
SELECT count(*), 
	EXTRACT(MONTH FROM required_date) as month_id,
	to_char(to_timestamp(to_char(EXTRACT(MONTH FROM required_date), '999'), 'MM'), 'Mon') as month_desc, 
	EXTRACT(YEAR FROM required_date) as year
FROM orders o 
INNER JOIN order_details od on (o.order_id = od.order_id)
right JOIN customers cos on (o.customer_id = cos.customer_id)
where EXTRACT(YEAR FROM required_date) = 1997
group by EXTRACT(MONTH FROM required_date), 	
	 to_char(to_timestamp(to_char(EXTRACT(MONTH FROM required_date), '99'), 'MM'), 'Mon'),
	 EXTRACT(YEAR FROM required_date)
order by month_desc

--You are given a table segments with the following structure:

--  create table segments (
--      l integer not null,
--      r integer not null,
--      check(l <= r),
--      unique(l,r)
--  );
--Each record in this table represents a contiguous segment of a line, from l to r inclusive. Its length equals r − l.
--Consider the parts of a line covered by the segments. Write an SQL query that returns the total length of all the parts of the line covered by the segments specified in the table segments. Please note that any parts of the line that are covered by several overlapping segments should be counted only once.

--For example, given:

--  l | r
--  --+--
--  1 | 5
--  2 | 3
--  4 | 6
--your query should return 5, as the segments cover the part of the line from 1 to 6.


WITH recursive
min_max AS (
	    SELECT 
		min(l) min_l,
		max(r) max_r 
	    FROM segments
	    ),
	    
cnt(x)  AS (
	    SELECT min_l as x 
	    FROM min_max 
	    UNION ALL 
	    SELECT x+1 
	    FROM cnt 
	    WHERE x< (
		      SELECT 
			max_r 
		      FROM 
			min_max
		      )
	    )
SELECT count(distinct x)
FROM cnt
JOIN segments s on cnt.x between s.l and s.r-1
