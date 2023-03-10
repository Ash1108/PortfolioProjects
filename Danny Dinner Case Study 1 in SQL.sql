/*
I am creating the tables sales, menu, members for Danny's Dinner Project.
*/

CREATE TABLE sales (
  "customer_id" VARCHAR(1),
  "order_date" DATE,
  "product_id" INTEGER
);

INSERT INTO sales
  ("customer_id", "order_date", "product_id")
VALUES
  ('A', '2021-01-01', '1'),
  ('A', '2021-01-01', '2'),
  ('A', '2021-01-07', '2'),
  ('A', '2021-01-10', '3'),
  ('A', '2021-01-11', '3'),
  ('A', '2021-01-11', '3'),
  ('B', '2021-01-01', '2'),
  ('B', '2021-01-02', '2'),
  ('B', '2021-01-04', '1'),
  ('B', '2021-01-11', '1'),
  ('B', '2021-01-16', '3'),
  ('B', '2021-02-01', '3'),
  ('C', '2021-01-01', '3'),
  ('C', '2021-01-01', '3'),
  ('C', '2021-01-07', '3');

SELECT *
FROM [PortfolioProject].[dbo].[sales];

CREATE TABLE menu (
  "product_id" INTEGER,
  "product_name" VARCHAR(5),
  "price" INTEGER
);

INSERT INTO menu
  ("product_id", "product_name", "price")
VALUES
  ('1', 'sushi', '10'),
  ('2', 'curry', '15'),
  ('3', 'ramen', '12');

SELECT *
FROM [PortfolioProject].[dbo].[menu];

CREATE TABLE members (
  "customer_id" VARCHAR(1),
  "join_date" DATE
);

INSERT INTO members
  ("customer_id", "join_date")
VALUES
  ('A', '2021-01-07'),
  ('B', '2021-01-09');

SELECT *
FROM [PortfolioProject].[dbo].[members];

---------------------------------------------------------------------

-- 1)What is the total amount each customer spent at the restaurant?

-- First, I joined the tables sales and menu using Inner Join

SELECT *
FROM sales
INNER JOIN menu
	ON sales.product_id = menu.product_id;

-- Then, I used SUM function with GROUP BY clause

SELECT customer_id, SUM(price) as total_amount
FROM sales
INNER JOIN menu
	ON sales.product_id = menu.product_id
GROUP BY customer_id;

-- The answer is A is 76
--               B is 74
--               C is 36

-----------------------------------------------------------------------------------

-- 2)How many days has each customer visited the restaurant?

SELECT *
FROM [PortfolioProject].[dbo].[sales];

-- I used COUNT function for order_date with GROUP BY clause

SELECT customer_id, COUNT(order_date)
FROM [PortfolioProject].[dbo].[sales]
GROUP BY customer_id;

-- Answer is A 6
--			 B 6
--			 C 3

-----------------------------------------------------------------------

--3)What was the first item from the menu purchased by each customer?

-- First, I joined the tables 'sales' and 'menu'

SELECT *
FROM [PortfolioProject].[dbo].[sales]
INNER JOIN [PortfolioProject].[dbo].[menu]
	ON sales.product_id = menu.product_id;

-- Then, I listed the customer_id, order_date, product_name and used ORDER BY clause

SELECT customer_id, order_date, product_name
FROM [PortfolioProject].[dbo].[sales]
INNER JOIN [PortfolioProject].[dbo].[menu]
	ON sales.product_id = menu.product_id
ORDER BY order_date;

-- After listing the order_date , I used WHERE condition to narrow down the requirement.

SELECT customer_id, order_date, product_name
FROM [PortfolioProject].[dbo].[sales]
INNER JOIN [PortfolioProject].[dbo].[menu]
	ON sales.product_id = menu.product_id
WHERE order_date = '2021-01-01'
ORDER BY order_date;

-- Answer is A 2021-01-01 sushi
--			 A 2021-01-01 curry
--			 B 2021-01-01 curry
--			 C 2021-01-01 ramen
--			 C 2021-01-01 ramen
			
-------------------------------------------------------------------------------------------------

-- 4)What is the most purchased item on the menu and how many times was it purchased by all customers?

SELECT *
FROM [PortfolioProject].[dbo].[sales];

SELECT *
FROM [PortfolioProject].[dbo].[menu];

-- First, I used COUNT function with GROUP BY on product_id

SELECT product_name, COUNT(sales.product_id) AS product_purchased_count
FROM [PortfolioProject].[dbo].[sales]
INNER JOIN [PortfolioProject].[dbo].[menu]
	ON sales.product_id = menu.product_id
GROUP BY product_name
ORDER BY product_purchased_count DESC;

-- Second, I listed count of customer_id and grouped by both the customer_id and product_id

SELECT customer_id, COUNT(customer_id) AS ramen_purchased_count
FROM [PortfolioProject].[dbo].[sales]
WHERE product_id = 3
GROUP BY customer_id;

-- Fisrt, Answer is ramen 8
--					curry 4
--					sushi 3

-- Second, Answer is A 3
--					 B 2
--					 C 3

---------------------------------------------------------------------------------------------------

--5)Which item was the most popular for each customer?

SELECT *
FROM [PortfolioProject].[dbo].[sales];

WITH cte_rank AS(
	SELECT sales.customer_id, menu.product_name, COUNT(*) AS order_count,
	DENSE_RANK() OVER(PARTITION BY sales.customer_id ORDER BY COUNT(sales.customer_id) DESC) AS rank
	FROM [PortfolioProject].[dbo].[sales]
	INNER JOIN [PortfolioProject].[dbo].[menu]
		ON sales.product_id = menu.product_id
	GROUP BY sales.customer_id, menu.product_name
)

--selects the customers order_count whose rank is 1 i.e 
-- rank is partitioned by customer_id and ordered by highest count value. 
-- So, A ramen 3 -> rank 1
--	   A curry 2 -> rank 2
--	   A sushi 1 -> rank 3
--	   B sushi 2 -> rank 1
--     B curry 2 -> rank 1
--     etc...

SELECT customer_id, product_name, order_count, rank
FROM cte_rank
WHERE rank = 1;

-- Answer is customer_id product_name order_count rank
--				A           ramen		3			1
--				B			sushi		2			1
--				B			curry		2			1
--				B			ramen		2			1
--				C			ramen		3			1

-----------------------------------------------------------------------------------

--6)Which item was first purchased by the customer after they became a member?

SELECT *
FROM [PortfolioProject].[dbo].[menu];

SELECT *
FROM [PortfolioProject].[dbo].[sales];

-- find the item which was first purchased after join_date
--First, I joined 3 tables and then used ROW_NUMBER() function

WITH CTE_first_order AS(
SELECT sales.customer_id, menu.product_name, sales.order_date,  ROW_NUMBER() OVER(PARTITION BY sales.customer_id ORDER BY menu.product_id) AS row_id
FROM [PortfolioProject].[dbo].[sales] 
INNER JOIN [PortfolioProject].[dbo].[members]
	ON sales.customer_id = members.customer_id
INNER JOIN [PortfolioProject].[dbo].[menu]
	ON sales.product_id = menu.product_id
WHERE sales.order_date >= members.join_date
)

SELECT *
FROM CTE_first_order
WHERE row_id = 1

-- Answer is A curry 2021-01-07
--			 B sushi 2021-01-11

-------------------------------------------------------------------------------------------------

--7) Which item was purchased just before the customer became a member?

SELECT *
FROM [PortfolioProject].[dbo].[sales];

-- find the item which was purchased before join_date

WITH CTE_order AS(
SELECT sales.customer_id, sales.order_date, menu.product_name, 
RANK() OVER(PARTITION BY sales.customer_id ORDER BY sales.order_date DESC) AS row_id
FROM [PortfolioProject].[dbo].[sales]
INNER JOIN [PortfolioProject].[dbo].[menu]
	ON sales.product_id = menu.product_id
INNER JOIN [PortfolioProject].[dbo].[members]
	ON sales.customer_id = members.customer_id
WHERE sales.order_date < members.join_date
)

SELECT customer_id, order_date, product_name
FROM CTE_order
WHERE row_id =1;

-- Answer is A 2021-01-01 sushi
--           A 2021-01-01 curry
--           B 2021-01-04 sushi

-----------------------------------------------------------------------------------------

--8)What is the total items and amount spent for each member before they became a member?

SELECT *
FROM [PortfolioProject].[dbo].[sales]

SELECT *
FROM [PortfolioProject].[dbo].[menu]

-- I used COUNT, SUM function

SELECT sales.customer_id, COUNT(menu.product_id) as total_items, SUM(menu.price) AS total_price
FROM [PortfolioProject].[dbo].[sales]
INNER JOIN [PortfolioProject].[dbo].[menu]
	On sales.product_id = menu.product_id
INNER JOIN [PortfolioProject].[dbo].[members]
	ON sales.customer_id = members.customer_id
WHERE sales.order_date < members.join_date
GROUP BY sales.customer_id;

-- Answer:
-- customer_id	total_items	total_price
--		A			2			25
--		B			3			40

-----------------------------------------------------------------------------------------

--9)If each $1 spent equates to 10 points and sushi has a 2x points multiplier - how many points would each customer have?

SELECT *
FROM [PortfolioProject].[dbo].[menu];

--I used SUM with CASE function

SELECT sales.customer_id, 
SUM(
	CASE
		WHEN menu.product_name = 'sushi' THEN 20 * price
		ELSE 10 * price
	END
) AS points
FROM [PortfolioProject].[dbo].[sales]
INNER JOIN [PortfolioProject].[dbo].[menu]
	ON sales.product_id = menu.product_id
GROUP BY sales.customer_id;

--Answer:
--		customer_id	  points
--			A		    860	
--			B			940
--			C			360

--------------------------------------------------------------------------------------

--10)In the first week after a customer joins the program (including their join date) they earn 2x points on all items, 
--   not just sushi - how many points do customer A and B have at the end of January?

-- Using SUM with CASE function by limiting the date

SELECT sales.customer_id,
SUM(
	CASE
  	WHEN menu.product_name = 'sushi' THEN 20 * price
	WHEN sales.order_date BETWEEN '2021-01-07' AND '2021-01-14' THEN 20 * price
  	ELSE 10 * PRICE
	END
) AS Points
FROM [PortfolioProject].[dbo].[sales]
INNER JOIN [PortfolioProject].[dbo].[menu]
   ON sales.product_id = menu.product_id
INNER JOIN dbo.members
    ON members.customer_id = sales.customer_id
GROUP BY sales.customer_id
ORDER BY sales.customer_id;

--Answer:
--	customer_id	 points
--		A		  1370
--		B		  940

----------------------------------------------------------------------------------------------












































