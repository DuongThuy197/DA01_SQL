-- EX 1:
with spend_by_year as (
  select extract(year from transaction_date) as year,
  product_id,
  sum(spend) over(partition by product_id,extract(year from transaction_date)) as curr_year_spend
  from user_transactions
)
select *,
lag(curr_year_spend) over(partition by product_id order by year) as prev_year_spend,
round(((curr_year_spend - lag(curr_year_spend) over(partition by product_id order by year))
/lag(curr_year_spend) over(partition by product_id order by year)) * 100.0,2) as yoy_rate
from spend_by_year
-- EX 2:
with cte as(
  select card_name,
  first_value (issued_amount) over(partition by card_name order by issue_year, issue_month) as issued_amount,
  row_number() over (partition by card_name order by issue_year, issue_month) AS stt
  from monthly_cards_issued)
select card_name, issued_amount
from cte
where stt = 1
order by issued_amount desc
-- EX 3:
with ranking as (
  SELECT *,
  rank() over(partition by user_id order by transaction_date) as ranking
  FROM transactions
  order by user_id, transaction_date
)
select user_id, spend,transaction_date
from ranking
where ranking = 3
-- EX 4:
with count_product as (
  select user_id,
  transaction_date,
  count(product_id) as purchase_count
  from user_transactions
  group by user_id, transaction_date
  order by user_id, transaction_date desc
), 
ranking as(
  select *,
  row_number() over(partition by user_id) as rk
  from count_product
)
select transaction_date, user_id, purchase_count
from ranking
where rk = 1
order by transaction_date
-- EX 6:
with ranking as (
select category, product, sum(spend) as total_spend,
RANK() OVER (PARTITION BY category order by sum(spend) desc) AS rank
from product_spend
where extract(year from transaction_date) = 2022
group by category, product
order by category
)
select category, product, total_spend from ranking where rank <= 2
-- EX 7:

