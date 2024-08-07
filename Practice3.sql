-- EX 1:
select name 
from STUDENTS
where Marks > 75
order by right(Name, 3), ID
-- EX 2:
SELECT user_id, upper(left(name, 1)) || lower(right(name, length(name) - 1)) AS name
FROM Users
-- EX 3:
select manufacturer,
'$' || round(sum(total_sales)/1000000,0) ||' '|| 'million' as sales_mil
from pharmacy_sales
group by manufacturer
order by sum(total_sales) DESC, manufacturer
--EX 4:
select extract(month from submit_date) as mth,
product_id,
round(avg(stars),2) as avg_stars
from reviews
group by extract(month from submit_date), product_id
order by extract(month from submit_date), product_id
-- EX 5:
SELECT sender_id, count(message_id) as message_count
FROM messages
where extract(YEAR from sent_date) = 2022 and extract(month from sent_date) = 08
group by sender_id
order by count(message_id) DESC
LIMIT 2
-- EX 6:
select tweet_id
from Tweets
where length(content) > 15
-- EX 7:
-- EX 8:
select count(id)
from employees
where extract (year from joining_date) = 2022 and
extract(month from joining_date) between 1 and 7
-- EX 9:
select position('a' in first_name) from worker
where first_name = 'Amitah'
-- EX 10:
select title,
left(substring(title from position(' 'in title)),5) as vintage_year
from winemag_p2
where country = 'Macedonia'
