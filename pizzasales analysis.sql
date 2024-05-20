Create database Pizzasale;
use Pizzasale;

create table orders (
order_id int not null ,
order_date date not null,
order_time time not null,
primary key(order_id) );

create table order_details (
order_details_id int not null,
order_id int not null ,
pizza_id text  not null,
quantity int not null,
primary key(order_details_id) );

-- Retrive the total number of orders placed

select count(order_id) as total_orders from orders;

-- Caluclate total revenue genrated from pizza sales

select round(sum(od.quantity*p.price),0) as total_revenue 
from order_details as od 
join pizzas as p
on od.pizza_id=p.pizza_id;

-- highest priced pizza

select pt.name, p.price 
from pizza_types as pt
join pizzas as p
on pt.pizza_type_id=p.pizza_type_id
order by p.price desc
limit 1; 

-- most common pizza size ordered

select p.size, count(od.order_details_id) as Order_count
from pizzas as p
join order_details as od
on p.pizza_id=od.pizza_id
group by p.size
order by order_count desc
limit 1;

-- top 5 most ordred pizza types along with their quantities.

select pt.name, sum(od.quantity) as quantity
from pizza_types as pt
join pizzas as p
on pt.pizza_type_id=p.pizza_type_id
join order_details as od
on od.pizza_id=p.pizza_id
group by pt.name
order by quantity desc
limit 5; 

-- find the total quantity of each pizza category orderd.

select pt.category, sum(od.quantity) as quantity
from pizza_types as pt
join pizzas as p
on pt.pizza_type_id=p.pizza_type_id
join order_details as od
on od.pizza_id=p.pizza_id
group by pt.category
order by quantity desc;

-- determine the distribution of orders by hour of the day

select hour(order_time) as hour_distribution , count(order_id) as order_count
from orders
group by hour_distribution
order by order_count desc;

-- find the categories wise pizza distribution

select category, count(name) as quantity
from pizza_types
group by category;

-- group the orders by date and calculate the average numbers of pizzas order per day

select round(avg(quantity),0) as avg_quantity from 
  (select o.order_date, sum(od.quantity) as quantity
   from orders as o
   join order_details as od 
   on o.order_id = od.order_id
   group by o.order_date)
as order_quantity;

-- top 3 most pizza type based on revenue

select pt.name as name, sum(od.quantity*p.price) as revenue
from pizza_types as pt
join pizzas as p
on p.pizza_type_id=pt.pizza_type_id
join order_details as od
on od.pizza_id=p.pizza_id
group by pt.name
order  by revenue desc
limit 3;

-- calucate percentage contibution  of each pizza type to total revenue

select pt.category as category, 
round(sum(od.quantity*p.price) /(select round(sum(od.quantity*p.price),0) as total_revenue 
from order_details as od 
join pizzas as p
on od.pizza_id=p.pizza_id)*100,0) as perctange_conribution_in_revenue
from pizza_types as pt
join pizzas as p
on p.pizza_type_id=pt.pizza_type_id
join order_details as od
on od.pizza_id=p.pizza_id
group by category
order  by  perctange_conribution_in_revenue desc;

-- analyze the cumulative revenue generated over time

select order_date,
sum(revenue) over (order by order_date) as cum_revenue
from
(select o.order_date , sum(od.quantity*p.price) as revenue
from order_details as od
join pizzas as p
on od.pizza_id=p.pizza_id
join orders as o
on o.order_id=od.order_id
group by o.order_date) as sales;

-- determine the top 3 most ordered pizza type based on revenue for each pizza category.

select category,name, revenue
from 
(select category, name, revenue,
rank() over(partition by category order by revenue desc ) as rn 
from 
(select pt.category, pt.name, sum(od.quantity*p.price) as revenue
from pizza_types as pt
join pizzas as p
on pt.pizza_type_id=p.pizza_type_id
join order_details as od
on od.pizza_id=p.pizza_id
group by pt.category,pt.name) as pz) as a
where rn<=3;