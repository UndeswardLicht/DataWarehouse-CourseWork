DROP SCHEMA IF EXISTS DW CASCADE;

CREATE SCHEMA DW;

CREATE TABLE DW.dim_Brand(
    id SERIAL NOT NULL PRIMARY KEY,
    brand_name VARCHAR(255) NOT NULL
);

CREATE TABLE DW.dim_Categories(
    id SERIAL NOT NULL PRIMARY KEY,
    category VARCHAR(255) NOT NULL
);

CREATE TABLE DW.dim_Subcategories(
    id SERIAL NOT NULL PRIMARY KEY,
    subcategory VARCHAR(255) NOT NULL
);

CREATE TABLE DW.dim_Employee(
    id SERIAL NOT NULL PRIMARY KEY,
    full_name VARCHAR(255) NOT NULL
);

CREATE TABLE DW.dim_Item(
    id SERIAL NOT NULL PRIMARY KEY,
    full_item_name VARCHAR(255) NOT NULL,
    brand_id INT NOT NULL,
    category_id INT NOT NULL,
    subcategory_id INT NOT NULL,
    price DECIMAL(8, 2) NOT NULL,
    old_price DECIMAL(8, 2) NOT NULL,
    rent_price DECIMAL(8, 2) NOT NULL,
    old_rent_price DECIMAL(8, 2) NOT NULL,
    FOREIGN KEY(category_id) REFERENCES DW.dim_Categories(id),
    FOREIGN KEY(brand_id) REFERENCES DW.dim_Brand(id),
    FOREIGN KEY(subcategory_id) REFERENCES DW.dim_Subcategories(id)
);

CREATE TABLE DW.dim_Time(
    time_key SERIAL NOT NULL PRIMARY KEY,
    full_date DATE NOT NULL,
    year_n INT NOT NULL,
    quarter_n INT NOT NULL,
    month_n INT NOT NULL,
    month_name VARCHAR(255) NOT NULL,
    day_n INT NOT NULL,
    day_name VARCHAR(255) NOT NULL
);

CREATE TABLE DW.dim_Customer(
    id SERIAL NOT NULL PRIMARY KEY,
    full_name INT NOT NULL,
    phone BIGINT NOT NULL,
    last_rent_on INT NOT NULL,
    FOREIGN KEY(last_rent_on) REFERENCES DW.dim_Time(time_key)
);

CREATE TABLE DW.fact_Purchases(
    item_id INT NOT NULL,
    time_key INT NOT NULL,
    employee_id INT NOT NULL,
    quantity_sold INT NOT NULL,
    total_sales INT NOT NULL,
    PRIMARY KEY(item_id, time_key, employee_id),
    FOREIGN KEY(item_id) REFERENCES DW.dim_Item(id),
    FOREIGN KEY(time_key) REFERENCES DW.dim_Time(time_key),
    FOREIGN KEY(employee_id) REFERENCES DW.dim_Employee(id)
);

CREATE TABLE DW.fact_Rents(
    item_id INT NOT NULL,
    rented_by INT NOT NULL,
    rented_on INT NOT NULL,
    rented_from INT NOT NULL,
    rented_to INT NOT NULL,
    total_for_rents INT NOT NULL,
    rents_number INT NOT NULL,
    PRIMARY KEY(item_id, rented_by, rented_on),
    FOREIGN KEY(rented_on) REFERENCES DW.dim_Time(time_key),
    FOREIGN KEY(rented_from) REFERENCES DW.dim_Time(time_key),
    FOREIGN KEY(item_id) REFERENCES DW.dim_Item(id),
    FOREIGN KEY(rented_to) REFERENCES DW.dim_Time(time_key),
    FOREIGN KEY(rented_by) REFERENCES DW.dim_Customer(id)
);