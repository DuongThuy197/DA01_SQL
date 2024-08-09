-- EX 1:
SELECT
    SUM(CASE WHEN device_type = 'laptop' THEN 1 ELSE 0 END) AS laptop_views,
    SUM(CASE WHEN device_type IN ('phone', 'tablet') THEN 1 ELSE 0 END) AS mobile_views
FROM
    viewership
-- EX 2:
select *,
case
    when x + y > z then 'Yes'
    when x + y < z then 'No'
end as triangle
from Triangle 
-- EX 3:
SELECT
    ROUND((COUNT(CASE
        WHEN call_category IS NULL OR call_category = 'n/a' THEN 1
        ELSE NULL
    END) * 100.0 / COUNT(*)),1) AS uncategorised_call_pct
FROM callers
-- EX 4:
select name
from Customer
where referee_id != 2 or referee_id is null
-- EX 5:
select pclass,
     sum(case when survived = 0 then 1 else 0 end) as non_survived,
     sum(case when survived = 1 then 1 else 0 end) as survived
from titanic
group by pclass
