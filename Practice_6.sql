-- EX 1:
with duplicated_job as(
select company_id, title, description, count(job_id)
from job_listings
group by company_id, title, description
order by company_id
)
select count(distinct company_id) as duplicate_companies
from duplicated_job
where count > 1
--EX 2:
select category, product, sum(spend) as total_spend,
RANK() OVER (PARTITION BY category order by sum(spend) desc) AS rank
from product_spend
where extract(year from transaction_date) = 2022
group by category, product
order by category
)
select category, product, total_spend from ranking where rank <= 2
-- EX 3:
with cte as (
select policy_holder_id, count(case_id) 
from callers
group by policy_holder_id
)
select count(policy_holder_id) from cte 
where count >= 3
-- EX 4:
select a.page_id from pages as a
left join page_likes as b
on a.page_id = b.page_id
where liked_date is null
order by a.page_id 
-- EX 5:
select month, count(distinct user_id) as monthly_active_users
from user_actions
where month - extract(month from event_date) = 1
group by month
-- EX 6:
select TO_CHAR(trans_date,'yyyy-mm') as month,
country,
count(id) as trans_count,
count(id) filter (where state = 'approved') as approved_count,
sum(amount) as trans_total_amount,
sum(amount) filter (where state = 'approved') as approved_total_amount
from Transactions
group by TO_CHAR(trans_date,'yyyy-mm'), country
-- EX 7:
with cte as (
    select product_id,
    MIN(year) as first_year
    from Sales 
    group by product_id
)
select Sales.product_id, cte.first_year, Sales.quantity, Sales.price
from Sales join cte
on Sales.product_id = cte.product_id
and cte.first_year = Sales.year
-- EX 8:
with total_product as(
select count(distinct product_key) as total_product_key
from Customer
),
purchased_product_customer as(
    select customer_id,
    count(distinct product_key) as purchased_product_key
    from Customer
    group by Customer_id
)
select a.customer_id
from purchased_product_customer as a
inner join total_product as b
on b.total_product_key = a.purchased_product_key
-- EX 9:
with salary as (
    select *
    from Employees
    where salary < 30000
)
select salary.employee_id
from salary
where salary.manager_id not in (select employee_id as manager_id from Employees)
-- EX 10:
with duplicated_job as(
select company_id, title, description, count(job_id)
from job_listings
group by company_id, title, description
order by company_id
)
select count(distinct company_id) as duplicate_companies
from duplicated_job
where count > 1
-- EX 11:
with cte1 as(
    select Users.name, count(*) as total_rating
    from MovieRating
    join Users
    on MovieRating.user_id = Users.user_id
    group by Users.name
    order by count(*) desc, Users.name asc
    limit 1
),
cte2 as(
    select Movies.title, avg(MovieRating.rating) 
    from MovieRating
    join Movies
    on MovieRating.movie_id = Movies.movie_id
    and extract(month from MovieRating.created_at) = 2
    group by Movies.title
    order by avg(MovieRating.rating) desc, Movies.title
    limit 1
)
select name as results from cte1
union
select title as results from cte2
-- EX 12:
WITH FriendCounts AS (
    SELECT 
        requester_id AS id,
        COUNT(*) AS num
    FROM RequestAccepted
    GROUP BY requester_id

    UNION ALL

    SELECT 
        accepter_id AS id,
        COUNT(*) AS num
    FROM RequestAccepted
    GROUP BY accepter_id
)
select id, sum(num) as num from FriendCounts
group by id
limit 1
