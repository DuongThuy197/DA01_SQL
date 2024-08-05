-- EX 1:
select distinct city from STATION where ID % 2 = 0
-- EX 2:
select count(CITY) - count(distinct CITY) from STATION
-- EX 3:
select ceiling(avg(salary) - avg(cast(replace(cast(salary as char), '0', ' ') as decimal))) from EMPLOYEES
-- EX 4:
select round(cast(sum(order_occurrences * item_count) / sum(order_occurrences) as DECIMAL),1) as mean from items_per_order
-- EX 5:
select candidate_id
from candidates
where skill in ('Python','Tableau','PostgreSQL')
group by candidate_id
having count(skill) = 3
-- EX 6:
SELECT user_id, max(date(post_date)) - min(date(post_date)) as days_between
from posts
group by user_id
having count(user_id) > 2
-- EX 7:
SELECT user_id, max(date(post_date)) - min(date(post_date)) as days_between
from posts
where extract(year from (post_date)) = 2021
group by user_id
having count(user_id) > 2
-- EX 8:
select manufacturer, count(drug), abs(sum(total_sales)-sum(cogs)) as total_losses
from pharmacy_sales
where cogs > total_sales
group by manufacturer
order by abs(sum(total_sales)-sum(cogs)) DESC
-- EX 9:
select * from cinema
where id % 2 !=0 and description != 'boring'
order by rating DESC
-- EX 10:
select teacher_id, count(distinct subject_id) as cnt
from Teacher
group by teacher_id
-- EX 11:
select user_id, count(follower_id) as followers_count
from Followers
group by user_id
order by user_id 
-- EX 12:
select class
from Courses
group by class
having count(student) >=5
