Select * from walmart

select Count(*) from Walmart;

Drop table walmart

Select payment_method, count(*)
from walmart 
group by payment_method;

Select count(Distinct branch)
from walmart

select max(quantity),min(quantity)
from walmart

--Business problems

--Question no.1
--What are the different payment methods, and how many transactions and items were sold with each method?

select payment_method, count(*) as No_transactions, sum(quantity) as No_quantity
from walmart
group by payment_method

--Question no. 2
--Which category received the highest average rating in each branch?
select * 
from(
select 
   branch, 
   category,
   avg(rating) as avg_rating,
   rank() over(partition by branch order by avg(rating) desc) as rank
from walmart
group by branch, category 
)
where rank = 1

--Question no.3
--What is the busiest day of the week for each branch based on transaction volume?

select * 
from(
select 
   branch,
   TO_CHAR(TO_DATE(date, 'DD/MM/YY'),'day') as formated_day,
   count(*) as No_of_transactions,
   rank() over(partition by branch order by count(*) desc) as rank
from walmart
group by branch, formated_day 
)
where rank =1

--Question no. 4
--How many items were sold through each payment method?

select payment_method, sum(quantity) as Items_sold
from walmart
group by payment_method


-- Question no.5: What are the average, minimum, and maximum ratings for each category in
-- each city?
select city, category,
     avg(rating) as avg_rating,
	 min(rating) as min_rating,
	 max(rating) as max_rating
from walmart  
group by 1,2
order by city, category


-- Question no.6: What is the total profit for each category, ranked from highest to lowest?
select 
   category,
   sum(unit_price * quantity * profit_margin) as total_profit
from walmart 
group by category 
order by total_profit desc


--Question no.7: What is the most frequently used payment method in each branch?
select *
from(
select 
   branch,
   payment_method,
   count(*) as frequency,
   rank() over (partition by branch order by count(*) desc) as rank
from walmart 
group by branch, payment_method
)
where rank =1

-- Question: How many transactions occur in each shift (Morning, Afternoon, Evening)
-- across branches?
select 
   branch,
   case 
     when EXTRACT(HOUR FROM (time::time)) <12 THEN 'morning'
	 when EXTRACT(HOUR FROM (time::time)) between 12 and 17 THEN 'afternoon'
	 else 'evening'
   end day_time,
   count(*) as No_of_trans
 
from walmart
group by branch, day_time
order by 1, 3 desc


-- Question: Which branches experienced the largest decrease in revenue compared to
-- the previous year?
--rdr = ((lst_yr_rev - this_yr_rev)/lst_yr_rev) * 100

With rev_2022 
as
(
    select 
	   branch,
       sum(total) as revenue

    from walmart
    where Extract (YEAR from TO_DATE(date, 'DD/MM/YY')) = 2022
    group by 1
),


rev_2023 
as
(
    select 
	   branch,
       sum(total) as revenue

    from walmart
    where Extract (YEAR from TO_DATE(date, 'DD/MM/YY')) = 2023
    group by 1
)

select 
   l.branch,
   l.revenue as ls_yr_rev,
   c.revenue as cr_yr_rev,
   round(((l.revenue-c.revenue)::numeric/l.revenue::numeric *100),2) as rev_dec_rate
from rev_2022 l join rev_2023 c on l.branch = c.branch
where l.revenue > c.revenue
order by 4 desc


