use pizza_runner;

show tables;
 -- Preprocessing 
	UPDATE runner_orders 
SET 
    cancellation = NULL
WHERE
    cancellation = '';
    -- Updating customer orders and adjusting the pizza serial number to 1 and 2 and Mod 3 for Odd and even order numbers    
		UPDATE customer_orders 
SET 
    pizza_serial_number = 1
WHERE
    MOD(order_id, 2) != 0;
		UPDATE customer_orders 
SET 
    pizza_serial_number = 2
WHERE
    MOD(order_id, 2) = 0;
UPDATE customer_orders 
SET 
    pizza_serial_number = 3
WHERE
    MOD(order_id, 3) = 0;
	
    -- Updating customer orders and adjusting the pizza serial number to 1 and 2 and Mod 3 for Odd and even order numbers    
		UPDATE customer_orders 
SET 
    pizza_serial_number = 1
WHERE
    MOD(order_id, 2) != 0;
        
	-- Insering records to daily_Pizza
SELECT 
    *
FROM
    daily_pizza;
        alter table daily_pizza change start_date start_date varchar(20);
        alter table daily_pizza change finish_date finish_date varchar(20);
		insert into daily_pizza values (1,1,2000,"1/12/2022 12:03:25","1/12/2022 12:03:25","2,3,4,5",100);
		insert into daily_pizza values (3,2,4000,"1/12/2022 12:03:25","1/12/2022 12:03:25","2,3,4,5",100);
        insert into daily_pizza values (2,1,2000,"1/12/2022 12:03:25","1/12/2022 12:03:25","2,3,4,5",100);
-- --------------------------- --------------------------- --------------------------- --------------------------- ---------------------------
-- 1 Question 1 How many pizzas were ordered - 14 orders were made?
SELECT 
    COUNT(order_id)
FROM
    customer_orders;

-- 2 How many unique customer orders were made - 10 Unique Orders were made?
SELECT 
    COUNT(DISTINCT order_id)
FROM
    customer_orders;

-- 3 How many successful orders were delivered by each runner - 8 orders were successfully delivered?
SELECT 
    COUNT(1)
FROM
    runner_orders
WHERE
    cancellation IS NULL;

-- 4 How many of each type of pizza was delivered?
SELECT 
    c.pizza_serial_number,
    p.pizza_name,
    COUNT(1) number_of_orders
FROM
    customer_orders c
        LEFT JOIN
    daily_pizza d ON c.pizza_serial_number = d.pizza_serial_number
        LEFT JOIN
    pizza_names p ON d.pizza_id = p.pizza_id
GROUP BY pizza_serial_number;


-- 5 How many Vegetarian and Meatlovers were ordered by each customer - 10 Meatlovers and 4 vegetarian?
SELECT 
    p.pizza_name, COUNT(1) number_of_orders
FROM
    customer_orders c
        LEFT JOIN
    daily_pizza d ON c.pizza_serial_number = d.pizza_serial_number
        LEFT JOIN
    pizza_names p ON d.pizza_id = p.pizza_id
GROUP BY pizza_name;

-- 6 What was the maximum number of pizzas delivered in a single order -  3 Pizza were delivered with order number 4?
SELECT 
    c.customer_id,
    c.order_id,
    COUNT(c.order_id) AS number_of_orders
FROM
    customer_orders c
        LEFT JOIN
    runner_orders r ON r.order_id = c.order_id
WHERE
    r.cancellation IS NULL
GROUP BY customer_id , order_id
ORDER BY COUNT(1) DESC;

-- 7 For each customer, how many delivered pizzas had at least 1 change and how many had no changes?




-- 8 How many pizzas were delivered that had both exclusions and extras - 7 Orders have both extras and exclusions in it?
SELECT 
    COUNT(*)
FROM
    customer_orders
WHERE
    (exclusions <> 0 || extras <> 0);


-- 9 What was the total volume of pizzas ordered for each hour of the day?
SELECT 
    EXTRACT(HOUR FROM order_time) Hour, COUNT(1) order_count
FROM
    customer_orders
GROUP BY Hour
ORDER BY Hour ASC;

-- 10 What was the volume of orders for each day of the week?
SELECT 
    DAYNAME(order_time) Days, COUNT(1) order_count
FROM
    customer_orders
GROUP BY Days
ORDER BY dayofweek(order_time) ASC;

-- 11 How many runners signed up for each 1 week period? (i.e. week starts 2021-01-01)
SELECT 
    EXTRACT(WEEK FROM pickup_time) + 1 weeks,
    COUNT(DISTINCT runner_id) reg_runners,
    COUNT(*) order_numbers
FROM
    runner_orders
WHERE
    cancellation IS NULL
GROUP BY Weeks;

-- 12 What was the average time in minutes it took for each runner to arrive at the Pizza Runner HQ to pickup the order?
SELECT 
    runner_id,
    COUNT(*) order_number,
    ROUND(AVG(SUBSTRING_INDEX(duration, ' ', 1)),
            0) average_d_time
FROM
    runner_orders
WHERE
    cancellation IS NULL
GROUP BY runner_id;

/** 13 Is there any relationship between the number of pizzas and how long the order takes to prepare - 
 The more the pizza ordered, the more time it takes to prepare and it 
 takes an average of 10 mins to prepare one pizza and about 30 mins for 3 pizzas? **/
SELECT 
    p.pickup_time,
    c.order_time,
     q.pizza_name,
    c.order_id,
    COUNT(c.order_id) Number_of_Orders,
    TIME(AVG(TIMEDIFF(p.pickup_time, c.order_time))) prep_duration
FROM
    customer_orders c
        LEFT JOIN
    runner_orders p ON c.order_id = p.order_id
        INNER JOIN
    daily_pizza d ON c.pizza_serial_number = d.pizza_serial_number
        INNER JOIN
    pizza_names q ON q.pizza_id = d.pizza_id
WHERE
    p.cancellation IS NULL
GROUP BY order_id;

/** 14 What was the average distance travelled for each customer - 
Customer distance travelled  104 had the lowest number of distance covered though
he purchased the highest item **/
SELECT 
    c.customer_id,
    ROUND(AVG(SUBSTRING_INDEX(p.distance, ' ', 1)),
            0) Distance
FROM
    customer_orders c
        LEFT JOIN
    runner_orders p ON c.order_id = p.order_id
WHERE
    p.cancellation IS NULL
GROUP BY c.customer_id;

-- 15 What was the difference between the longest and shortest delivery times for all orders?

SELECT 
    MIN(ROUND((SUBSTRING_INDEX(distance, ' ', 1)), 0)) Min_distance,
    MAX(ROUND((SUBSTRING_INDEX(distance, ' ', 1)), 0)) Max_distance,
    (MAX(ROUND((SUBSTRING_INDEX(distance, ' ', 1)), 0)) - MIN(ROUND((SUBSTRING_INDEX(distance, ' ', 1)), 0))) Distance
FROM
    runner_orders
WHERE
    cancellation IS NULL;

-- 16 What was the average speed for each runner for each delivery and do you notice any trend for these values?
SELECT 
    runner_id,
    COUNT(runner_id) order_number,
    ROUND(SUM(SUBSTRING_INDEX(distance, ' ', 1)),
            0) * 1000 `Distance(m)`,
    ROUND(SUM(SUBSTRING_INDEX(duration, ' ', 1)),
            0) * 60 `time_taken(s)`,
    ROUND(((ROUND(SUM(SUBSTRING_INDEX(distance, ' ', 1)),
                    0) * 1000) / (ROUND(SUM(SUBSTRING_INDEX(duration, ' ', 1)),
                    0) * 60)),
            1) `speed(m/s)`
FROM
    runner_orders
WHERE
    cancellation IS NULL
 GROUP BY runner_id ;

-- 17 What is the successful delivery percentage for each runner?
SELECT 
    p.runner_id,
    e.delivered all_request,
    p.delivered,
    concat((ROUND((p.delivered / e.delivered) * 100)),' %') `%`
FROM
    (SELECT 
        runner_id, COUNT(1) AS delivered
    FROM
        runner_orders
    WHERE
        cancellation IS NULL
    GROUP BY runner_id) AS p
        INNER JOIN
    (SELECT 
        runner_id, COUNT(1) AS delivered
    FROM
        runner_orders
    GROUP BY runner_id) AS e ON e.runner_id = p.runner_id;
    

-- Price and Ratings Review --

-- 1 If a Meat Lovers pizza costs $12 and Vegetarian costs $10 and there were no charges for changes - how much money has Pizza Runner made so far if there are no delivery fees?
SELECT 
     if (grouping(q.pizza_name),"Total",q.pizza_name) `pizza name`,
     if(pizza_name = 'Meatlovers', COUNT(c.order_id) * 12,COUNT(c.order_id) * 10)
     `Pizza Amount`,
    COUNT(c.order_id) `Number of Orders`
FROM
    customer_orders c
        LEFT JOIN
    runner_orders p ON c.order_id = p.order_id
        INNER JOIN
    daily_pizza d ON c.pizza_serial_number = d.pizza_serial_number
        INNER JOIN
    pizza_names q ON q.pizza_id = d.pizza_id
WHERE
    p.cancellation IS NULL
GROUP BY q.pizza_name with ROLLUP;

 


