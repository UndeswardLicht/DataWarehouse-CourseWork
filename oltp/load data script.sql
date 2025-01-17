drop table if exists temp_rents;
drop table if exists temp_purchases;
drop table if exists temp_items;
drop table if exists temp_customers;
drop table if exists temp_staff;
drop table if exists temp_categories;
drop table if exists temp_subcategories;

--1. create Temp tables to load data into them:
    -- items
    -- purchases 
    -- rents
    -- customers
    -- staff
    -- categories
    -- subcategories
--2. load data to temp tables
--3. create scripts? functions? that clean data in tables: 
    -- date format ??
    -- -/no data to one value
    -- one format of passport values - no spaces, uppercase
    -- one format of phone numbers - only digits
    -- one format of category/subcategory - "Capitalized Words"
    -- separate last_name and first_name of people
    -- separate items name into brand-model

--4. actually load data from temp to real tables
--5. while doing so check 'NOT EXISTS' 
--6. delete temp tables

CREATE TEMP TABLE temp_items (
    item_full_name VARHCAR(255),
    category VARHCAR(255),
    subcategory VARHCAR(255),
    price VARCHAR(255),
    rent_price VARCHAR(255),
    delivered DATE
);

CREATE TEMP TABLE temp_purchases(
    purchase_date DATE,
    employee_full_name VARHCAR(255),
    item_full_name VARHCAR(255)
);

CREATE TEMP TABLE temp_rents(
    item_full_name VARHCAR(255),
    from_date DATE,
    to_date DATE,
    when_paid DATE,
    customer VARHCAR(255)
);

CREATE TEMP TABLE temp_customers(
    passport VARHCAR(255),
    customer_full_name VARHCAR(255),
    phone VARHCAR(255)
);

CREATE TEMP TABLE temp_categories(
    categories VARHCAR(255)
);

CREATE TEMP TABLE temp_subcategories(
    subcategories VARHCAR(255)
);

CREATE TEMP TABLE temp_staff(
    employee_full_name VARHCAR(255)
);

COPY temp_items from {file_name} WITH (FORMAT csv, HEADER true, DELIMITER ',', QUOTE '"');
COPY temp_purchases from {file_name} WITH (FORMAT csv, HEADER true, DELIMITER ',', QUOTE '"');
COPY temp_rents from {file_name} WITH (FORMAT csv, HEADER true, DELIMITER ',', QUOTE '"');
COPY temp_customers from {file_name} WITH (FORMAT csv, HEADER true, DELIMITER ',', QUOTE '"');
COPY temp_staff from {file_name} WITH (FORMAT csv, HEADER true, DELIMITER ',', QUOTE '"');


INSERT INTO categories(category_name)
SELECT i.category
FROM temp_items i
WHERE NOT EXISTS(
    SELECT 1 from categories
    WHERE category_name = i.category
);

INSERT INTO subcategories(subcategory_name)
SELECT i.subcategory
FROM temp_items i
WHERE NOT EXISTS(
    SELECT 1 from subcategories
    WHERE subcategory_name = i.subcategory
);

INSERT INTO rentees(passport_id, first_name, last_name, phone)
SELECT (
    c.passport,
    split_part(c.full_name, ' ', 1) AS first_name,
    split_part(c.full_name, ' ', 2) AS last_name,
    c.phone
) 
FROM temp_customers c
WHERE NOT EXISTS(
    SELECT 1 from rentees
    WHERE passport_id = c.passport
);

--loophole -> it's possible that two full namesakes will work there.
--posible solution: add a field to distinguish two people - passport data or middle/father's name?
INSERT INTO staff(first_name, last_name)
SELECT (
    split_part(s.full_name, ' ', 1) AS first_name,
    split_part(s.full_name, ' ', 2) AS last_name
)
FROM temp_staff s
WHERE NOT EXISTS(
    SELECT 1 from staff
    WHERE first_name = s.first_name AND last_name = s.last_name
);


--loophole -> there can be >1 items of identical models of the same brand
--possible solution: add timestamp of 'shipping date', column 'number on stock' and a check to verify
-- whether the item should be inserted once again or not 

--this query select totaly new items
WITH last_delivery_date AS
(
    SELECT latest_update_item from Latest_Updates
),
new_items AS
(
    SELECT item_full_name, category, subcategory, price, rent_price
    FROM temp_items
    WHERE delivered > last_delivery_date
)

INSERT INTO items(model, brand, category_id, subcategory_id, price, rent_price)
SELECT (
    split_part(ni.item_full_name, ' ', 1) AS brand,
    split_part(ni.item_full_name, ' ', 2) AS model,
    (SELECT id FROM categories WHERE category_name = ni.category),
    (SELECT id FROM subcategories WHERE subcategory_name = ni.subcategory),
    ni.price,
    ni.rent_price
)
FROM new_items ni
WHERE NOT EXISTS(
    SELECT 1 FROM items
    WHERE CONCAT(model, ' ', brand)) = ni.item_full_name 
);

--this query adds quantity if there were new already known items
WITH last_delivery_date AS
(
    SELECT latest_update_item from Latest_Updates
),
newly_delivered_items AS
(
    SELECT item_full_name
    FROM temp_items
    WHERE delivered > last_delivery_date
)
UPDATE items
SET stock_quantity = stock_quantity + 1
WHERE CONCAT(model, ' ', brand) in newly_delivered_items;

--query to beatify data in table
UPDATE items
SET model = UPPER(model),
    category_name = INITCAP(category_name),
    subcategory_name = INITCAP(subcategory_name)




--loophole -> it's possible that there will be made more than one payment for the same amount.
--posible solution: date format should be timestamp - yyyy-mm-dd-hh-mm-ss
INSERT INTO payments(columns_name)
SELECT *
FROM temp_purchases;

INSERT INTO payments(columns_name)
SELECT * 
FROM temp_rents


INSERT INTO -purchases(columns_name)
SELECT * from temp_purchases

INSERT INTO rents(columns_name)
SELECT * from temp_rents




INSERT INTO items_rents(columns_name)
SELECT * from temp_rents






drop table temp_rents;
drop table temp_purchases;
drop table temp_items;
drop table temp_customers;
drop table temp_staff;
drop table temp_categories;
drop table temp_subcategories;