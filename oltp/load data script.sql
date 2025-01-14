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
    subcategory VARHCAR(255)
);

CREATE TEMP TABLE temp_purchases(
    purchase_date DATE,
    employee_full_name VARHCAR(255),
    item_full_name VARHCAR(255),
    amount MONEY
);

CREATE TEMP TABLE temp_rents(
    item_full_name VARHCAR(255),
    from_date DATE,
    to_date DATE,
    when_paid DATE,
    customer VARHCAR(255),
    amount MONEY
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





drop table temp_rents;
drop table temp_purchases;
drop table temp_items;
drop table temp_customers;
drop table temp_staff;
drop table temp_categories;
drop table temp_subcategories;