--EX 1:
select b.CONTINENT,  floor(avg(a.POPULATION))
from CITY as a
inner join COUNTRY as b
on a.COUNTRYCODE = b.CODE
group by b.CONTINENT
-- EX 2:
SELECT ROUND(COUNT(b.email_id)::DECIMAL
    /COUNT(DISTINCT a.email_id),2) AS confirm_rate
FROM emails as a
LEFT JOIN texts as b
ON a.email_id = b.email_id AND b.signup_action = 'Confirmed'
-- EX 3:
select b.age_bucket,
round(((sum(a.time_spent) filter (where activity_type = 'send')) / sum(a.time_spent))*100.0,2) as send_perc,
round(((sum(a.time_spent) filter (where activity_type = 'open')) / sum(a.time_spent))*100.0,2) as open_perc
from activities as a
inner join age_breakdown as b
on a.user_id = b.user_id
where a.activity_type in ('send','open')
group by b.age_bucket
-- EX 4:
  select a.customer_id
from customer_contracts as a
inner join products as b
on a.product_id = b.product_id
group by customer_id
having count(distinct b.product_category) >=3
-- EX 5:
SELECT  m.employee_id, m.name, COUNT(e.employee_id) AS reports_count,
ROUND(AVG(e.age)) AS average_age
FROM employees m
LEFT JOIN employees e
ON m.employee_id = e.reports_to
GROUP BY m.employee_id, m.name
HAVING COUNT(e.employee_id) > 0
ORDER BY m.employee_id
-- EX 6:
select p.product_name, sum(o.unit) as unit from Products as p
inner join Orders as o
on p.product_id = o.product_id
where extract(month from order_date) = 2 and extract(year from order_date) = 2020
group by p.product_name
having sum(o.unit) >= 100
order by sum(o.unit) DESC
-- EX 7:
select a.page_id from pages as a
left join page_likes as b
on a.page_id = b.page_id
where liked_date is null
order by a.page_id 
  
-- Mid-course test
-- EX 1:
select film_id, sum(replacement_cost) from film
group by film_id
order by sum(replacement_cost)
-- EX 2:
select 
case
    when replacement_cost between 9.99 and 19.99 then 'low'
    when replacement_cost between 20.00 and 24.99 then 'medium'
    when replacement_cost between 25.00 and 29.99 then 'high'
end category,
count (*) as total_films
from film
group by category
-- EX 3:
select a.title, a.length, d.name from film as a
inner join film_category as b on a.film_id = b.film_id
inner join category as d on d.category_id = b.category_id
where d.name = 'Drama' or name = 'Sports'
order by a.length desc
-- EX 4:
select d.name, count(a.film_id)
from film as a
inner join film_category as b on a.film_id = b.film_id
inner join category as d on d.category_id = b.category_id
group by d.name
order by count(a.film_id) desc
-- EX 5:
select actor.first_name, actor.last_name, count(film.film_id) from film 
inner join film_actor on film.film_id = film_actor.film_id
inner join actor on actor.actor_id = film_actor.actor_id
group by actor.first_name, actor.last_name
order by count(film.film_id) desc
-- EX 6:
select count(address.address_id) from address
left join customer on address.address_id = customer.address_id
where customer.address_id is null
-- EX 7:
select a.city, sum(amount) as revenue from city as a
inner join address as b on a.city_id = b.city_id
inner join customer as c on b.address_id = c.address_id
inner join payment as d on c.customer_id = d.customer_id
group by a.city
order by sum(amount) desc
-- EX 8:
select a.city || ',' || e.country as "city, country" , sum(amount) as revenue from city as a
inner join country as e on a.country_id = e.country_id
inner join address as b on a.city_id = b.city_id
inner join customer as c on b.address_id = c.address_id
inner join payment as d on c.customer_id = d.customer_id
group by a.city || ',' || e.country
order by sum(amount) 


