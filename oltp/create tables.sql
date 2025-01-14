drop table if exists Rents;
drop table if exists Purchases;
drop table if exists Items_Rents;
drop table if exists Items;
drop table if exists Payments;
drop table if exists Rentees;
drop table if exists Subcategories;
drop table if exists Staff;
drop table if exists Categories;

CREATE TABLE Categories(
    id SERIAL PRIMARY KEY,
    category_name VARCHAR(255) NOT NULL
);

CREATE TABLE Staff(
    id SERIAL PRIMARY KEY,
    first_name INT NOT NULL,
    last_name INT NOT NULL
);

CREATE TABLE Subcategories(
    id SERIAL PRIMARY KEY,
    subcategory_name VARCHAR(255) NOT NULL
);

CREATE TABLE Rentees(
    passport_id VARCHAR(255) NOT NULL PRIMARY KEY UNIQUE,
    first_name VARCHAR(255) NOT NULL,
    last_name VARCHAR(255) NOT NULL,
    phone VARCHAR(255) NOT NULL
);

CREATE TABLE Payments(
    id SERIAL PRIMARY KEY,
    amount MONEY NOT NULL,
    payment_date TIME(0) WITHOUT TIME ZONE NOT NULL
);

CREATE TABLE Items(
    id SERIAL PRIMARY KEY,
    model VARCHAR(255) NOT NULL,
    brand VARCHAR(255) NOT NULL,
    category_id INT NOT NULL,
    subcategory_id INT NOT NULL,
    sold BOOLEAN NOT NULL DEFAULT FALSE,
    FOREIGN KEY(subcategory_id) REFERENCES Subcategories(id),
    FOREIGN KEY(category_id) REFERENCES Categories(id)
);

CREATE TABLE Items_Rents(
    item_id INT NOT NULL UNIQUE,
    rent_id INT NOT NULL UNIQUE,
    FOREIGN KEY(item_id) REFERENCES Items(id),
    PRIMARY KEY(item_id, rent_id)
);

CREATE TABLE Purchases(
    id SERIAL PRIMARY KEY,
    item_id INT NOT NULL,
    payment_id INT NOT NULL,
    staff_member_id INT NOT NULL,
    FOREIGN KEY(item_id) REFERENCES Items(id),
    FOREIGN KEY(staff_member_id) REFERENCES Staff(id),
    FOREIGN KEY(payment_id) REFERENCES Payments(id)
);

CREATE TABLE Rents(
    id SERIAL PRIMARY KEY,
    item_id INT NOT NULL,
    payment_id INT NOT NULL,
    rentee_id VARCHAR(255) NOT NULL,
    rented_from TIME(0) WITHOUT TIME ZONE NOT NULL,
    rented_to TIME(0) WITHOUT TIME ZONE NOT NULL,
    FOREIGN KEY (payment_id) REFERENCES Payments(id),
    FOREIGN KEY(item_id) REFERENCES Items_Rents(rent_id),
    FOREIGN KEY(rentee_id) REFERENCES Rentees(passport_id)
);
