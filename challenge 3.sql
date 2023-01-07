create schema BuyBuy_c;
use BuyBuy_c;
CREATE TABLE sales_data ( sales_date DATE, cus_id VARCHAR(20), cus_age INT(20), cus_gender VARCHAR(20), cus_country TEXT(20), cus_state TEXT(20), prod_category VARCHAR(20), prod_subcategory VARCHAR(20), product VARCHAR(20), ord_quantity INT, unit_cost INT, unit_price INT, cost INT, revenue INT );

ALTER TABLE sales_data change product product varchar(100);

ALTER TABLE sales_data change sales_date sales_date varchar(100);

ALTER TABLE sales_data change prod_subcategory prod_subcategory varchar(100);

ALTER TABLE sales_data add column ndate date;


ALTER TABLE sales_data add column profit int;

SELECT  COUNT(*)
FROM sales_data;

SELECT monthname(ndate) month, quarter(ndate), count(*)
FROM sales_data
group by month
order by month(ndate);

/** Creating a date format Column AND updating the values
WITH the correct sales date format for easier analysis **/ 

UPDATE sales_data a,
(
	SELECT  DISTINCT (STR_TO_DATE(sales_date,'%m/%d/%YYYY')) AS updated
	       ,(sales_date)
	FROM sales_data
) AS b

SET a.ndate = b.updated
WHERE a.sales_date = b.sales_date;

 /** Updating profit TABLE for the data **/ 

UPDATE sales_data

SET profit = revenue - cost; 

-- ------ Analysis ----------------------
SELECT  QUARTER(STR_TO_DATE(sales_date,'%m/%Y/%D')) AS Quater
       ,COUNT(1)
FROM sales_data
GROUP BY  Quater
ORDER BY Quater; 

/** Answer 1 Write a query that returns the total profit made by BuyBuy
FROM 1Q11 to 4Q16
(all quarters of every year
) **/
SELECT  YEAR(ndate) Year
       ,qUARTER(ndate) Quarters
       ,(SUM(revenue) - SUM(cost)) Profit
FROM sales_data
GROUP BY  Year, Quarters
ORDER BY Year ASC
         ,Quarters ASC;

/** Write queries that return the total profit made by BuyBuy IN Q2 of every year
FROM 2011 to 2016. **/
SELECT  YEAR(ndate) Year
       ,QUARTER(ndate) Quarter
       ,SUM(Profit) Profit
FROM sales_data
WHERE QUARTER(ndate) = 2
AND YEAR(ndate) BETWEEN '2011' AND '2016'
GROUP BY  Year, quarter
ORDER BY Year
         ,Quarter; 

/** Write a query that returns the annual profit made by BuyBuy
FROM the year 2011 to 2016 **/
SELECT  YEAR(ndate) Year
       ,SUM(Profit) Profit
FROM sales_data
WHERE YEAR(ndate) BETWEEN 2011 AND 2016
GROUP BY  Year
ORDER BY Year; 

/** Write 2 queries that return the countries
WHERE BuyBuy has made the most profit
AND also the least profit of all-time. Your query must display both results
ON the same output. **/
SELECT  a.Min_country
       ,a.profit Min_Profit
       ,p.Max_country
       ,p.profit Max_Profit
FROM
(
	SELECT  SUM(Profit) Profit
	       ,cus_country Max_country
	FROM sales_data
	GROUP BY  Max_country
	ORDER BY profit DESC
	LIMIT 1
) p
JOIN
(
	SELECT  SUM(Profit) Profit
	       ,cus_country Min_country
	FROM sales_data
	GROUP BY  Min_country
	ORDER BY profit ASC
	LIMIT 1
) a
ON p.Max_country != a.Min_country; 

/** Write a query that shows the Top-10 most
 profitable countries for BuyBuy sales operations FROM 2011 to 2016 **/
SELECT  SUM(Profit) Profit
       ,cus_country Max_country
FROM sales_data
WHERE YEAR(ndate) BETWEEN 2011 AND 2016
GROUP BY  Max_country
ORDER BY profit DESC
LIMIT 10; 

/** Write a query that shows the all-time Top-10 least profitable 
countries for BuyBuy sales operations **/

SELECT  SUM(Profit) Profit
       ,cus_country Max_country
FROM sales_data
WHERE YEAR(ndate) BETWEEN 2011 AND 2016
GROUP BY  Max_country
ORDER BY profit ASC
LIMIT 10;

 /* Write a query that ranks all product categories sold by Buybuy,
FROM least amount to the most amount of all-time revenue generated */
SELECT  product
       ,revenue
       ,rank() over(order by revenue Asc) ranking
FROM
(
	SELECT  product
	       ,SUM(revenue) revenue
	FROM sales_data
	GROUP BY  product
) AS p; 

/*Write a query that returns Top-2 product categories by Profit offered by Buybuy
WITH an all-time high number of units sold*/
SELECT  p.product
       ,ord_quantity
       ,ndate
       ,profit
FROM
(
	SELECT  product
	       ,SUM(profit) profit
	FROM sales_data
	GROUP BY  product
	ORDER BY profit Desc
	LIMIT 2
) AS p
JOIN
(
	WITH CTE AS
	(
		SELECT  *
		       ,dense_rank() over (partition by product ORDER BY ord_quantity Desc,ndate Asc) rankings
		FROM
		(
			SELECT  product
			       ,ord_quantity
			       ,ndate
			       ,dense_rank() over (partition by product ORDER BY ord_quantity Desc) ranking
			FROM sales_data
		) p
		WHERE ranking = 1
	)
	SELECT  *
	FROM CTE
	WHERE rankings = 1
) c
ON c.product = p.product; 

/** Daily All time High Sales for the different Products **/
WITH CTE AS
(
	SELECT  *
	       ,dense_rank() over (partition by product ORDER BY ord_quantity Desc,ndate Asc) rankings
	FROM
	(
		SELECT  product
		       ,ord_quantity
		       ,ndate
		       ,dense_rank() over (partition by product ORDER BY ord_quantity Desc) ranking
		FROM sales_data
	) p
	WHERE ranking = 1
)
SELECT  product, ord_quantity, ndate
FROM CTE
WHERE rankings = 1;

 /** Product WITH the highest sales */
SELECT  product
       ,SUM(revenue) revenue
FROM sales_data
GROUP BY  product
ORDER BY revenue DESC
LIMIT 2; 

/** Write a query that shows the Top 10 highest-grossing products sold by BuyBuy based
ON all-time profits */
SELECT  p.product
		,c.ndate
        ,c.ord_quantity
        ,c.revenue
        ,c.profit
        ,p.profit `total profit`
        ,p.revenue `total revenue`
FROM
(
	SELECT  product
	       ,SUM(revenue) revenue
           ,sum(profit) profit
	FROM sales_data
	GROUP BY  product
	ORDER BY revenue Desc
	LIMIT 2
) AS p
JOIN
(
	WITH CTE AS
	(
		SELECT  *
		       ,dense_rank() over (partition by product ORDER BY profit Desc,ndate Asc) rankings
		FROM
		(
			SELECT  product
			       ,profit
			       ,ndate
			       ,revenue
			       ,ord_quantity
			       ,dense_rank() over (partition by product ORDER BY profit Desc) ranking
			FROM sales_data
		) p
		WHERE ranking = 1
	)
	SELECT  *
	FROM CTE
	WHERE rankings = 1
) c
ON c.product = p.product;


/* Running Total for the Different Products */
select product, ndate, profit
,sum(profit) over (partition by product order by ndate, profit Asc) `Daily Product sales Running Profit`
from sales_data

