/* Question 6: Category performance. The Pricing Team wants to know each category performs according to their price.
*/

with products_in_orders as
/*create a temporary table getting all products with their orders, their initial unit price, current unit price
 * in each order, quantity in each order, discount in each order, and amount in each order
 */
(
select
	od.product_id 
	,
	p.category_id 
	,
	p.product_name 
	,
	p.unit_price as initial_unit_price
	,
	od.order_id
	,
	od.unit_price as current_unit_price
	,
	od.quantity 
	,
	od.discount
	,
	(od.unit_price * od.quantity - od.unit_price * od.quantity * od.discount) as amount
from
	order_details od
full outer join products p 
	on
	od.product_id = p.product_id
order by
	od.product_id
)
,
category_sales as(
--create another temporary table to categorise initial unit price into different groups.
select
	po.product_name
	,
	case
		when po.initial_unit_price < 20 then 'Below 20'
		when po.initial_unit_price between 20 and 50 then '$20-$50'
		else 'Over $50'
	end price_range
	,
	c.category_name
	,
	count(po.order_id) as total_number_orders
	,
	sum(po.amount) as total_amount
from
	products_in_orders as po
full outer join categories as c 
	on
	c.category_id = po.category_id
group by
	po.product_name,
	po.initial_unit_price,
	c.category_name 
)
select
	category_name 
,
	price_range
,
	sum(total_amount)
,
	sum(total_number_orders)
from
	category_sales
group by
	category_name,
	price_range
order by
	category_name;
