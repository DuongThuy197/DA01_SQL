--1/ Tạo bảng vv_ecommerce_analyst
with cte as(
select extract(month from o.created_at) as month,
    extract(year from o.created_at) as year,
    p.category,
    sum(oi.sale_price) as TPV,
    count(distinct oi.order_id) as TPO,
    sum(p.cost) as total_cost,
    sum(oi.sale_price) - sum(p.cost) as total_profit,
    (sum(oi.sale_price) - sum(p.cost)) / sum(p.cost) as profit_to_cost_ratio
    from bigquery-public-data.thelook_ecommerce.orders as o
    inner join bigquery-public-data.thelook_ecommerce.order_items as oi
    on o.order_id = oi.order_id
    inner join bigquery-public-data.thelook_ecommerce.products as p
    on p.id = oi.product_id
    group by  extract(year from o.created_at), extract(month from o.created_at), p.category
), vw_ecommerce_analyst as(
  select month, year, category, total_cost, total_profit, profit_to_cost_ratio,
  TPV,
  lag(TPV) over(partition by category order by year, month) as last_TPV,
  (TPV - lag(TPV) over(partition by category order by year, month)) / lag(TPV) over(partition by category order by year, month) as revenue_growth,
  TPO,
  lag(TPO) over(partition by category order by year, month) as last_TPO,
  (TPO - lag(TPO) over(partition by category order by year, month)) / lag(TPO) over(partition by category order by year, month) as order_growth
  from(
  select * from cte
  order by category, year, month)
  order by category, year, month
)
select month, year, category, TPV, revenue_growth, TPO, order_growth, total_cost, total_profit, profit_to_cost_ratio
from vw_ecommerce_analyst

-- 2/ Retention cohort analysis
WITH cohort_index AS (
  SELECT 
    user_id,
    sale_price,
    FORMAT_TIMESTAMP('%Y-%m', TIMESTAMP(first_purchase_date)) AS cohort_date,
    (EXTRACT(YEAR FROM created_at) - EXTRACT(YEAR FROM first_purchase_date)) * 12
    + (EXTRACT(MONTH FROM created_at) - EXTRACT(MONTH FROM first_purchase_date)) + 1 AS index,
    created_at
  FROM (
    SELECT 
      u.id AS user_id,
      oi.order_id,
      oi.product_id,
      oi.sale_price,
      oi.created_at,
      MIN(oi.created_at) OVER(PARTITION BY u.id) AS first_purchase_date
    FROM 
      `bigquery-public-data.thelook_ecommerce.order_items` AS oi
    INNER JOIN 
      `bigquery-public-data.thelook_ecommerce.users` AS u
    ON 
      oi.user_id = u.id
    ORDER BY 
      u.id, oi.order_id
  ) AS a
), cohort_index_4month AS (
  SELECT * 
  FROM cohort_index
  WHERE index <= 4
), cohort_final AS (
  SELECT 
    cohort_date, 
    index,
    COUNT(DISTINCT user_id) AS cnt,
    SUM(sale_price) AS revenue
  FROM 
    cohort_index_4month
  GROUP BY 
    cohort_date, index
), pivot_table AS (
  SELECT 
    cohort_date,
    SUM(CASE WHEN index = 1 THEN cnt ELSE 0 END) AS m1,
    SUM(CASE WHEN index = 2 THEN cnt ELSE 0 END) AS m2,
    SUM(CASE WHEN index = 3 THEN cnt ELSE 0 END) AS m3,
    SUM(CASE WHEN index = 4 THEN cnt ELSE 0 END) AS m4
  FROM 
    cohort_final
  GROUP BY 
    cohort_date
)
SELECT 
  cohort_date,
  round(100* m1/m1,2) || '%' as m1,
	round(100 * m2/m1,2) || '%' as m2,
	round(100 * m3/m1,2) || '%' as m3,
	round(100 * m4/m1,2) || '%' as m4
FROM 
  pivot_table
ORDER BY cohort_date
