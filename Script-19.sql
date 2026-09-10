drop schema public cascade;
create schema public;


create table contragents(
	id serial primary key,
	name VARCHAR(200) not NULL,
	inn VARCHAR(20),
	addres VARCHAR(200),
	phone VARCHAR(20),
	type VARCHAR(20) check (type in ('Поставщик', 'Покупатель')) not null
);

create table product_items(
	id serial primary key,
	name VARCHAR(200) not NULL,
	code VARCHAR(200),
	unit VARCHAR(20)
);

create table technological_items(
	id serial primary key,
	name VARCHAR(200) not NULL,
	code VARCHAR(200),
	price DECIMAL(12,2) check (price >= 0) not null,
	type VARCHAR(20) check (type in ('material', 'operation')) not null,
	unit VARCHAR(20)
);


create table specifiacations(
	id serial primary key,
	product_item_id int not null references product_items(id) on update cascade on delete cascade,
	manufacturier_id int not null references contragents(id) on update cascade on delete cascade
);

create table specifiacation_lines(
	id serial primary key,
	specifiacation_id int not null references specifiacations(id) on update cascade on delete cascade,
	technological_item_id int not null references technological_items(id) on update cascade on delete cascade,
	quantity DECIMAL(12,3) check (quantity >= 0) not null
);

create table orders_by_manufacturier(
	id serial primary key,
	order_number int not null,
	date DATE not null
);

create table order_by_manufacturier_lines( 
	id serial primary key,
	order_by_manufacturier_id int not null references orders_by_manufacturier(id) on update cascade on delete cascade,
	specifiacation_id int not null references specifiacations(id) on update cascade on delete restrict,
	quantity DECIMAL(12,3) check (quantity >= 0) not null
);

create table orders_by_customer(
	id serial primary key,
	order_number int not null,
	customer_id int not null references contragents(id) on update cascade on delete restrict,
	date DATE not null
);

create table order_by_customer_lines(
	id serial primary key,
	price DECIMAL(12,2) check (price >= 0) not null,
	discount INT check (discount >= 0 and discount <= 100) not null,
	product_item_id int not null references product_items(id) on update cascade on delete restrict,
	order_by_customer_id int not null references orders_by_customer(id) on update cascade on delete cascade,
	quantity DECIMAL(12,3) check (quantity >= 0) not null
);


insert into 

