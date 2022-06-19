--Q10: The sales team wants to build another list of KPIs to measure employees' performance by category.

/* Calculation will be used:
 * (1) total sale amount for each category by a particular employee (category_sale_by_employee)
 * (2) total sale amount of all categories by a particular employee (total_sale_by_employee)
 * (3) total sale amount for each category by all employees (total_category_sale)
 * (4) percentage of total sales amount including discount against the total sales amount for each employee (4) = (1)/(2)
 * (5) percentage of the total category sales amount by each employee against the total category sales amount by all employees (percent_of_category_sale) (5)= (1)/(3)
*/

with product_sale as 
(
	select product_id
	, round(sum((unit_price*quantity)*(1-discount))::numeric, 2) as rounded_total_product_sale
	from order_details
	group by product_id
)
, category_sale as 
--calculate the total sale amount of each category (3)
(
	select category_id 
	, sum(rounded_total_product_sale) as total_category_sale
	from product_sale as t1
	join products as t2
	on t1.product_id = t2.product_id
	group by 1
)
, product_sale_employee as
(
	select employee_id
	, product_id
	, unit_price
	, quantity
	, discount
	, round(((unit_price*quantity)*(1-discount))::numeric, 2) as rounded_amount
	from order_details t1
	join orders t2
	on t1.order_id=t2.order_id
) 
, category_sale_by_employee as 
--calculate the total sale amount of each category by each employee (1)
(
	select employee_id
	, category_id 
	, sum(rounded_amount) as category_sale_by_employee
	from product_sale_employee t1
	join products t2
	on t1.product_id = t2.product_id
	group by 1, 2
)
, total_sale_by_employee as 
--calculate the total sale amount by each employee (2)
(
	select employee_id
	, sum(category_sale_by_employee) as total_sale_by_employee
	from category_sale_by_employee
	group by 1
)
, percent_of_employee_sale as
(
	select t1.employee_id
	--percentage of total sales amount including discount against the total sales amount for each employee (4) = (1)/(2) 
	, category_id 
	, category_sale_by_employee
	, total_sale_by_employee
	, round(((category_sale_by_employee/total_sale_by_employee)*100)::numeric, 2) as percent_of_employee_sale
	from total_sale_by_employee t1
	join category_sale_by_employee t2
	on t1.employee_id = t2.employee_id
)
, percent_of_category_sale as 
--calculate percentage of the total category sales amount by each employee against the total category sales amount by all employees (percent_of_category_sale) (5)= (1)/(3)
(
select employee_id
, t1.category_id
, category_sale_by_employee
, total_category_sale
, round(((category_sale_by_employee/total_category_sale)*100)::numeric, 2) as percent_of_category_sale
from category_sale_by_employee t1
join category_sale t2
on t1.category_id = t2.category_id
)
, combined_table as 
(
	select t1.category_id 
	, t1.employee_id
	, t1.category_sale_by_employee
	, total_category_sale
	, total_sale_by_employee
	, percent_of_category_sale
	, percent_of_employee_sale
	from percent_of_category_sale t1
	join percent_of_employee_sale t2
	on t1.category_id = t2.category_id 
	and t1.employee_id = t2.employee_id
)
select category_name
, concat(first_name,' ', last_name) as employee_full_name
, category_sale_by_employee
, total_category_sale
, total_sale_by_employee
, percent_of_category_sale
, percent_of_employee_sale
from combined_table t1
join categories t2
on t1.category_id = t2.category_id 
join employees t3
on t1.employee_id = t3.employee_id
order by 1, 2;