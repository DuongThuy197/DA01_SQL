--1/ Doanh thu theo từng ProductLine, Year  và DealSize
select productline, year_id, dealsize, sum(sales) as revenue
from sales_dataset_rfm_prj_clean
group by productline, year_id, dealsize
order by productline, year_id, dealsize

--2/ Đâu là tháng có bán tốt nhất mỗi năm
with cte as (
	select
	year_id,
	month_id, 
	revenue,
	row_number() over(partition by year_id order by revenue desc) as order_number
	from (select year_id, month_id, sum(sales) as revenue
	from sales_dataset_rfm_prj_clean
	group by year_id, month_id
	order by year_id, month_id) as a
)
select * from cte where order_number = 1

--3/ Product line nào được bán nhiều ở tháng 11
with revenue_11 as (
	select year_id, productline, revenue,
row_number() over(partition by year_id order by revenue desc) as order_number
from(
	select year_id, productline, sum(sales) as revenue
from sales_dataset_rfm_prj_clean
where month_id = 11
group by year_id, productline
order by year_id, sum(sales) desc
) as b
)
select * from revenue_11 where order_number = 1

--4/ Đâu là sản phẩm có doanh thu tốt nhất ở UK mỗi năm
with cte as (
	select year_id, productline, revenue, 
rank() over(partition by year_id order by revenue desc) as ranking
from(
	select year_id, productline, sum(sales) as revenue
from sales_dataset_rfm_prj_clean
where country = 'UK'
group by year_id, productline
) as c
)
select * from cte where ranking = 1

--5/ Ai là khách hàng tốt nhất, phân tích dựa vào RFM
with maxPurchaseDate as (
	select max(orderdate) as max_order_date
	from sales_dataset_rfm_prj_clean
), lastPurchaseDate as (
	select customername, max(orderdate) as last_order_date
	from sales_dataset_rfm_prj_clean
	group by customername	
),Recency as(
	select customername,  
	extract(day from maxPurchaseDate.max_order_date - lastPurchaseDate.last_order_date) as R
	from maxPurchaseDate, lastPurchaseDate
),Frequency_Monetary as (
	select customername,
	count(distinct ordernumber) as F,
	sum(sales) as M
	from sales_dataset_rfm_prj_clean
	group by customername
), customer_RFM as (
	select a.customername, a.R, b.F, b.M
	from Recency as a inner join Frequency_Monetary as b
	on a.customername = b.customername
),RFM_score as(
	select customername,
	ntile(5) over(order by R desc) as R_score,
	ntile(5) over(order by F) as F_score,
	ntile(5) over(order by M) as M_score
	from customer_RFM
),RFM_final as(
select customername,
cast(R_score as varchar) || cast(F_score as varchar) || cast(M_score as varchar) as RFM_score
from rfm_score
)
select * 
from(
	select c.customername, d.segment from RFM_final c
	inner join segment_score d
	on c.RFM_score = d.scores
	where d.segment = 'Champions'
)


















