--Question 1: A list of products offered in the range $20 to $50

select
	product_name
,
	unit_price
from
	products p
where
	discontinued = 0
	and unit_price between 20 and 50
order by
	unit_price desc;