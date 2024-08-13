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
with previous_month as (
    select user_id, event_date
    from user_actions 
    where extract (month from event_date) = month - 1
),
current_month as (
    select user_id, month as month
    from user_actions 
    where extract (month from event_date) = month)
select b.month, count(distinct b.user_id) as monthly_active_users
from previous_month as a
inner join current_month as b 
on a.user_id = b.user_id
group by b.month
-- EX 6:
WITH count AS (
    SELECT
        EXTRACT(YEAR FROM trans_date) || '-' || EXTRACT(MONTH FROM trans_date) AS month,
        country,
        COUNT(id) AS approved_count
    FROM Transactions
    WHERE state = 'approved'
    GROUP BY EXTRACT(YEAR FROM trans_date), EXTRACT(MONTH FROM trans_date), country
),
sum_approved_amount AS (
    SELECT
        EXTRACT(YEAR FROM trans_date) || '-' || EXTRACT(MONTH FROM trans_date) AS month,
        country,
        SUM(amount) AS approved_total_amount
    FROM Transactions
    WHERE state = 'approved'
    GROUP BY EXTRACT(YEAR FROM trans_date), EXTRACT(MONTH FROM trans_date), country
)
SELECT
    EXTRACT(YEAR FROM b.trans_date) || '-' || EXTRACT(MONTH FROM b.trans_date) AS month,
    b.country,
    COUNT(b.id) AS total_count,
    SUM(b.amount) as trans_total_amount,
    c.approved_count,
    d.approved_total_amount
FROM Transactions b
INNER JOIN count c
    ON EXTRACT(YEAR FROM b.trans_date) || '-' || EXTRACT(MONTH FROM b.trans_date) = c.month
    AND b.country = c.country
INNER JOIN sum_approved_amount d
    ON EXTRACT(YEAR FROM b.trans_date) || '-' || EXTRACT(MONTH FROM b.trans_date) = d.month
    AND b.country = d.country
GROUP BY
    EXTRACT(YEAR FROM b.trans_date) || '-' || EXTRACT(MONTH FROM b.trans_date),
    b.country,
    c.approved_count,
    d.approved_total_amount
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
