--Q4: The logistics team wants to identify for which month they perform well globally over 1997-1998

select
	date_trunc('month', o.order_date)::date as year_month
,
	count(distinct o.order_id) as total_number_orders
,
	round(sum(o.freight)) as total_freight
from
	orders o
where
	o.order_date between '1997-01-01' and '1998-12-31'
group by
	1
having
	count(distinct o.order_id ) > 35
order by
	3 desc;