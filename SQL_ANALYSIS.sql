/* © 2024 SAURABH DWIVEDI. All rights reserved. 
https://github.com/saurabhpandit0002/
Pizza-Sales-Analysis
*/

SELECT * FROM pizza_sales;

/*------------KPI's------------*/
--1)the total number of orders placed.

SELECT COUNT(order_id) as total_orders
from orders;


--2)Calculate the total revenue generated from pizza sales.
SELECT 
    ROUND(SUM(order_details.quantity * pizzas.price),
            2) AS Total_sales
FROM
    order_details
        JOIN
    pizzas ON order_details.pizza_id = pizzas.pizza_id;


--3)Identify the highest-priced pizza.
SELECT 
    pizza_types.name, max(pizzas.price) AS MAX_PRICE
FROM
    pizza_types
        JOIN
    pizzas ON pizza_types.pizza_type_id = pizzas.pizza_type_id

GROUP BY  pizza_types.name, pizzas.price
ORDER BY pizzas.price DESC
LIMIT 1;



--4)Identify the most common pizza size ordered.
SELECT 
    pizzas.size,
    COUNT(order_details.order_details_id) AS ORDER_COUNT
FROM
    pizzas
        JOIN
    order_details ON pizzas.pizza_id = order_details.pizza_id
GROUP BY pizzas.size
ORDER BY ORDER_COUNT DESC;



--5)List the top 5 most ordered pizza types along with their quantities.
SELECT 
    pizza_types.name,
    SUM(order_details.quantity) AS ORDER_QUANTITY
FROM
    pizza_types
        JOIN
    pizzas ON pizza_types.pizza_type_id = pizzas.pizza_type_id
        JOIN
    order_details ON order_details.pizza_id = pizzas.pizza_id
GROUP BY pizza_types.name
ORDER BY ORDER_QUANTITY DESC
LIMIT 5;

--6)Join the necessary tables to find the total quantity of each pizza category ordered.
SELECT 
    pizza_types.category,
    SUM(order_details.quantity) AS ORDER_QUANTITY
FROM
    pizza_types
        JOIN
    pizzas ON pizza_types.pizza_type_id = pizzas.pizza_type_id
        JOIN
    order_details ON order_details.pizza_id = pizzas.pizza_id
GROUP BY pizza_types.category
ORDER BY ORDER_QUANTITY DESC;



--7)Determine the distribution of orders by hour of the day.
SELECT 
    HOUR(ORDER_TIME) AS HOUR, COUNT(ORDER_ID) AS ORDER_COUNT
FROM
    orders
GROUP BY HOUR(ORDER_TIME);


--8)Join relevant tables to find the category-wise distribution of pizzas.

SELECT pizza_types.category ,count(name)
from pizza_types
group by category;



--9)Group the orders by date and calculate the average number of pizzas ordered per day.
SELECT 
    ROUND(AVG(QUANTITY), 0) AS AVG_PIZZA_ORDER
FROM
    (SELECT 
        orders.order_date, SUM(order_details.quantity) AS quantity
    FROM
        order_details
    JOIN orders ON order_details.order_id = orders.order_id
    GROUP BY orders.order_date) AS ORDER_QUANTIY;



--10)Determine the top 3 most ordered pizza types based on revenue.
SELECT 
    pizza_types.name,
    SUM(order_details.quantity * pizzas.price) AS REVENUE
FROM
    pizza_types
        JOIN
    pizzas ON pizza_types.pizza_type_id = pizzas.pizza_type_id
        JOIN
    order_details ON order_details.pizza_id = pizzas.pizza_id
GROUP BY pizza_types.name
ORDER BY REVENUE DESC
LIMIT 3;



--11)Calculate the percentage contribution of each pizza type to total revenue.
SELECT pizza_types.category,
ROUND(SUM(order_details.quantity*pizzas.price ) /(SELECT 
    ROUND(SUM(order_details.quantity * pizzas.price),
            2) AS Total_sales
FROM
    order_details
        JOIN
    pizzas ON order_details.pizza_id = pizzas.pizza_id)*100,2)
AS REVENUE
FROM pizza_types JOIN pizzas
ON pizza_types.pizza_type_id=pizzas.pizza_type_id
JOIN order_details 
ON order_details.pizza_id=pizzas.pizza_id
GROUP BY pizza_types.category
ORDER BY REVENUE DESC
;
    
    
 
--12)Analyze the cumulative revenue generated over time.

SELECT order_date ,
round(sum(revenue) over (order by order_date ),2) as cum_revenue
from
(SELECT orders.order_date,
sum(order_details.quantity*pizzas.price) AS REVENUE
FROM order_details JOIN pizzas
ON pizzas.pizza_id=order_details.pizza_id
JOIN orders 
ON orders.order_id=order_details.order_id
GROUP BY orders.order_date) AS SALES;



--13)Determine the top 3 most ordered pizza types based on revenue for each pizza category.

select category, name,revenue
from
(select category,name, revenue,
rank() over (partition by category order by revenue desc) as ranks 
from
(select pizza_types.category,pizza_types.name, 
sum(order_details.quantity*pizzas.price) as revenue
from pizza_types join pizzas
on pizza_types.pizza_type_id=pizzas.pizza_type_id
join order_details
on order_details.pizza_id=pizzas.pizza_id
group by pizza_types.category, pizza_types.name) as a) as b
where ranks<=3;








