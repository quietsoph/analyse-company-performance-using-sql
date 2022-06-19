/*Q8: The Pricing Team wants to know for each currently offered products, how their unit price compares against their categories average and mediam unit price.
 */
--DONE 

with category_product as
--create a temporary table to get category name for each product
(
select
	c.category_id
	,
	c.category_name 
	,
	p.product_name 
	,
	p.unit_price
from
	products p
full outer join categories c 
	on
	p.category_id = c.category_id
where
	p.discontinued = 0
order by
	c.category_name,
	p.product_name
)
,
category_avg_median as
--create a temporary table to calculate each category's average unit price and median unit price
(
select
	category_name
	,
	round(avg(unit_price)::numeric, 2) as average_category_unit_price
	,
	round(percentile_cont(0.5) within group(order by unit_price)::numeric, 2) as median_category_unit_price
from
	category_product cp
group by
	category_name
)
select
	cam.category_name
	--
, cp.product_name
,
	cp.unit_price
,
	cam.average_category_unit_price
,
	cam.median_category_unit_price
,
	case
		--compare a product's unit price against its category average unit price.
	when cp.unit_price < cam.average_category_unit_price then 'Below Average'
		when cp.unit_price = cam.average_category_unit_price then 'Equal Average'
		else 'Over Average'
	end average_unit_price_position
,
	case
		--compare a product's unit price against its category median unit price. 
	when cp.unit_price < cam.median_category_unit_price then 'Below Median'
		when cp.unit_price = cam.median_category_unit_price then 'Equal Median'
		else 'Over Median'
	end
from
	category_avg_median cam
join category_product cp 
on
	cam.category_name = cp.category_name;