create table customers(
	customer_id serial primary key,
	full_name varchar(100) not null,
	email varchar(100) unique not null,
	balance numeric(10, 2) default 0
);

create table products(
	product_id serial primary key,
	product_name varchar(100) not null,
	price numeric(10, 2) not null,
	stock_quantity int not null 
);

create table orders(
	order_id serial primary key,
	customer_id int references customers(customer_id),
	order_date timestamp default current_timestamp,
	total_amount numeric(10, 2) default 0
);

create table order_items(
	order_item_id serial primary key,
	order_id int references orders(order_id),
	product_id int references products(product_id),
	quantity int not null,
	price numeric(10, 2) not null
);

create table order_log(
	log_id serial primary key,
	order_id int,
	customer_id int,
	action varchar(50),
	log_date timestamp default current_timestamp
);

insert into customers (full_name, email, balance) values
('John Smith', 'j.smith@email.com', 1500.00),
('Emma Johnson', 'e.johnson@email.com', 50.00),
('Michael Brown', 'm.brown@email.com', 3200.50),
('Emily Davis', 'e.davis@email.com', 0.00),
('David Wilson', 'd.wilson@email.com', 450.00),
('Sarah Miller', 's.miller@email.com', 120.00),
('James Taylor', 'j.taylor@email.com', 5000.00),
('Jessica Anderson', 'j.anderson@email.com', 75.50),
('Robert Thomas', 'r.thomas@email.com', 800.00),
('Lisa Jackson', 'l.jackson@email.com', 30.00);

insert into products (product_name, price, stock_quantity) values
('Laptop', 25000.00, 15),
('Mechanical Keyboard', 3500.00, 40),
('Wireless Mouse', 1200.00, 50),
('27" Monitor', 8500.00, 20),
('Noise-canceling Headphones', 4200.00, 30),
('Laptop Backpack', 1500.00, 100),
('Coffee Beans 1kg', 600.00, 80),
('Energy Drink', 65.00, 200),
('128GB Flash Drive', 450.00, 60),
('Notebook', 150.00, 150);

insert into orders (customer_id, order_date, total_amount) values
(1, current_timestamp - interval '5 days', 25000.00),
(2, current_timestamp - interval '4 days', 1200.00),
(3, current_timestamp - interval '4 days', 9100.00),
(4, current_timestamp - interval '3 days', 130.00),
(5, current_timestamp - interval '3 days', 4200.00),
(6, current_timestamp - interval '2 days', 3500.00),
(7, current_timestamp - interval '2 days', 17000.00),
(8, current_timestamp - interval '1 day', 600.00),
(9, current_timestamp - interval '1 day', 1500.00),
(10, current_timestamp, 450.00);

insert into order_items (order_id, product_id, quantity, price) values
(1, 1, 1, 25000.00),
(2, 3, 1, 1200.00),
(3, 4, 1, 8500.00),
(3, 7, 1, 600.00),
(4, 8, 2, 65.00),
(5, 5, 1, 4200.00),
(6, 2, 1, 3500.00),
(7, 4, 2, 8500.00),
(8, 7, 1, 600.00),
(9, 6, 1, 1500.00),
(10, 9, 1, 450.00);


insert into order_log (order_id, customer_id, action, log_date) values
(1, 1, 'Order Created', current_timestamp - interval '5 days'),
(2, 2, 'Order Created', current_timestamp - interval '4 days'),
(3, 3, 'Order Created', current_timestamp - interval '4 days'),
(4, 4, 'Order Created', current_timestamp - interval '3 days'),
(5, 5, 'Order Created', current_timestamp - interval '3 days'),
(6, 6, 'Order Created', current_timestamp - interval '2 days'),
(7, 7, 'Order Created', current_timestamp - interval '2 days'),
(8, 8, 'Order Created', current_timestamp - interval '1 day'),
(9, 9, 'Order Created', current_timestamp - interval '1 day'),
(10, 10, 'Order Created', current_timestamp);

create or replace function calculate_order_total(p_order_id int)
returns numeric(10, 2) 
as $$
declare
	total_price numeric(10, 2);
begin
	select coalesce(sum(quantity * price), 0)
	into total_price
	from order_items
	where order_id = p_order_id;
	return total_price;
end;
$$ language plpgsql;

select order_id,
	calculate_order_total(order_id) as calculated_total
from order_items
order by order_id;

create or replace procedure create_order(p_customer_id int)
language plpgsql
as $$
begin
	if exists (select 1 from customers where customer_id = p_customer_id) then
		insert into orders (customer_id, order_date, total_amount) values
		(p_customer_id, current_timestamp, 0);
	else
		raise notice 'Client does not exist';
	end if;
end;
$$;

call create_order(1);

select *
from orders
order by order_id desc

create or replace procedure add_product_to_order(p_order_id int, p_product_id int, p_quantity int)
language plpgsql
as $$
declare
	v_current_price numeric(10, 2);
	v_current_stock int;
begin
	if p_quantity <= 0 then
		raise exception 'Qantity has to be higher then 0';
	end if;

	select price,
		stock_quantity
	into v_current_price,
		v_current_stock
	from products
	where product_id = p_product_id;

	if v_current_stock < p_quantity then
		raise exception 'There are no items lefy';
	end if;

	insert into order_items(order_id, product_id, quantity, price) values
	(p_order_id, p_product_id, p_quantity, v_current_price);

	update products
	set stock_quantity = stock_quantity - p_quantity
	where product_id = p_product_id;
end;
$$;

call add_product_to_order(13, 1, 2)

select *
from products
order by product_id

create or replace function update_order_total_trigger()
returns trigger
language plpgsql
as $$
begin
	if TG_OP = 'DELETE' then
		update orders
		set total_amount = calculate_order_total(old.order_id)
		where order_id = old.order_id;
		return old;
	else
		update orders
		set total_amount = calculate_order_total(new.order_id)
		where order_id = new.order_id;
		return new;
	end if;
end;
$$;

create trigger trigger_update_total
after insert or update or delete
on order_items
for each row 
execute function UPDATE_order_total_trigger()

call add_product_to_order(13, 1, 2)

select *
from orders
where order_id = 13

create or replace function log_new_order_trigger()
returns trigger
language plpgsql
as $$
begin
	insert into order_log (order_id, customer_id, action, log_date) values
	(new.order_id, new.customer_id, 'Order Created', current_timestamp);
	return new;
end;
$$;

create trigger trigger_log_order
after insert
on orders
for each row
execute function log_new_order_trigger();

call create_order(2);

select *
from order_log;

insert into customers (full_name, email, balance) values
('Yevheniia Krychun', 'yevheniia.krychun@gmail.com', 1000000.00);

insert into products (product_name, price, stock_quantity) values 
('Test Laptop', 250000.00, 10);

call create_order(2);

call add_product_to_order(17, 11, 2);

select *
from orders 
where order_id = 17;

select *
from products 
where product_id = 11;

select *
from order_log 
order by log_date desc;




