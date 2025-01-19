DROP TABLE IF EXISTS Latest_Updates;
DROP TABLE IF EXISTS Items_Purchases;
DROP TABLE IF EXISTS Items_Rents;
DROP TABLE IF EXISTS Rents;
DROP TABLE IF EXISTS Purchases;
DROP TABLE IF EXISTS Items;
DROP TABLE IF EXISTS Rentees;
DROP TABLE IF EXISTS Staff;
DROP TABLE IF EXISTS Subcategories;
DROP TABLE IF EXISTS Categories;

CREATE TABLE Categories(
    id SERIAL PRIMARY KEY,
    category_name VARCHAR(255) NOT NULL
);

CREATE TABLE Subcategories(
    id SERIAL PRIMARY KEY,
    subcategory_name VARCHAR(255) NOT NULL
);

CREATE TABLE Staff(
    id SERIAL PRIMARY KEY,
    first_name VARCHAR(255) NOT NULL,
    last_name VARCHAR(255) NOT NULL
);

CREATE TABLE Rentees(
    passport_id VARCHAR(255) NOT NULL PRIMARY KEY UNIQUE,
    first_name VARCHAR(255) NOT NULL,
    last_name VARCHAR(255) NOT NULL,
    phone VARCHAR(255) 
);

--BRAND should be rather another table like category and subcategory, but I understood it too late and didn't want to rewrite this. 
CREATE TABLE Items(
    id SERIAL PRIMARY KEY,
    model VARCHAR(255) NOT NULL,
    brand VARCHAR(255) NOT NULL,
    category_id INT NOT NULL,
    subcategory_id INT NOT NULL,
    stock_quantity INT NOT NULL DEFAULT 1,
    price DECIMAL(10, 2) NOT NULL DEFAULT 0.00,
    rent_price DECIMAL(10, 2) NOT NULL DEFAULT 0.00,
    FOREIGN KEY(subcategory_id) REFERENCES Subcategories(id),
    FOREIGN KEY(category_id) REFERENCES Categories(id),
    CONSTRAINT stock_nonnegative CHECK (stock_quantity >= 0),
    CONSTRAINT price_nonnegative CHECK (price >= 0),
    CONSTRAINT rent_price_nonnegative CHECK (rent_price >= 0)
);


CREATE TABLE Purchases(
    id SERIAL PRIMARY KEY,
    staff_member_id INT NOT NULL,
    total_price DECIMAL(10, 2) NOT NULL,
    payment_date TIMESTAMP WITHOUT TIME ZONE NOT NULL,
    FOREIGN KEY(staff_member_id) REFERENCES Staff(id)
);

CREATE TABLE Rents(
    id SERIAL PRIMARY KEY,
    rentee_id VARCHAR(255) NOT NULL,
    payment_date TIMESTAMP WITHOUT TIME ZONE NOT NULL,
    total_price DECIMAL(10, 2) NOT NULL,
    FOREIGN KEY(rentee_id) REFERENCES Rentees(passport_id)
);

CREATE TABLE Items_Rents(
    item_id INT NOT NULL,
    rent_id INT NOT NULL,
    rented_from DATE NOT NULL,
    rented_to DATE NOT NULL,
    FOREIGN KEY(item_id) REFERENCES Items(id),
    FOREIGN KEY(rent_id) REFERENCES Rents(id),
    PRIMARY KEY(item_id, rent_id)
);

CREATE TABLE Items_Purchases(
    item_id INT NOT NULL,
    purchase_id INT NOT NULL,
    quantity INT NOT NULL DEFAULT 1,
    FOREIGN KEY(item_id) REFERENCES Items(id),
    FOREIGN KEY(purchase_id) REFERENCES Purchases(id),
    PRIMARY KEY(item_id, purchase_id),
    CONSTRAINT quantity_nonnegative CHECK (quantity >= 0)
);

CREATE TABLE Latest_Updates(
	id SERIAL PRIMARY KEY,
    latest_update_purchase TIMESTAMP WITHOUT TIME ZONE NOT NULL DEFAULT '2001-01-01 01:01:01',
    latest_update_rent TIMESTAMP WITHOUT TIME ZONE NOT NULL DEFAULT '2001-01-01 01:01:01',
    latest_update_item TIMESTAMP WITHOUT TIME ZONE NOT NULL DEFAULT '2001-01-01 01:01:01'
);

INSERT into Latest_Updates(latest_update_purchase,latest_update_rent,latest_update_item)
VALUES ('2001-01-01 01:01:01', '2001-01-01 01:01:01', '2001-01-01 01:01:01');