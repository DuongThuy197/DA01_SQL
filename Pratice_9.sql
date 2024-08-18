--1/Chuyển đổi kiểu dữ liệu phù hợp cho các trường
alter table sales_dataset_rfm_prj 
	alter column ordernumber type integer using (trim(ordernumber):: integer),
    alter column quantityordered type integer using (trim(quantityordered):: integer),
    alter column priceeach type float using (trim(priceeach):: float),
	alter column orderlinenumber type integer using (trim(orderlinenumber):: integer),
	alter column sales type float using (trim(sales):: float),
	alter column msrp type integer using (trim(msrp):: integer)
ALTER TABLE sales_dataset_rfm_prj 
ALTER COLUMN orderdate TYPE TIMESTAMP
USING TO_TIMESTAMP(orderdate, 'MM/DD/YYYY HH24:MI')

-- 2/ Check NULL/BLANK (‘’)  ở các trường: ORDERNUMBER, QUANTITYORDERED, PRICEEACH, ORDERLINENUMBER, SALES, ORDERDATE.
SELECT count(ordernumber) FROM sales_dataset_rfm_prj WHERE ordernumber IS NULL
SELECT count(quantityordered) FROM sales_dataset_rfm_prj WHERE quantityordered IS NULL
SELECT count(priceeach) FROM sales_dataset_rfm_prj WHERE priceeach IS NULL
SELECT count(orderlinenumber) FROM sales_dataset_rfm_prj WHERE orderlinenumber IS NULL
SELECT count(sales) FROM sales_dataset_rfm_prj WHERE sales IS NULL
SELECT count(orderdate) FROM sales_dataset_rfm_prj WHERE orderdate IS NULL
--=> Không có cột nào trong số các cột ở trên bị null

/* 3/ Thêm cột CONTACTLASTNAME, CONTACTFIRSTNAME được tách ra từ CONTACTFULLNAME . 
Chuẩn hóa CONTACTLASTNAME, CONTACTFIRSTNAME theo định dạng chữ cái đầu tiên viết hoa, chữ cái tiếp theo viết thường. */
alter table sales_dataset_rfm_prj 
add column CONTACTLASTNAME char(50),
add column CONTACTFIRSTNAME char(50)
update sales_dataset_rfm_prj
set contactlastname = left(contactfullname, position('-'in contactfullname)-1),
contactfirstname =  substring(contactfullname from position('-' in contactfullname) + 1)

-- 4/Thêm cột QTR_ID, MONTH_ID, YEAR_ID lần lượt là Qúy, tháng, năm được lấy ra từ ORDERDATE 
alter table sales_dataset_rfm_prj 
add column QTR_ID int,
add column MONTH_ID int,
add column YEAR_ID int

update sales_dataset_rfm_prj
set month_id = extract(month from orderdate),
    year_id = extract(year from orderdate)

update sales_dataset_rfm_prj
set qtr_id = case
		       when month_id in (1, 2, 3) then 1
		       when month_id in (4, 5, 6) then 2
		       when month_id in (7, 8, 9) then 3
		       else 4
 			end

-- 5/ Hãy tìm outlier (nếu có) cho cột QUANTITYORDERED và hãy chọn cách xử lý cho bản ghi đó
-- C1: Dùng box plot
with txt_min_max as(
select Q1 - 1.5*IQR as min_value, 
Q3 + 1.5*IQR as max_value
from(
select percentile_cont(0.25) within group (order by quantityordered) as Q1,
percentile_cont(0.75) within group (order by quantityordered) as Q3,
percentile_cont(0.75) within group (order by quantityordered) - percentile_cont(0.25) within group (order by quantityordered) as IQR
from sales_dataset_rfm_prj) as a)
select * from sales_dataset_rfm_prj
where quantityordered < (select min_value from txt_min_max)
or quantityordered > (select max_value from txt_min_max)
-- C2: Dùng z-score = (users - avg)/stddev
select avg(quantityordered), stddev(quantityordered)
from sales_dataset_rfm_prj

WITH cte AS (
    SELECT 
        ordernumber, 
        quantityordered,
        (SELECT AVG(quantityordered) FROM sales_dataset_rfm_prj) AS avg_quantityordered,
        (SELECT STDDEV(quantityordered) FROM sales_dataset_rfm_prj) AS stddev_quantityordered
    FROM 
        sales_dataset_rfm_prj
),twt_outlier as(
	SELECT 
    ordernumber,
    quantityordered, 
    (quantityordered - avg_quantityordered) / stddev_quantityordered AS z_score
FROM 
    cte
WHERE abs((quantityordered - avg_quantityordered) / stddev_quantityordered)>2)
update sales_dataset_rfm_prj set quantityordered = (SELECT AVG(quantityordered) FROM sales_dataset_rfm_prj) 
	where quantityordered in (select quantityordered from twt_outlier)

-- 6/ Lưu vào bảng mới
create table SALES_DATASET_RFM_PRJ_CLEAN as
	select * from sales_dataset_rfm_prj
