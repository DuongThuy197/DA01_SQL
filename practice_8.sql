-- EX 1:
with cate_order as(
    select *,
    case
        when customer_pref_delivery_date = order_date then 'immediate'
        else 'scheduled'
    end as category
    from Delivery
), ranking as(
    select customer_id, delivery_id, order_date, category,
    rank() over(partition by customer_id order by order_date) as rank
    from cate_order
    
), top_rank as(
   select * from ranking where rank = 1 
)
SELECT ROUND(
    (COUNT(*) FILTER (WHERE category = 'immediate') * 100.0) / COUNT(*),
    2
) AS immediate_percentage
FROM top_rank
-- EX 2:
with consecutive as(
    select player_id, event_date,
    lead(event_date) over(partition by player_id order by event_date) as next_event_date,
    extract(day from lead(event_date) over(partition by player_id order by event_date)) -  
    extract(day from event_date) as diff_day,
    extract(year from lead(event_date) over(partition by player_id order by event_date)) -  extract(year from event_date) as diff_year
    from Activity
)
select round((count(distinct player_id) filter(where diff_day = 1 and diff_year = 0)::decimal)
       / count(distinct player_id),2) as fraction
from consecutive
