-- Create database
create database if not exists datawalmart;

-- Create table
create table if not exists sales(
	Invoice_id varchar(30) not null primary key,
    Branch varchar(5) not null,
    City varchar(30) not null,
    Customer_type varchar(30) not null,
    Gender varchar(30) not null,
    Product_line varchar(100) not null,
    Unit_price decimal(10,2) not null,
    Quantity int not null,
    VAT float(6,4) not null,
    Total decimal(12, 4) not null,
    Date datetime not null,
    Time time not null,
    Payment varchar(15) not null,
    Cogs decimal(10,2) not null,
    Gross_margin_pct float(11,9),
    Gross_income decimal(12, 4),
    Rating float(2, 1)
);

-- ------------------ Feature Engineering -----------------
-- time_of_day --
use datawalmart;
select 
     time,
     (case
          when Time between "00:00:00" and "12:00:00" then "Morning"
          when Time between "12:01:00" and "16:00:00" then "Afternoon"
          else "Evening"
	  end
      ) as Time_of_the_date
from sales;

alter table sales add column time_of_day varchar(20);

update sales
set time_of_day = (
case
          when Time between "00:00:00" and "12:00:00" then "Morning"
          when Time between "12:01:00" and "16:00:00" then "Afternoon"
          else "Evening"
	  end
);

-- day_name --

select 
    date,
    dayname(date)
from sales;

alter table sales add column Day_name varchar(10);

-- month_name --

update sales
set Day_name = dayname(date);

select 
    date,
    monthname(date)
from sales;

alter table sales add column Month_name varchar(10);

update sales
set Month_name = monthname(date);

-- -------------------- Generic ------------------------

-- how many unique cities does the data have?
select 
   distinct city
from sales;

-- in which city is each branch?
select 
    distinct branch
from sales;

select 
distinct city, 
branch 
from sales;

-- ---------------------- Product ----------------------

-- how many unique product lines does the data have?
select 
    count(distinct product_line)
from sales;

-- what is the most common payment method?
select 
    payment_method,
    count(payment_method) as Cnt
from sales
group by payment_method
order by Cnt Desc;

-- what is the most selling product line?
select 
    product_line,
    count(product_line) as cnt
from sales
group by product_line
order by cnt Desc;

-- what is the total revenue by month?
select
	month_name as month,
    sum(total) as total_revenue
from sales
group by month_name
order by total_revenue desc;

-- what month had the largest COGS?
select 
	month_name as month,
    sum(cogs) as cogs
from sales
group by month_name
order by cogs desc;

-- what product line had the largest revenue?
select 
	product_line,
    sum(total) as total_revenue
from sales
group by product_line
order by total_revenue desc;

-- what is the city with the largest revenue?
select 
	branch,
    city,
    sum(total) as total_revenue
from sales
group by city, branch
order by total_revenue desc;

-- what product line had the largest VAT?
select
	product_line,
    avg(vat) as avg_tax
from sales
group by product_line
order by avg_tax desc;

-- Fetch each product line and add a column to those product line showing "Good", "Bad". Good if its greater than average sales.
select 
    product_line,
    sum(total) AS total_sales,
    case
        when sum(total) > (select avg(total_sales) 
                           from (select sum(total) as total_sales 
                                 from sales 
                                 group by product_line) as avg_table)
        then 'Good'
        else 'Bad'
    end as performance
from sales
group by product_line;

-- which branch sold more products then average product sold?
select
	branch,
    sum(quantity) as qty
from sales
group by branch
having sum(quantity) > (select avg(quantity) from sales);

-- what is the most commomn product line by gender?
select 
	gender,
    product_line,
    count(gender) as total_cnt
from sales
group by gender, product_line
order by total_cnt desc;

-- what is the average rating of each product line?
select 
	avg(rating) as avg_rating,
    product_line
from sales
group by product_line
order by avg_rating desc;

-- --------------------------Sales--------------------------

-- number of sales made in each time of the day per weekday
select 
	time_of_day,
    count(*) as total_sales
from sales
where day_name = "Monday"
group by time_of_day
order by total_sales desc;

-- which of the customer types brings the most revenue
select
	customer_type,
    sum(total) as total_rev
from sales
group by customer_type
order by total_rev desc;

-- which city has the largest tax percent/VAT ( values added tax)?
select 
	city,
    avg(vat) as VAT 
from sales
group by city
order by VAT desc;

-- which customer type pays the most in VAT?
select 
	customer_type,
    avg(vat) as VAT 
from sales
group by customer_type
order by VAT desc;

-- -------------------------Customer-----------------------

-- how may unique customer types does the data have?
select 
	distinct customer_type
from sales;

-- how  many unique payment methods does the data have?
select 
	distinct payment_method
from sales;

-- what is the most common customer type?
select 
	customer_type,
    sum(total) as total_amount
from sales
group by customer_type
order by total_amount desc;

-- which customer type buys the most?
select 
	customer_type,
    count(*) as cstm_cnt
from sales
group by customer_type;

-- what is the gender of the most of the customers?
select
	gender,
    count(*) as gender_cnt
from sales
group by gender
order by gender_cnt desc;

-- what is the gender distribution per branch?
select
	gender,
    count(*) as gender_cnt
from sales
where branch = "C"
group by gender
order by gender_cnt desc;

-- which time of the day do customers give most rating?
select 
	time_of_day,
    avg(rating) as avg_rating
from sales
group by time_of_day
order by avg_rating desc;

-- which time of the day do customers give most ratings per branch?
select 
	time_of_day,
    avg(rating) as avg_rating
from sales
where branch = "A"
group by time_of_day
order by avg_rating desc;

-- which day of the week has the best avg ratings?
select
	day_name,
    avg(rating) as avg_rating
from sales
group by day_name
order by avg_rating desc;

-- which day of the week has the best average ratings per branch?
select
    branch,
    dayname(date) AS day_of_week,
    avg(rating) AS avg_rating
from sales
group by branch, dayname(date);





