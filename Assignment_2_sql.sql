explain analyze
select a.id,
	a.name,
	a.total_orders,
	b.product_category,
	b.category_count
from 
(
	select c.id,
		c.name,
		count(o.client_id) as total_orders
	from opt_clients c
	left join opt_orders o
	on c.id = o.client_id 
	where c.status = 'active' and o.order_date >= '2025-01-01' and o.order_date <= '2025-12-31'
	group by c.id,
		c.name
	order by c.id
) as a
left join 
(
	select o.client_id,
		p.product_category,
		count(p.product_category) as category_count
	from opt_orders o
	left join opt_products p
	on o.product_id = p.product_id 
	where o.order_date >= '2025-01-01' and o.order_date <= '2025-12-31'
	group by o.client_id, 
		p.product_category 
) as b
on a.id = b.client_id
order by a.id

create index if not exists idx_opt_orders_client_id on opt_orders(client_id);
create index if not exists idx_opt_orders_product_id on opt_orders(product_id);
create index if not exists idx_opt_clients_status on opt_clients(status);
create index if not exists idx_opt_orders_order_date on opt_orders(order_date);

set enable_indexscan = off;
set enable_bitmapscan = off;

explain analyze
with base_data as(
	select c.id,
	c.name,
	p.product_category
	from opt_clients c
	left join opt_orders o
	on c.id = o.client_id 
	left join opt_products p 
	on o.product_id = p.product_id 
	where c.status = 'active' and o.order_date >= '2025-01-01' and o.order_date <= '2025-12-31'
)
select distinct id,
	name,
	product_category,
	count(*) over (partition by id) as total_orders,
	count(*) over (partition by id, product_category) as category_count
from base_data 
order by id;

set enable_indexscan = on;
set enable_bitmapscan = on;