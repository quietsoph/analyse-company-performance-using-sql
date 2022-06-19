--Q2: Which countries they didn't perform well in 1998

select
	ship_country
,
	round(avg(extract(doy from shipped_date)-extract(doy from order_date)), 2) as average_days_between_order_shipping
	--convert dates into the date of the year to do substraction 
,
	count(distinct order_id) as total_number_orders
from
	orders
where
	extract(year from order_date) = '1998'
	--filter the orders from the year 1998 only
group by
	ship_country
having
	round(avg(extract(doy from shipped_date)-extract(doy from order_date)), 2) >= 5
	and count(distinct order_id) > 10
order by
	ship_country;
