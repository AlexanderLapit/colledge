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

create table items(
	id serial primary key,
	name VARCHAR(200) not NULL,
	code VARCHAR(200),
	type VARCHAR(20) check (type in ('product', 'material', 'operation')) not null,
	unit VARCHAR(20)
);

create table prices(
	id serial primary key,
	item_id INT not null references items(id) on update cascade on delete cascade,
	price DECIMAL(12,2) check (price >= 0) not null,
	discount INT check (discount >= 0 and discount <= 100) not null,
	from_date DATE not null,
	to_date DATE not null

);

create table specifiacations(
	id serial primary key,
	product_item_id int not null references items(id) on update cascade on delete cascade,
	manufacturier_id int not null references contragents(id) on update cascade on delete cascade
);

create table specifiacation_lines(
	id serial primary key,
	specifiacation_id int not null references specifiacations(id) on update cascade on delete cascade,
	-- technological item это операция или материал
	technological_item_id int not null references items(id) on update cascade on delete cascade,
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
	product_item_id int not null references items(id) on update cascade on delete restrict,
	order_by_customer_id int not null references orders_by_customer(id) on update cascade on delete cascade,
	quantity DECIMAL(12,3) check (quantity >= 0) not null
);
create table users(
id serial primary key,
login VARCHAR(50) unique,
password_hash VARCHAR(255),
role VARCHAR(20),
is_blocked BOOLEAN,
failed_attempts INTEGER,
blocked_until TIMESTAMP,
created_at TIMESTAMP
);

create table notes(
	id serial primary key,
	title VARCHAR(255),
	content text,
	user_id INTEGER references users(id) on update cascade on delete cascade,
	created_at TIMESTAMP
);


-- 1. Заполняем контрагентов (Поставщики и Покупатели)
INSERT INTO contragents (name, inn, addres, phone, type) VALUES
('ООО "Ромашка"', '7701234567', 'г. Москва, ул. Ленина, 1', '+7-999-123-45-67', 'Поставщик'),
('ООО "ТехноСнаб"', '7707654321', 'г. Москва, ул. Пушкина, 2', '+7-999-765-43-21', 'Поставщик'),
('ИП Иванов И.И.', '7701112223', 'г. Тула, пр-т Мира, 10', '+7-999-111-22-33', 'Покупатель');

-- 2. Заполняем товары/услуги (items)
INSERT INTO items (name, code, type, unit) VALUES
('Стальной лист', 'STL-001', 'material', 'кг'),
('Токарная обработка', 'OPR-001', 'operation', 'час'),
('Готовое изделие "Вал"', 'PRD-001', 'product', 'шт'),
('Готовое изделие "Шестерня"', 'PRD-002', 'product', 'шт');

INSERT INTO prices (item_id, price, discount, from_date, to_date) VALUES
-- Цена на материал (действует весь 2026 год)
(1, 150.00, 1, '2026-01-01', '2026-12-31'), 
-- Цена на операцию
(2, 2000.00, 5, '2026-01-01', '2026-12-31'),
-- Цены на готовые изделия
(3, 10000.00, 1, '2026-01-01', '2026-12-31'),
(4, 25000.00, 10, '2026-01-01', '2026-12-31');

-- 4. Заполняем спецификации (specifications)
INSERT INTO specifiacations (product_item_id, manufacturier_id) VALUES
-- Спецификация для "Вала" (делает ООО Ромашка)
(3, 1),
-- Спецификация для "Шестерни" (делает ООО ТехноСнаб)
(4, 2);

-- 5. Заполняем строки спецификаций (specification_lines)
INSERT INTO specifiacation_lines (specifiacation_id, technological_item_id, quantity) VALUES
-- Для производства "Вала" (ID 3) нужно 10 кг стали (ID 1) и 2 часа токарки (ID 2)
(1, 1, 10.00),
(1, 2, 2.00),
-- Для производства "Шестерни" (ID 4) нужно 5 кг стали (ID 1) и 1 час токарки (ID 2)
(2, 1, 5.00),
(2, 2, 1.00);

-- 6. Заполняем заказы покупателей (orders_by_customer)
INSERT INTO orders_by_customer (order_number, customer_id, date) VALUES
(1001, 3, '2026-09-01'),
(1002, 3, '2026-09-05');

-- 7. Заполняем строки заказов покупателей (order_by_customer_lines) - ТЕ САМЫЕ ДАННЫЕ ДЛЯ ВАШЕГО ЗАПРОСА
INSERT INTO order_by_customer_lines (product_item_id, order_by_customer_id, quantity) VALUES
-- Заказ 1001: Купили 2 "Вала" (item_id 3)
(3, 1, 2.00),
(4, 1, 1.00),
-- Заказ 1002: Купили 1 "Шестерню" (item_id 4)
(4, 2, 1.00);


