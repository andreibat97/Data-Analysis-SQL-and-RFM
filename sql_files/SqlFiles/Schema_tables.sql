-- I start this project creating the tables

DROP TABLE IF EXISTS orders;
DROP TABLE IF EXISTS customers;
DROP TABLE IF EXISTS bills;
DROP TABLE IF EXISTS items;

-- 1. Customers Table
CREATE TABLE customers (
  customer_id VARCHAR(10) PRIMARY KEY,
  first_name VARCHAR(20) NOT NULL,
  last_name VARCHAR(20) NOT NULL,
  email VARCHAR(100) NOT NULL UNIQUE,
  country VARCHAR(50),
  signup_date DATE NOT NULL,
  lifetime_spend DECIMAL(10,2) NOT NULL DEFAULT 0.00,
  purchase_frequency INT NOT NULL DEFAULT 0,
  CONSTRAINT chk_lifetime_spend CHECK (lifetime_spend >= 0),
  CONSTRAINT chk_purchase_frequency CHECK (purchase_frequency >= 0),
  CONSTRAINT chk_email_format CHECK (email LIKE '%@%.%')
);

-- 2. Orders Table
CREATE TABLE orders (
  order_id VARCHAR(10) PRIMARY KEY,
  customer_id VARCHAR(10) NOT NULL, -- Corregido a VARCHAR(10) para coincidir exactamente con el tipo en 'customers'
  order_date DATE NOT NULL,
  total_amount DECIMAL(10,2) NOT NULL,
  status VARCHAR(20) NOT NULL,
  FOREIGN KEY (customer_id) REFERENCES customers(customer_id),
  CONSTRAINT chk_total_amount CHECK (total_amount >= 0),
  CONSTRAINT chk_status CHECK (status IN ('PAID', 'SHIPPED', 'PENDING', 'NEW', 'CANCELLED')) -- Corregido a comillas simples
);

-- 3. Items Table
CREATE TABLE items (
  item_id VARCHAR(10) PRIMARY KEY,
  name VARCHAR(50) NOT NULL, -- Corregido typo 'NOT NUULL'
  price DECIMAL(10,2) NOT NULL,
  stock_quantity INT NOT NULL,
  CONSTRAINT chk_item_name CHECK (name <> ''), -- Corregido a comillas simples
  CONSTRAINT chk_price CHECK (price >= 0),
  CONSTRAINT chk_stock CHECK (stock_quantity >= 0)
);

-- 4. Bills Table
CREATE TABLE bills (
  bill_id VARCHAR(10) PRIMARY KEY,
  item_id VARCHAR(10) NOT NULL, 
  order_id VARCHAR(10) NOT NULL,
  quantity INT NOT NULL,
  unit_price DECIMAL(10,2) NOT NULL,
  FOREIGN KEY (order_id) REFERENCES orders(order_id),
  FOREIGN KEY (item_id) REFERENCES items(item_id),
  CONSTRAINT chk_quantity CHECK (quantity > 0),
  CONSTRAINT chk_unit_price CHECK (unit_price >= 0)
);

-- Please upload the files in the following order: Customers, Orders, Items, Bills .