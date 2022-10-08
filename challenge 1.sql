/* -------------------- Case Study Questions
--------------------*/
-- 1. What is the total amount each customer spent at the restaurant?
-- 2. How many days has each customer visited the restaurant?
-- 3. What was the first item FROM the menu purchased by each customer?
-- 4. What is the most purchased item ON the menu AND how many times was it purchased by all customers?
-- 5. Which item was the most popular for each customer?
-- 6. Which item was purchased first by the customer after they became a member?
-- 7. Which item was purchased just before the customer became a member?
-- 8. What is the total items AND amount spent for each member before they became a member?
-- 9. If each $1 spent equates to 10 points AND sushi has a 2x points multiplier - how many points would each customer have?
-- 10. IN the first week after a customer joins the program (including their JOIN date) they earn 2x points ON all items , not just sushi - how many points do customer A AND B have at the end of January? Use dannys_diner;

SELECT  *
FROM members;

SELECT  *
FROM menu;

SELECT  *
FROM sales;
-- Procedure to get danny tables Delimiter //

CREATE procedure diners(in var text) begin if var = menu THEN
SELECT  *
FROM menu; elseif var = sales THEN

SELECT  *
FROM sales; elseif var = members THEN

SELECT  *
FROM members; Else

SELECT  *
FROM sales; end if; end // Delimiter;

-- 1. What is the total amount each customer spent at the restaurant?
-- Answer to Question 1 : USING 2 methods
-- Total amount each customer spent wtih TABLE function

WITH customer_purchase AS
(
	SELECT  s.customer_id
	       ,s.product_id
	       ,COUNT(s.product_id)
	       ,m.price
	       ,(m.price * COUNT(s.product_id))as price_value
	FROM sales AS s
	LEFT JOIN menu AS m
	ON s.product_id = m.product_id
	GROUP BY  customer_id
	         ,product_id
)
SELECT  customer_id
       ,SUM(price_value) AS TotalSpent
FROM customer_purchase
GROUP BY  customer_id;
-- Creating a view AND combinning the sales AND menu tables to get a single TABLE

CREATE VIEW customer_big_data AS
SELECT  s.customer_id
       ,s.order_date
       ,s.product_id
       ,m.product_name
       ,m.price
FROM sales AS s
JOIN menu AS m
ON m.product_id = s.product_id;
-- Total Amount each customer spent

SELECT  customer_id
       ,SUM(price)
FROM customer_big_data
GROUP BY  customer_id;
-- 2. How many days has each customer visited the restaurant?
-- Answer to question 2
-- USING count distinct without windows function
SELECT  customer_id
       ,COUNT(DISTINCT order_date) AS visited_days
FROM sales
GROUP BY  customer_id;
-- 3. What was the first itemFROM the menu purchased by each customer? 
call diners( "menu");

-- solve USING windows function row number
WITH customer_first_purchase AS
(
	SELECT  customer_id
	       ,order_date
	       ,product_id
	       ,product_name
	       ,extract(Year
	FROM order_date) AS Year , row_number() over(partition by customer_id , extract(Year
	FROM order_date) ORDER BY order_date) AS purchase_row
	FROM customer_big_data
)
SELECT  *
FROM customer_first_purchase
WHERE purchase_row = 1;
-- 4. What is the most purchased item
ON the menu AND how many times was it purchased by all customers?
SELECT  customer_id
       ,COUNT(product_id) prodct_count
       ,product_name
FROM customer_big_data
WHERE product_name = (
SELECT  product_name
FROM customer_big_data
GROUP BY  product_name
ORDER BY COUNT(*) DESC
LIMIT 1)
GROUP BY  customer_id;

-- 5. Which item was the most popular for each customer?
WITH mp_popular AS
(
	WITH cp_popular AS
	(
		SELECT  customer_id
		       ,order_date
		       ,product_name
		       ,product_id
		       ,row_number() over(partition by product_name ,customer_id ORDER BY product_name) popular
		FROM customer_big_data
	)
	SELECT  popular
	       ,product_name
	       ,customer_id
	       ,dense_rank() over(partition by customer_id ORDER BY popular Desc) ranks
	FROM cp_popular
	ORDER BY customer_id Desc
)
SELECT  *
FROM mp_popular
WHERE ranks = 1;
-- 6. Which item was purchased first by the customer after they became a member? 
WITH order_ranks AS
(
	SELECT  c.customer_id
	       ,c.order_date
	       ,c.product_id
	       ,c.product_name
	       ,row_number() over(Partition by c.customer_id ORDER BY c.order_date) AS order_rank
	FROM customer_big_data c
	LEFT JOIN members m
	ON c.order_date >= m.join_date AND c.customer_id = m.customer_id
	WHERE c.order_date >= m.join_date
	ORDER BY c.customer_id , c.order_date 
)
SELECT  *
FROM order_ranks
WHERE order_rank = 1;
-- 7. Which item was purchased just before the customer became a member? 
WITH order_ranks AS
(
	SELECT  c.customer_id
	       ,c.order_date
	       ,c.product_id
	       ,c.product_name
	       ,row_number() over(Partition by c.customer_id ORDER BY c.order_date) AS order_rank
	FROM customer_big_data c
	LEFT JOIN members m
	ON c.order_date >= m.join_date AND c.customer_id = m.customer_id
	WHERE c.order_date >= m.join_date
	ORDER BY c.customer_id , c.order_date 
)
SELECT  *
FROM order_ranks
WHERE order_rank = 1;
-- 7. Which item was purchased just before the customer became a member? 
WITH asp AS
(
	SELECT  c.customer_id
	       ,c.order_date
	       ,c.product_id
	       ,c.product_name
	       ,c.price
	       ,CASE WHEN m.join_date >= '1900-1-29' THEN 'Member'  ELSE 'Not a Member' END Membership
	       ,row_number() over(Partition by c.customer_id ORDER BY c.order_date) AS order_rank
	FROM customer_big_data c
	LEFT JOIN members m
	ON c.order_date >= m.join_date AND c.customer_id = m.customer_id
	ORDER BY c.customer_id , c.order_date
)
SELECT  *
FROM asp
WHERE Membership = 'Not a member'
AND order_rank = 1;
-- 8. What is the total items AND amount spent for each member before they became a member? 
WITH asp AS
(
	SELECT  c.customer_id
	       ,c.order_date
	       ,c.product_id
	       ,c.product_name
	       ,c.price
	       ,CASE WHEN m.join_date >= '1900-1-29' THEN 'Member'  ELSE 'Not a Member' END Membership
	       ,row_number() over(Partition by c.customer_id ORDER BY c.order_date) AS order_rank
	FROM customer_big_data c
	LEFT JOIN members m
	ON c.order_date >= m.join_date AND c.customer_id = m.customer_id
	ORDER BY c.customer_id , c.order_date
)
SELECT  customer_id
       ,SUM(price)
       ,COUNT(product_id)
FROM asp
WHERE Membership = 'Not a member'
GROUP BY  customer_id;
-- 9. If each $1 spent equates to 10 points AND sushi has a 2x points multiplier - how many points would each customer have?
SELECT  customer_id
       ,price
       ,CASE WHEN product_id = 'sushi' THEN SUM(price * 2 * 10)  ELSE SUM(price * 10) END points
FROM customer_big_data
GROUP BY  customer_id;
-- 10. IN the first week after a customer joins the program (including their JOIN date) they earn 2x points ON all items , not just sushi - how many points do customer A AND B have at the end of January?
WITH asp AS
(
	SELECT  c.customer_id
	       ,c.order_date
	       ,c.product_id
	       ,c.product_name
	       ,c.price
	       ,m.join_date
	       ,CASE WHEN m.join_date >= '1900-1-29' THEN 'Member'  ELSE 'Not a Member' END Membership
	       ,row_number() over(Partition by c.customer_id ORDER BY c.order_date) AS order_rank
	FROM customer_big_data c
	LEFT JOIN members m
	ON c.order_date >= m.join_date AND c.customer_id = m.customer_id
	ORDER BY c.customer_id , c.order_date
)
SELECT  customer_id
       ,extract(Month
FROM order_date) Month , CASE WHEN Membership = 'member' AND DATEDIFF(order_date , date_add(join_date , INTERVAL 7 Day)) <= 7 THEN SUM(price *2* 10) WHEN product_name = 'sushi' THEN SUM(price *2* 10) else (price * 10) end points
FROM asp
WHERE extract(month
FROM order_date) = 1 AND customer_id IN ('A' , 'B')
GROUP BY  customer_id