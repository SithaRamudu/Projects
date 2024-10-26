-- 1.1 Create a database
create database amazon_db;
use amazon_db;

-- 1.2 Create a table and insert the data through "Table Data Import Wizard"
CREATE TABLE amazon_sales_data (
    invoice_id VARCHAR(30) NOT NULL,
    branch VARCHAR(5) NOT NULL,
    city VARCHAR(30) NOT NULL,
    customer_type VARCHAR(30) NOT NULL,
    gender VARCHAR(10) NOT NULL,
    product_line VARCHAR(100) NOT NULL,
    unit_price DECIMAL(10, 2) NOT NULL,
    quantity INT NOT NULL,
    VAT FLOAT NOT NULL,
    total DECIMAL(10, 2) NOT NULL,
    date DATE NOT NULL,
    time TIME NOT NULL,
    payment_method VARCHAR(30) NOT NULL,
    cogs DECIMAL(10, 2) NOT NULL,
    gross_margin_percentage FLOAT NOT NULL,
    gross_income DECIMAL(10, 2) NOT NULL,
    rating FLOAT NOT NULL
);

select * from amazon_sales_data;
select count(*) as total_rows from amazon_sales_data;

-- 1.3 Checking the null values
describe amazon_sales_data;
select * 
from amazon_sales_data 
where invoice_id is null
or  branch is null
or city is null
or customer_type is null 
or gender is null
or product_line is null
or unit_price is null
or quantity is null
or VAT is null
or total is null 
or date is null
or time is null 
or payment_method is null 
or cogs is null
or gross_margin_percentage is null
or gross_income is null
or rating is null;

-- 2. Feature Engineering:
-- 2.1 Add the  "timeofday" column

set sql_safe_updates = 0;

alter table amazon_sales_data add timeofday varchar(10);

update amazon_sales_data
set timeofday = case
 when hour(time) between 6 and 11 then 'Morning'
 when hour(time) between 12 and 17 then 'Afternoon'
 else 'Evenving'
end;

-- 2.2 Add the "dayname" column
alter table amazon_sales_data add dayname varchar(10);

update amazon_sales_data
set dayname = dayname(date);
-- 2.3 Add the "monthname" column
alter table amazon_sales_data add monthname varchar(10);

update amazon_sales_data
set monthname = monthname(date);

-- 3. Exploratory Data Analysis (EDA): 
-- The dataset contains 17 columns and 1000 rows and  for project requirement I add 3 more  columns.
-- After feature engineering it has 20 columns and 1000 rows.
-- In these 20 columns 11 are numerical columns and other 9 are categorical columns.
select * from amazon_sales_data;
-- 1.What is the count of distinct cities in the dataset?
select  count(distinct city) as distinct_cities from amazon_sales_data;
-- The count of distinct cities in the dataset is '3'

-- 2.For each branch, what is the corresponding city?
select branch, city from amazon_sales_data group by branch, city;
-- For each branch corresponding cities are ("branch A : Yangon", "branch B : Mandalay", "branch C : Naypyitaw")

-- 3.What is the count of distinct product lines in the dataset?
select count(distinct product_line) as distinct_product_lines from amazon_sales_data;
-- The count of distinct product lines are '6'

-- 4.Which payment method occurs most frequently?
select payment_method, count(*) as occurrences
from amazon_sales_data
group by payment_method
order by occurrences desc
limit 1;
-- The most frequently payment method occurs is "Ewallet" and number of occurrences is '345'

-- 5.Which product line has the highest sales?
select product_line, sum(total) as total_sales
from amazon_sales_data
group by product_line
order by total_sales desc
limit 1;
-- "Food and beverages" has the highest sales and total sales is '56144.96'

-- 6.How much revenue is generated each month?
select monthname(date) as month, sum(total) as total_revenue
from amazon_sales_data
group by month;
-- In month of January the total_revenue is  '116292.11'
-- In month of March the total_revenue is  '109455.74'
-- In month of February the total_revenue is  '97219.58'

-- 7.In which month did the cost of goods sold reach its peak?
select monthname(date) as month, sum(cogs) as total_cogs
from amazon_sales_data
group by month
order by total_cogs desc
limit 1;
-- The month of "January " the cost of goods sold reach  its peak and the total_cogs is '110754.16'

-- 8.Which product line generated the highest revenue?
select product_line, sum(total) as total_sales
from amazon_sales_data
group by product_line
order by total_sales desc
limit 1;
-- "Food and beverages" has generated the highest revenue and the  total_sales for Food and beverages is '56144.96'

-- 9.In which city was the highest revenue recorded?
select city, sum(total) as city_revenue 
from amazon_sales_data
group by city
order by city_revenue desc
limit 1;
-- "Naypyitaw" is the city recorded highest revenue and the city_revenue is '110568.86'

-- 10.Which product line incurred the highest Value Added Tax?
select product_line, sum(VAT) as total_vat
from amazon_sales_data
group by product_line
order by total_vat desc
limit 1;
-- "Food and beverages" has incurred the highest Value Added Tax and the total_vat is '2673.563990712166' 

-- 11.For each product line, add a column indicating "Good" if its sales are above average, otherwise "Bad."
select product_line, sum(total) as total_sales,
    case
     when sum(total) > (select avg(total) from amazon_sales_data) then "Good"
     else "Bad"
   end as performance
from amazon_sales_data
group by product_line;
-- All product lines having a good performance  
-- Health and beauty	   49193.84  	Good
-- Electronic accessories  54337.64	    Good
-- Home and lifestyle	   53861.96     Good
-- Sports and travel	   55123.00	    Good
-- Food and beverages	   56144.96	    Good
-- Fashion accessories	   54306.03	    Good

-- 12.Identify the branch that exceeded the average number of products sold
select branch, sum(quantity) as total_quantity
from amazon_sales_data
group by branch
having sum(quantity) > (
 select avg(total_quantity)
   from (select sum(quantity) as total_quantity 
   from amazon_sales_data 
   group by branch)
   as branch_totals);
-- The branch 'A' that exceeded the average number of products sold and the total_quantity is '1859' 

-- Which product line is most frequently associated with each gender?
select gender, product_line, count(*) as frequency
from amazon_sales_data
group by gender, product_line
order by gender, frequency desc
limit 1;
-- The product line "Fashion accessories" is most frequently associated with "Female" gender and number of  occurrences is '96'

-- 14.Calculate the average rating for each product line.
select product_line, round(avg(rating), 1) as average_rating
from amazon_sales_data
group by product_line;
-- The average rating for each product lines are:
-- Health and beauty	    7
-- Electronic accessories	6.9
-- Home and lifestyle	    6.8
-- Sports and travel	    6.9
-- Food and beverages	    7.1
-- Fashion accessories	    7

-- 15.Count the sales occurrences for each time of day on every weekday
select dayname , timeofday, count(*) as sales_occurrences
from amazon_sales_data
group by dayname, timeofday
order by sales_occurrences desc;
select * from amazon_sales_data;
/* Count the sales occurrences for each time of day on every weekday
Saturday	Afternoon	81
Wednesday	Afternoon	81
Thursday	Afternoon	76
Monday	    Afternoon	75
Friday	    Afternoon	74
Tuesday	    Afternoon	71
Sunday	    Afternoon	70
Saturday	Evenving	55
Tuesday	    Evenving	51
Sunday	    Evenving	41
Wednesday	Evenving	40
Tuesday	    Morning	    36
Friday	    Evenving	36
Thursday	Morning	    33
Friday	    Morning	    29
Monday	   Evenving	    29
Thursday   Evenving	    29
Saturday   Morning	    28
Sunday	   Morning	    22
Wednesday  Morning	    22
Monday	   Morning	    21
*/

-- 16.Identify the customer type contributing the highest revenue
select customer_type, sum(total) as total_revenue
from amazon_sales_data
group by customer_type
order by total_revenue desc
limit 1;
-- The "Member" customer type is contributing the highest revenue and the total revenue is '164223.81'

-- 17.Determine the city with the highest VAT percentage.
select city, max(VAT) as highest_vat
from amazon_sales_data
group by city
order by highest_vat desc
limit 1;
-- "Naypyitaw" city has the highest VAT percentage and the highest_vat is '49.65'

-- 18.Identify the customer type with the highest VAT payments.
select customer_type, sum(VAT) as total_vat
from amazon_sales_data
group by customer_type
order by total_vat desc
limit 1;
-- "Member" customer type has the highest vat payments and the total_vat is '7820.163996100426'

-- 19.What is the count of distinct customer types in the dataset?
select count(distinct customer_type) as distinct_customer_types from amazon_sales_data;
-- The count of distinct customer types in the dataset is '2'

-- 20.What is the count of distinct payment methods in the dataset?
select count(distinct payment_method) as distinct_payment_method from amazon_sales_data;
-- The count of distinct payment methods in the dataset is '3'

-- 21.Which customer type occurs most frequently?
select customer_type, count(*) as frequency
from amazon_sales_data
group by customer_type
order by frequency desc
limit 1;
-- The "Member" customer type is occurs most frequently and its frequency is '501'

-- 22.Identify the customer type with the highest purchase frequency.
select customer_type, count(*) as purchase_frequency
from amazon_sales_data
group by customer_type
order by purchase_frequency desc
limit 1;
-- The "Member" customer type has the highest purchase frequency.

-- 23.Determine the predominant gender among customers
select gender, count(*) as count
from amazon_sales_data
group by gender
order by count desc
limit 1;
-- The predominant gender among customers is "Female" and the count is '501'

-- 24.Examine the distribution of genders within each branch
select gender, branch, count(*) as gender_count
from amazon_sales_data
group by gender, branch;
/* The distribution of genders within each branches are:
Female	A	161
Female	C	178
Male	A	179
Male	C	150
Female	B	162
Male	B	170
*/
-- 25.Identify the time of day when customers provide the most ratings
select  timeofday, count(*) as rating_count
from amazon_sales_data
group by timeofday
order by rating_count desc
limit 1;
-- "Afternoon is the time of day when customers provide the most ratings and the rating_count is '528'

-- 26.Determine the time of day with the highest customer ratings for each branch.
select branch, timeofday, round(avg(rating),1) as average_rating
from amazon_sales_data
group by branch, timeofday
order by branch, average_rating desc;
/* The time of day the highest customer ratings for each branches are
A	Afternoon	7.1
A	Evenving	7
A	Morning  	7
B	Morning 	6.9
B	Afternoon	6.8
B	Evenving	6.8
C	Evenving	7.1
C	Afternoon	7.1
C	Morning	    7
*/
-- 27.Identify the day of the week with the highest average ratings.
select dayname, round(avg(rating),1) as average_rating
from amazon_sales_data
group by dayname
order by average_rating desc
limit 1;
-- The "Monday" day of the week has the highest average rating and the average_rating is '7.2'

-- 28.Determine the day of the week with the highest average ratings for each branch
with RankedRatings as (
    select branch, dayname, round(avg(rating), 2) as average_rating,
           row_number() over (partition by branch order by  round(avg(rating), 1) desc) as rn
    from amazon_sales_data
    group by  branch, dayname
)
select  branch, dayname, average_rating
from RankedRatings
where rn = 1
order by branch;
/* The day of the week with the highest average ratings for each branches are:
A	Friday	7.31
B	Monday	7.34
C	Friday	7.28
*/















