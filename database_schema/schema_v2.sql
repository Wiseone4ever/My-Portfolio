CREATE TABLE IF NOT EXISTS CUSTOMERS
(
    customer_id VARCHAR(255) NOT NULL PRIMARY KEY,
    first_name VARCHAR(255) NOT NULL,
    last_name VARCHAR(255),
    username VARCHAR(255),
    gender TEXT,
    date_of_birth DATE NOT NULL,
    email VARCHAR(255) UNIQUE,
    phone VARCHAR(20) UNIQUE,
    street_name VARCHAR(255),
    city VARCHAR(255),
    country VARCHAR(255),
    postal_code VARCHAR(20),
    account_created_date TIMESTAMP,
    premium_subscription INTEGER
);

CREATE TABLE IF NOT EXISTS PRODUCT_CATEGORY
(
    category_id VARCHAR(255) NOT NULL PRIMARY KEY,
    cat_name VARCHAR(255)
);

CREATE TABLE IF NOT EXISTS SUPPLIERS
(
    supplier_id VARCHAR(255) NOT NULL PRIMARY KEY,
    supplier_name VARCHAR(255),
    supplier_address VARCHAR(500),
    supplier_phone VARCHAR(20),
    supplier_email VARCHAR(255) UNIQUE
);

CREATE TABLE IF NOT EXISTS PRODUCTS
(
    product_id VARCHAR(255) NOT NULL PRIMARY KEY,
    product_name VARCHAR(255),
    price REAL,
    stock_quantity INTEGER NOT NULL,
    category_id VARCHAR(255) NOT NULL,
    supplier_id VARCHAR(255) NOT NULL,
    FOREIGN KEY(category_id) REFERENCES PRODUCT_CATEGORY(category_id),
    FOREIGN KEY(supplier_id) REFERENCES SUPPLIERS(supplier_id)
);

CREATE TABLE IF NOT EXISTS GIFT_CARD
(
gift_card_id VARCHAR(50) NOT NULL PRIMARY KEY,
gift_card_code VARCHAR(50),
detail INTEGER,
status VARCHAR(50)
);

CREATE TABLE IF NOT EXISTS ORDERS
(
    order_id VARCHAR(255) NOT NULL PRIMARY KEY,
    customer_id VARCHAR(255),
    product_id VARCHAR(255),
    shipment_id VARCHAR(255),
    gift_card_id VARCHAR(255), 
    payment_method TEXT,
    quantity INTEGER,
    order_timestamp TIMESTAMP,
    payment_timestamp TIMESTAMP,
    order_status VARCHAR(50) NOT NULL,
    amount REAL,
    FOREIGN KEY(customer_id) REFERENCES CUSTOMERS(customer_id),
    FOREIGN KEY(product_id) REFERENCES PRODUCTS(product_id),
    FOREIGN KEY(shipment_id) REFERENCES SHIPMENT(shipment_id), 
    FOREIGN KEY(gift_card_id) REFERENCES GIFT_CARD(gift_card_id) 
);

CREATE TABLE IF NOT EXISTS SHIPMENT
(
shipment_id VARCHAR(255) NOT NULL PRIMARY KEY,
order_id VARCHAR(255),
dispatch_timestamp DATETIME,
shipped_timestamp DATETIME,
status VARCHAR(50) NOT NULL,
FOREIGN KEY(order_id) REFERENCES ORDERS(order_id)
);



/* Assuming the following tables are defined, uncomment to create them /
/
CREATE TABLE IF NOT EXISTS SHIPMENT_DETAIL
(
shipment_detail_id INTEGER NOT NULL PRIMARY KEY,
shipment_id VARCHAR(255),
order_id VARCHAR(255),
FOREIGN KEY(shipment_id) REFERENCES SHIPMENT(shipment_id),
FOREIGN KEY(order_id) REFERENCES ORDERS(order_id)
);

CREATE TABLE IF NOT EXISTS ORDER_DETAIL
(
order_detail_id INTEGER NOT NULL PRIMARY KEY,
order_id VARCHAR(255),
product_id VARCHAR(255),
quantity INTEGER,
FOREIGN KEY(order_id) REFERENCES ORDERS(order_id),
FOREIGN KEY(product_id) REFERENCES PRODUCTS(product_id)
);

CREATE TABLE IF NOT EXISTS PAYMENT
(
payment_id INTEGER NOT NULL PRIMARY KEY,
customer_id VARCHAR(255),
order_id VARCHAR(255), -- Assuming payments are linked to orders
amount REAL,
payment_date DATETIME,
payment_method VARCHAR(50),
card_number VARCHAR(20),
card_expiry_date DATE,
card_holder_name VARCHAR(255),
gift_card_id VARCHAR(50),
status VARCHAR(50),
FOREIGN KEY(customer_id) REFERENCES CUSTOMERS(customer_id),
FOREIGN KEY(order_id) REFERENCES ORDERS(order_id),
FOREIGN KEY(gift_card_id) REFERENCES GIFT_CARD(gift_card_id)
);
*/

