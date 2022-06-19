--(1)total_sale_amount = total sale amount for each category by a particular employee
--(2)total sale amount over all categories by a particular employee
--(3)total sale amount for each categogry by all employees
--%_of_employee_sale = (1)/(2)
--%_of_category_sale = (1)/(3)

--DONE

with sale_per_product as 
--calculate the sale amount for each product
(
	select product_id
	, sum(unit_price*quantity*(1-od.discount)) as amount_per_product
	from order_details od
	group by product_id
)
, sale_per_category as
(
	select category_id
	--calculate total sale amount for each category (3)
	, round(sum(amount_per_product)::numeric, 2) as total_amount_per_category
	from sale_per_product t1
	join products t2
	on t1.product_id = t2.product_id 
	group by 1
)
, sale_per_employee as 
(
	--calculate total sale amount over all categories by each employee (2)
	select employee_id
	, round(sum(unit_price*quantity*(1-t1.discount))::numeric, 2) as total_amount_per_employee
	from order_details t1
	join orders t2
	on t1.order_id = t2.order_id
	group by employee_id
)
--calculate total sale amount for each category by a particular employee (1)
,sale_per_category_per_employee as 
(
	select employee_id
	, category_id
	, round(sum(t1.unit_price*quantity*(1-t1.discount))::numeric, 2) as total_amount_per_category_per_employee
	from order_details t1
	join products t2
	on t1.product_id = t2.product_id
	join orders t3
	on t1.order_id = t3.order_id
	group by employee_id, category_id
)
--%_of_employee_sale = (1)/(2)
, percent_of_employee_sale as 
(
	select t1.employee_id
	, category_id
	, total_amount_per_category_per_employee
	, total_amount_per_employee
	, round((total_amount_per_category_per_employee/total_amount_per_employee)*100::numeric, 2) as percent_of_employee_sale
	from sale_per_category_per_employee t1
	join sale_per_employee t2
	on t1.employee_id = t2.employee_id
	order by 1, 2
)
--%_of_category_sale =(1)/(3)
, percent_of_category_sale as 
(
	select t1.category_id
	, employee_id
	, total_amount_per_category_per_employee
	, total_amount_per_category
	, round((total_amount_per_category_per_employee/ total_amount_per_category)*100::numeric, 2) as percent_of_category_sale
	from sale_per_category_per_employee t1
	join sale_per_category t2
	on t1.category_id = t2.category_id 
	order by t1.category_id, employee_id
)
--unite 
, employee_performance as 
(
	select t1.employee_id
	, t1.category_id
	, t1.total_amount_per_category_per_employee
	, total_amount_per_category
	, total_amount_per_employee
	, percent_of_category_sale
	, percent_of_employee_sale
	from percent_of_employee_sale t1
	full outer join percent_of_category_sale t2
	on t1.employee_id = t2.employee_id and t1.category_id = t2.category_id
)
select category_name
, concat(t2.first_name,' ', t2.last_name) as employee_full_name
, total_amount_per_category_per_employee
, total_amount_per_category
, total_amount_per_employee
, percent_of_category_sale
, percent_of_employee_sale
from employee_performance t1
join employees t2
on t1.employee_id = t2.employee_id
join categories t3
on t1.category_id = t3.category_id
order by 1, 2