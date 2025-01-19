DROP VIEW IF EXISTS view_new_purchased_items;
DROP VIEW IF EXISTS view_new_rented_items;
DROP TABLE IF EXISTS temp_rents;
DROP TABLE IF EXISTS temp_purchases;
DROP TABLE IF EXISTS temp_items;
DROP TABLE IF EXISTS temp_customers;
DROP TABLE IF EXISTS temp_staff;
DROP TABLE IF EXISTS temp_categories;
DROP TABLE IF EXISTS temp_subcategories;

CREATE TEMP TABLE temp_items (
    item_full_name VARCHAR(255),
    category VARCHAR(255),
    subcategory VARCHAR(255),
    price VARCHAR(255),
    rent_price VARCHAR(255),
    delivered DATE
);

CREATE TEMP TABLE temp_purchases(
    purchase_date DATE,
    employee_full_name VARCHAR(255),
    item_full_name VARCHAR(255)
);

CREATE TEMP TABLE temp_rents(
    item_full_name VARCHAR(255),
    from_date DATE,
    to_date DATE,
    when_paid DATE,
    customer VARCHAR(255)
);

CREATE TEMP TABLE temp_customers(
    passport VARCHAR(255),
    full_name VARCHAR(255),
    phone VARCHAR(255)
);

CREATE TEMP TABLE temp_categories(
    categories VARCHAR(255)
);

CREATE TEMP TABLE temp_subcategories(
    subcategories VARCHAR(255)
);

CREATE TEMP TABLE temp_staff(
    full_name VARCHAR(255)
);

COPY temp_items FROM 'ADD PATH TO ITEMS FILE' WITH (FORMAT csv, HEADER true, DELIMITER ',', QUOTE '"');
COPY temp_purchases FROM 'ADD PATH TO PURCHASES FILE' WITH (FORMAT csv, HEADER true, DELIMITER ',', QUOTE '"');
COPY temp_rents FROM 'ADD PATH TO RENTS FILE' WITH (FORMAT csv, HEADER true, DELIMITER ',', QUOTE '"');
COPY temp_customers FROM 'ADD PATH TO CUSTOMERS FILE' WITH (FORMAT csv, HEADER true, DELIMITER ',', QUOTE '"');
COPY temp_staff FROM 'ADD PATH TO STAFF FILE' WITH (FORMAT csv, HEADER true, DELIMITER ',', QUOTE '"');

UPDATE temp_items
SET category = initcap(category),
	subcategory = initcap(subcategory);

INSERT INTO categories(category_name)
SELECT i.category
FROM temp_items i
WHERE NOT EXISTS(
    SELECT 1 from categories
    WHERE category_name = i.category
)
GROUP BY category;

INSERT INTO subcategories(subcategory_name)
SELECT i.subcategory
FROM temp_items i
WHERE NOT EXISTS(
    SELECT 1 from subcategories
    WHERE subcategory_name = i.subcategory
)
GROUP BY subcategory;

--beatify passport and phone data remove spaces and small letters from passport, delete evrything except digits for phone 
UPDATE temp_customers
SET passport = REPLACE(UPPER(passport),' ', ''),
	phone = REGEXP_REPLACE(phone, '[^[:digit:]]','','g');
    
INSERT INTO rentees(passport_id, first_name, last_name, phone)
SELECT
    c.passport,
    split_part(c.full_name, ' ', 1),
    split_part(c.full_name, ' ', 2),
    c.phone
FROM temp_customers c
WHERE NOT EXISTS(
    SELECT 1 from rentees
    WHERE passport_id = c.passport
);

--loophole -> it's possible that two full namesakes will work there.
--posible solution: add a field to distinguish two people - passport data or middle/father's name?
INSERT INTO staff(first_name, last_name)
SELECT
    split_part(s.full_name, ' ', 1),
    split_part(s.full_name, ' ', 2)
FROM temp_staff s
WHERE NOT EXISTS(
    SELECT 1 from staff
    WHERE first_name = split_part(s.full_name, ' ', 1) AND last_name = split_part(s.full_name, ' ', 2)
);


--beautify ITEMS data - replacing ',' with '.' in PRICEs
--dissassembling and concatinating item name again like 'Brand MODEL' 
UPDATE temp_items
SET price = REPLACE(price, ',', '.'),
	rent_price = REPLACE(rent_price, ',', '.'),
	item_full_name = CONCAT(initcap(split_part(item_full_name, ' ', 1)), ' ', UPPER(split_part(item_full_name, ' ', 2)));

--this query adds quantity if there were new already known items but added later than last delivery date
UPDATE items
SET stock_quantity = stock_quantity + 1
WHERE CONCAT(brand, ' ', model) IN 	
	(SELECT item_full_name
    FROM temp_items
    WHERE delivered > (SELECT latest_update_item from Latest_Updates));

--this query imports new items if they were added later than last delivery date
WITH new_items AS
(
    SELECT item_full_name, category, subcategory, price, rent_price
    FROM temp_items
    WHERE delivered > (SELECT latest_update_item from Latest_Updates)
)
INSERT INTO items(model, brand, category_id, subcategory_id, price, rent_price)
SELECT
    split_part(ni.item_full_name, ' ', 2),
    split_part(ni.item_full_name, ' ', 1),
    (SELECT id FROM categories WHERE category_name = ni.category),
    (SELECT id FROM subcategories WHERE subcategory_name = ni.subcategory),
    CAST(ni.price AS DECIMAL(10,2)),
    CAST(ni.rent_price AS DECIMAL(10,2))
FROM new_items ni
WHERE NOT EXISTS(
    SELECT 1 FROM items
    WHERE CONCAT(brand, ' ', model) = ni.item_full_name 
);

--query updates table with dates based on latest csv date of items
UPDATE Latest_Updates
SET latest_update_item = 
	(SELECT max(delivered)
	FROM temp_items);


--definition of a PURCHASE: one or several lines in CSV file on the SAME date_time by SAME employee
--hence ONE PURCHASE is defined in script as one or several rows with SAME date_time and SAME employee name
--in real word terms = one staff member has sold >=1 product to one customer

--beautify PURCHASES data - replacing ',' with '.' in PRICEs
--dissassembling and concatinating item name again like 'Brand MODEL' in accordance with this in other part of the DB
UPDATE temp_purchases
SET item_full_name = CONCAT(initcap(split_part(item_full_name, ' ', 1)), ' ', UPPER(split_part(item_full_name, ' ', 2)));

--creating temp view to be able to work with the same result multiple times further
CREATE TEMP VIEW view_new_purchased_items AS
(
SELECT
	tp.purchase_date,
	sm.id AS empl_id,
	ip.id AS item_id,
	ip.price AS item_price
FROM temp_purchases tp
JOIN
(
    SELECT
    id, 
    CONCAT(brand, ' ', model) AS item_full_name,
    price
    FROM items) ip
ON tp.item_full_name = ip.item_full_name
JOIN
(
	SELECT
	id,
	TRIM(CONCAT(staff.first_name, ' ', staff.last_name)) as full_name
	FROM staff) sm
ON tp.employee_full_name = sm.full_name
WHERE tp.purchase_date > (SELECT latest_update_purchase from Latest_Updates)
);

--grouping new purchases by date and cashier to identify and retrieve a total amount of a purchase
WITH purch AS(
    SELECT purchase_date, empl_id, sum(item_price) AS total_price
    FROM view_new_purchased_items
    GROUP BY purchase_date, empl_id 
)
INSERT INTO purchases(staff_member_id, payment_date, total_price)
SELECT 
    empl_id,
    purchase_date,
    total_price
FROM purch;

--grouping new purchases by their purchase_ and item_id and counting how many of one item in in purchase
WITH group_table AS
(
SELECT p.id AS purchase_id, ni.item_id, COUNT(ni.item_id) 
FROM view_new_purchased_items ni
JOIN purchases p
ON p.payment_date = ni.purchase_date AND p.staff_member_id = ni.empl_id
GROUP BY purchase_id, item_id
)
INSERT INTO items_purchases(item_id, purchase_id, quantity)
SELECT 
	gt.item_id,
	gt.purchase_id,
	gt.count
FROM group_table gt;

UPDATE Latest_Updates
SET latest_update_purchase = 
	(SELECT max(purchase_date)
	FROM temp_purchases);


--definition of a RENT: one or several lines in CSV file on the SAME date_time by SAME rentee
--hence ONE RENT is defined in script as one or several rows with SAME date_time and SAME rentee passport
--in real word terms = one customer has rented >=1 product 

--beautify RENTS data - replacing ',' with '.' in PRICEs
--dissassembling and concatinating item name again like 'Brand MODEL' in accordance with this in other part of the DB
UPDATE temp_rents
SET item_full_name = CONCAT(initcap(split_part(item_full_name, ' ', 1)), ' ', UPPER(split_part(item_full_name, ' ', 2))),
	customer = UPPER(REPLACE(customer,' ',''));

--creating temp view to be able to work with the same result multiple times further
CREATE TEMP VIEW view_new_rented_items AS (
SELECT 
    ip.id AS item_id,
    tr.from_date,
    tr.to_date,
    tr.when_paid AS rent_date,
    tr.customer AS rentee_pass,
    ip.rent_price,
	ABS(tr.from_date - tr.to_date)/7 AS rent_weeks
FROM temp_rents tr
JOIN
(
    SELECT
    id, 
    CONCAT(brand, ' ', model) AS item_name,
    rent_price
    FROM items) ip
ON tr.item_full_name = ip.item_name
JOIN rentees re
ON tr.customer =  re.passport_id 
WHERE tr.when_paid > (SELECT latest_update_rent from Latest_Updates)
);

--grouping new rented itmes by date and rentee to identify and retrieve a total amount of a rent
WITH rnt AS (
SELECT rent_date, rentee_pass, (SUM(rent_price) * (rent_weeks)) AS total_price
FROM view_new_rented_items
GROUP BY rent_date, rentee_pass, rent_weeks
)
INSERT INTO rents(rentee_id, payment_date, total_price)
SELECT 
	rnt.rentee_pass,
	rnt.rent_date,
	rnt.total_price
FROM rnt;


--joining view and rent to retrieve rents_ids and item_ids at the same time
WITH join_rent AS(
SELECT nri.item_id, nri.from_date, nri.to_date, rents.id AS rent_id
FROM view_new_rented_items nri
JOIN rents
ON nri.rentee_pass = rents.rentee_id AND nri.rent_date = rents.payment_date)
INSERT INTO items_rents(item_id, rent_id, rented_from, rented_to)
SELECT 
	jr.item_id,
	jr.rent_id,
	jr.from_date,
	jr.to_date
FROM join_rent jr;

--query updates table with dates based on latest csv date of items
UPDATE Latest_Updates
SET latest_update_rent = 
	(SELECT max(when_paid)
	FROM temp_rents);