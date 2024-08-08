CREATE TABLE users(
	user_id int8 PRIMARY KEY,
	name VARCHAR(100),
	email VARCHAR(50),
	password VARCHAR(50)
 );

SELECT * FROM orders

CREATE TABLE restaurants(
	r_id int8 PRIMARY KEY,
	r_name VARCHAR(100),
	cuisine VARCHAR(50)
 );

CREATE TABLE orders (
    order_id BIGINT PRIMARY KEY,
    user_id BIGINT,
    r_id BIGINT,
    amount BIGINT,
    date DATE,
    partner_id BIGINT,
    delivery_time BIGINT,
    delivery_rating BIGINT,
    restaurant_rating BIGINT
);


CREATE TABLE order_details(
	id int8 PRIMARY KEY,
	order_id int8,
	f_id int8
 );

SELECT * FROM order_details

CREATE TABLE menu(
	menu_id int8 PRIMARY KEY,
	r_id int8,
	f_id int8,
	price int8
 );

SELECT * FROM food

CREATE TABLE food(
	f_id int8 PRIMARY KEY,
	f_name VARCHAR(50),
	type VARCHAR(50)	
 );

CREATE TABLE delivery_partner(
	partner_id int8 PRIMARY KEY,
	partner_name VARCHAR(50)	
 );

--Q.1 find customer who have never ordered

select name FROM users 
WHERE user_id 
NOT IN (SELECT user_id FROM orders)

-- Q.2 Averege Price/Dish

SELECT f.f_name, ROUND(AVG(price),2)
FROM menu m 
JOIN food f 
ON m.f_id = f.f_id 
GROUP BY f.f_name

-- Q.3 Find top restaurants in terms of numBer of orders for a given month 

SELECT o.r_id, r.r_name, COUNT(*) AS order_count
FROM orders o
JOIN restaurants r 
ON o.r_id = r.r_id
WHERE EXTRACT(MONTH FROM o.date) = 5
GROUP BY o.r_id, r.r_name
ORDER BY order_count DESC
LIMIT 1;


-- Q.4 restaurants with monthly sales > x 

SELECT r.r_name,SUM(o.amount) AS revenue
FROM orders o
JOIN restaurants r 
ON o.r_id = r.r_id
WHERE EXTRACT(MONTH FROM o.date) = 5  -- filters for the month of june
GROUP BY r.r_id, r.r_name
HAVING SUM(o.amount)>500;

-- Q.5 show all orders with order_details for a particular customer in a particular date range

SELECT o.order_id, f.f_name, r.r_name, u.name, o.date, o.amount
FROM users u
JOIN orders o 
ON u.user_id = o.user_id
JOIN order_details od 
ON o.order_id=od.order_id
JOIN food f
ON od.f_id = f.f_id
JOIN restaurants r 
ON r.r_id=o.r_id
WHERE u.name LIKE 'Nitish'
  AND o.date BETWEEN '2022-06-10' AND '2022-07-10';

-- Q.6 Find Restaurants with max repeated customers 

SELECT r.r_name, COUNT(*) AS loyal_customers
FROM ( 
    SELECT r_id, user_id, COUNT(*) AS visits
    FROM orders 
    GROUP BY r_id, user_id
    HAVING COUNT(*) > 1
) t
JOIN restaurants r 
ON r.r_id = t.r_id
GROUP BY r.r_name
ORDER BY loyal_customers DESC
LIMIT 1;

--Q.7 Month Over Month Revenue Growth of Swiggy?

WITH Sales AS (
    SELECT EXTRACT(MONTH FROM date) AS month, 
           SUM(amount) AS revenue
    FROM orders
    GROUP BY EXTRACT(MONTH FROM date)
    ORDER BY EXTRACT(MONTH FROM date)
), SalesWithLag AS (
    SELECT month, 
           revenue,
           LAG(revenue, 1) OVER (ORDER BY month) AS prev_revenue
    FROM Sales
)
SELECT month, 
       revenue, 
       ROUND(((revenue - prev_revenue) / NULLIF(prev_revenue, 0)) * 100, 2) AS growth_percentage
FROM SalesWithLag;

-- Q.8 Customer --> Favourite Food

WITH temp AS (
               SELECT o.user_id, od.f_id, COUNT(*) AS frequency
               FROM orders o
               JOIN order_details od 
               ON o.order_id = od.order_id
               GROUP BY o.user_id, od.f_id
             )

SELECT u.name, f_name
FROM temp t1 
JOIN users u 
ON u.user_id = t1.user_id
JOIN food f 
ON f.f_id = t1.f_id
WHERE t1.frequency = (
	SELECT MAX(frequency) FROM temp t2
	WHERE t2.user_id=t1.user_id
)




 





    





