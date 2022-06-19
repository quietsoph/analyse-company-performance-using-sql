--DONE

/* Q7: The Logistics Team wants to know what is the current state of regional suppliers' stocks
 * for each catagory of products.
 */ 

/*Query a list of countries (distinct) and categorise them into regions.
 * America: Brazil, Canada, USA
 * Europe: Denmark, Finland, France, Germany, Italy, Netherlands, Norway, Spain, Sweden, UK
 * Asia-Pacific: Australia, Japan, Singapore
 */

select
	c.category_name
,
	case
		when s.country in ('Brazil', 'Canada', 'USA') then 'America'
		when s.country in ('Denmark', 'Finland', 'France', 'Germany', 'Italy', 'Netherlands', 'Norway', 'Spain', 'Sweden', 'UK') then 'Europe'
		when s.country in ('Australia', 'Japan', 'Singapore') then 'Asia-Pacific'
		else ''
	end as supplier_region
,
	sum(p.unit_in_stock) as units_in_stock
,
	sum(p.unit_on_order) as units_on_order
,
	sum(p.reorder_level) as reorder_level
from
	products p
join categories c 
on
	p.category_id = c.category_id
join suppliers s 
on
	p.supplier_id = s.supplier_id
group by
	1,
	2
order by
	1 asc,
	5 asc;
