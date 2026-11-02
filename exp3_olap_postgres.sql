-- EXPERIMENT 3 | PART 3: OLAP USING SQL (PostgreSQL syntax: GROUPING SETS / ROLLUP / CUBE)
-- Table `orders` = your Superstore-style sheet imported from CSV.
-- (SQLite does NOT support ROLLUP/CUBE/GROUPING SETS. Use pgAdmin/Postgres.)

CREATE TABLE orders (
  row_id INT, order_id VARCHAR(20), order_date DATE, ship_date DATE, ship_mode VARCHAR(20),
  customer_id VARCHAR(20), customer_name VARCHAR(50), segment VARCHAR(20), country VARCHAR(30),
  city VARCHAR(40), state VARCHAR(40), postal_code VARCHAR(10), region VARCHAR(20),
  product_id VARCHAR(20), category VARCHAR(30), sub_category VARCHAR(30), product_name VARCHAR(150),
  sales NUMERIC(12,2), quantity INT, discount NUMERIC(4,2), profit NUMERIC(12,2)
);
-- Import: pgAdmin > right-click table > Import/Export > pick CSV, Header = ON.

-- BASE CUBE with CUBE  (every combination of the 3 dimensions incl. grand total)
SELECT EXTRACT(YEAR FROM order_date) AS yr, category, region, SUM(sales) AS sales
FROM orders GROUP BY CUBE (EXTRACT(YEAR FROM order_date), category, region);

-- BASE CUBE with GROUPING SETS (you choose exactly which groupings)
SELECT EXTRACT(YEAR FROM order_date) AS yr, category, region, SUM(sales) AS sales
FROM orders
GROUP BY GROUPING SETS ((EXTRACT(YEAR FROM order_date), category, region),
                        (EXTRACT(YEAR FROM order_date), category),
                        (EXTRACT(YEAR FROM order_date)), ());

-- ROLL-UP  (hierarchy: Year > Category > Region, subtotals going UP, ends with grand total)
SELECT EXTRACT(YEAR FROM order_date) AS yr, category, region, SUM(sales) AS sales
FROM orders GROUP BY ROLLUP (EXTRACT(YEAR FROM order_date), category, region);

-- DRILL-DOWN  (go DOWN the time hierarchy: Year > Quarter > Month)
SELECT EXTRACT(YEAR FROM order_date) yr, EXTRACT(QUARTER FROM order_date) qtr,
       EXTRACT(MONTH FROM order_date) mon, category, region, SUM(sales) sales
FROM orders GROUP BY 1,2,3,4,5 ORDER BY 1,2,3;

-- SLICE  (fix ONE dimension: Region = West)
SELECT EXTRACT(YEAR FROM order_date) yr, category, SUM(sales) sales
FROM orders WHERE region = 'West' GROUP BY 1,2;

-- DICE  (fix MULTIPLE dimensions: Region IN (West,East) AND Category IN (Furniture,Technology))
SELECT EXTRACT(YEAR FROM order_date) yr, region, category, SUM(sales) sales
FROM orders
WHERE region IN ('West','East') AND category IN ('Furniture','Technology')
GROUP BY 1,2,3;

-- Task 3: Monthly / Quarterly / Yearly sales & profit by category, region
SELECT EXTRACT(YEAR FROM order_date) yr, EXTRACT(QUARTER FROM order_date) qtr,
       EXTRACT(MONTH FROM order_date) mon, region, category, SUM(sales) sales, SUM(profit) profit
FROM orders GROUP BY ROLLUP (1,2,3), region, category;

-- Task 4: Year-over-year sales & profit comparison + growth % (window function LAG)
SELECT yr, sales, profit,
       ROUND(100*(sales - LAG(sales) OVER (ORDER BY yr)) / LAG(sales) OVER (ORDER BY yr), 2) AS sales_growth_pct
FROM (SELECT EXTRACT(YEAR FROM order_date) yr, SUM(sales) sales, SUM(profit) profit
      FROM orders GROUP BY 1) t;

-- Task 5: Sales across months for product X
SELECT EXTRACT(MONTH FROM order_date) mon, SUM(sales) FROM orders
WHERE product_name = 'Staples' GROUP BY 1 ORDER BY 1;

-- Task 6: Which product category has more demand in which region
SELECT sub_category, region, SUM(quantity) qty FROM orders GROUP BY 1,2 ORDER BY qty DESC;

-- Task 8: Sales by category and city for 2015
SELECT city, category, SUM(sales) FROM orders
WHERE EXTRACT(YEAR FROM order_date)=2015 GROUP BY 1,2;

-- Task 9: Category sales in January of each year
SELECT EXTRACT(YEAR FROM order_date) yr, category, SUM(sales) FROM orders
WHERE EXTRACT(MONTH FROM order_date)=1 GROUP BY 1,2;

-- Task 10: Furniture & Technology trend 2014-2015
SELECT EXTRACT(YEAR FROM order_date) yr, EXTRACT(MONTH FROM order_date) mon, category, SUM(sales)
FROM orders WHERE EXTRACT(YEAR FROM order_date) IN (2014,2015)
  AND category IN ('Furniture','Technology') GROUP BY 1,2,3 ORDER BY 1,2;

-- Task 11: Monthly growth % using LAG
SELECT yr, mon, sales,
       ROUND(100*(sales - LAG(sales) OVER (ORDER BY yr,mon)) / LAG(sales) OVER (ORDER BY yr,mon), 2) AS growth_pct
FROM (SELECT EXTRACT(YEAR FROM order_date) yr, EXTRACT(MONTH FROM order_date) mon, SUM(sales) sales
      FROM orders GROUP BY 1,2) m;
