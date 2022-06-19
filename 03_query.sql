--Q3: List of employees and their managers.
select
	concat(e.first_name, ' ', e.last_name) as employee_full_name
,
	e.title as employee_title
,
	(extract(year from e.hire_date) - extract(year from e.birth_date)) as employee_age
,
	concat(e2.first_name, ' ', e2.last_name) as manager_full_name
,
	e2.title as manager_title
from
	employees e
join employees e2 
on
	e.reports_to = e2.employee_id
order by
	3 asc,
	1 asc;