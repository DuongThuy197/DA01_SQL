-- 1/ Số lượng đơn hàng và số lượng khách hàng mỗi tháng
select FORMAT_TIMESTAMP('%Y-%m', TIMESTAMP(created_at)) as month_year,
count( distinct user_id) as total_user,
count(order_id) as total_orde
from bigquery-public-data.thelook_ecommerce.orders
where created_at between '2019-01-01' and '2022-04-30'
group by FORMAT_TIMESTAMP('%Y-%m', TIMESTAMP(created_at))

=> Số lượng đơn hàng và lượng khách tăng dần theo từng tháng
-- 2/ Giá trị đơn hàng trung bình (AOV) và số lượng khách hàng mỗi tháng
select FORMAT_TIMESTAMP('%Y-%m', TIMESTAMP(created_at)) as month_year,
count( distinct user_id) as total_user,
sum(sale_price) / count(distinct order_id) as AOV
from  bigquery-public-data.thelook_ecommerce.order_items
where created_at between '2019-01-01' and '2022-04-30'
group by FORMAT_TIMESTAMP('%Y-%m', TIMESTAMP(created_at))

  => AOV thường dao động trong khoảng từ 80 - 90, T1/2019 là tháng có giá trị đơn hàng trung bình cao nhất (114.95)
--3/ Tìm các khách hàng có trẻ tuổi nhất và lớn tuổi nhất theo từng giới tính
-- Male
WITH total_user AS (
  SELECT users.first_name, users.last_name, users.age, users.gender
  FROM bigquery-public-data.thelook_ecommerce.users AS users
  INNER JOIN bigquery-public-data.thelook_ecommerce.orders AS orders
  ON users.id = orders.user_id
  WHERE orders.created_at BETWEEN '2019-01-01' AND '2022-04-30'
),male_user as(
    SELECT first_name, last_name, age
    FROM total_user
    WHERE gender = 'M'
    order by age
)
select count(*) as total_youngest_male
from male_user
where age = (select min(age) from male_user)
union distinct
select count(*) as total_oldest_male
from male_user
where age = (select max(age) from male_user)

--Female
WITH total_user AS (
  SELECT users.first_name, users.last_name, users.age, users.gender
  FROM bigquery-public-data.thelook_ecommerce.users AS users
  INNER JOIN bigquery-public-data.thelook_ecommerce.orders AS orders
  ON users.id = orders.user_id
  WHERE orders.created_at BETWEEN '2019-01-01' AND '2022-04-30'
),female_user as(
    select first_name, last_name, age
    from total_user
    where gender = 'F'
    order by age
)
select count(*) as total_youngest_female
from female_user
where age = (select min(age) from female_user)
union distinct
select count(*) as total_oldest_female
from female_user
where age = (select max(age) from female_user)

  => Đối với cả Male vs Female: khách có độ tuổi trẻ nhát là 12 tuổi, già nhất là 70 tuổi. Số lượng người trẻ nhiều hơn số lượng người già
 
-- 4/ Thống kê top 5 sản phẩm có lợi nhuận cao nhất từng tháng
with sale as (
    select FORMAT_TIMESTAMP('%Y-%m', TIMESTAMP(oi.created_at)) as month_year,
    p.id,
    p.name,
    sum(sale_price) as total_sale,
    sum(cost) as total_cost,
    sum(sale_price) - sum(cost) as total_profit
    from bigquery-public-data.thelook_ecommerce.products as p
    inner join bigquery-public-data.thelook_ecommerce.order_items as oi
    on p.id = oi.product_id
    group by month_year, p.id, p.name
    order by month_year
), ranking as (
select *,
dense_rank() over(partition by month_year order by total_profit) as rank
from sale
order by month_year
)
select *from ranking where rank <= 5

--5/ Thống kê tổng doanh thu theo ngày của từng danh mục sản phẩm (category) trong 3 tháng 
SELECT 
  FORMAT_TIMESTAMP('%Y-%m-%d', TIMESTAMP(oi.created_at)) AS dates,
  p.category AS product_categories,
  SUM(oi.sale_price) AS revenue
  FROM 
  bigquery-public-data.thelook_ecommerce.order_items AS oi
 INNER JOIN 
  bigquery-public-data.thelook_ecommerce.products AS p
 ON 
  oi.product_id = p.id
  WHERE oi.created_at BETWEEN TIMESTAMP('2022-01-15') AND TIMESTAMP('2022-04-14')
  GROUP BY 
  dates, product_categories
ORDER BY 
  dates, product_categories;
