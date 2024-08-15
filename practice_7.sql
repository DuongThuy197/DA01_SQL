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
  SELECT user_id, transaction_date,
  count(product_id) over(partition by user_id, transaction_date) as purchase_count
  FROM user_transactions
  order by user_id, transaction_date desc
)
select transaction_date, user_id, purchase_count,
rank() over(partition by user_id order by transaction_date desc) as rk
from count_product
