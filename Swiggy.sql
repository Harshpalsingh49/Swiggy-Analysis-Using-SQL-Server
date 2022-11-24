create database swiggy
-- IMPORTED TABLES USING EXCEL FILES

select * from orders
select * from food
select * from order_details
select * from menu
select * from restaurants
select * from users

--- Find Users who have never ordered 


select name
from users 
where user_id NOT IN  (select user_id from orders)


Delete from users
Where name is null
Delete from orders
Where user_id is null

---- Average Price/dish

select f_name,round(avg(price),0) as avg_price
from food
inner join menu on food.f_id=menu.f_id
group by f_name
order by avg_price desc

-- Find the top restaurant in terms of the number of orders for a given month


create view  top_restaurant_june
as
select r_name,count(o.r_id) as max_orders
from restaurants r
inner join orders o 
on r.r_id = o.r_id
where DATENAME(month,date) LIKE 'June'
group by r_name
order by max_orders desc 
OFFSET 0 ROWS FETCH FIRST 1 ROWS ONLY;

select * from  top_restaurant_june

---4. restaurants with monthly sales greater than x for (x=500)

select r_name,sum(o.amount) as revenue
from restaurants r
inner join orders o 
on r.r_id = o.r_id
where DATENAME(month,date) LIKE 'June' and amount>500
group by r_name
order by revenue desc 

--Show all orders with order details for a particular customer in a particular date range
-- Lets assume date range between 10th june and 10th july

select o.order_id ,r.r_name,f.f_name
from orders o
join restaurants r
on o.r_id=r.r_id
join order_details od
on o.order_id=od.order_id
join food f
on od.f_id=f.f_id
where user_id IN (select user_id from users where name='Ankit') 
and date between '2022-06-10' and '2022-07-10'

--Find restaurants with max repeated customers
with cte as (
select r_id,user_id,count(*) as visits
from orders
group by r_id,user_id
having count(*)>1)

select r_name,count(*) as loyal_cx
from cte
join restaurants r
on cte.r_id=r.r_id
group by r_name
having count(*)>1


---Month over month revenue growth of swiggy.


select DATENAME(month,date),((monthly_inc-previous_month_inc)/previous_month_inc)
from (
      with cte as (select DATENAME(month,date) as 'month',sum(amount) as monthly_inc
       from orders
       group by DATENAME(month,date))

      select month,monthly_inc,lag(monthly_inc,1,0) over(order by month desc) as previous_month_inc
      from cte

 )


 ---Customer - favorite food
 with cte as (select o.user_id,od.f_id,count(*) as freq
 from orders o
 join order_details od
 on o.order_id=od.order_id
 group by o.user_id,od.f_id)

 select name,f_name,t1.freq
 from cte t1
 join users u
 on  t1.user_id=u.user_id
 join food f
 on t1.f_id=f.f_id
 where t1.freq IN (select max(freq) from cte t2 where t2.user_id=t1.user_id)
 
