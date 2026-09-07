USE [BikeStoreStage];
GO

CREATE SCHEMA production;
GO
CREATE SCHEMA sales;
GO

CREATE TABLE production.categories (
    category_id   INT           NOT NULL PRIMARY KEY,
    category_name VARCHAR(255)  NOT NULL
);

CREATE TABLE production.brands (
    brand_id   INT           NOT NULL PRIMARY KEY,
    brand_name VARCHAR(255)  NOT NULL
);

CREATE TABLE production.products (
    product_id   INT           NOT NULL PRIMARY KEY,
    product_name VARCHAR(255)  NOT NULL,
    brand_id     INT           NOT NULL,
    category_id  INT           NOT NULL,
    model_year   SMALLINT      NOT NULL,
    list_price   DECIMAL(10,2) NOT NULL
);

CREATE TABLE production.stocks (
    store_id   INT NOT NULL,
    product_id INT NOT NULL,
    quantity   INT NULL,
    PRIMARY KEY (store_id, product_id)
);

CREATE TABLE sales.customers (
    customer_id INT          NOT NULL PRIMARY KEY,
    first_name  VARCHAR(255) NOT NULL,
    last_name   VARCHAR(255) NOT NULL,
    phone       VARCHAR(25)  NULL,
    email       VARCHAR(255) NOT NULL,
    street      VARCHAR(255) NULL,
    city        VARCHAR(50)  NULL,
    state       VARCHAR(25)  NULL,
    zip_code    VARCHAR(5)   NULL
);

CREATE TABLE sales.stores (
    store_id   INT          NOT NULL PRIMARY KEY,
    store_name VARCHAR(255) NOT NULL,
    phone      VARCHAR(25)  NULL,
    email      VARCHAR(255) NULL,
    street     VARCHAR(255) NULL,
    city       VARCHAR(255) NULL,
    state      VARCHAR(10)  NULL,
    zip_code   VARCHAR(5)   NULL
);

CREATE TABLE sales.staffs (
    staff_id   INT          NOT NULL PRIMARY KEY,
    first_name VARCHAR(50)  NOT NULL,
    last_name  VARCHAR(50)  NOT NULL,
    email      VARCHAR(255) NOT NULL,
    phone      VARCHAR(25)  NULL,
    active     TINYINT      NOT NULL,
    store_id   INT          NOT NULL,
    manager_id INT          NULL
);

CREATE TABLE sales.orders (
    order_id      INT     NOT NULL PRIMARY KEY,
    customer_id   INT     NULL,
    order_status  TINYINT NOT NULL,
    order_date    DATE    NOT NULL,
    required_date DATE    NOT NULL,
    shipped_date  DATE    NULL,
    store_id      INT     NOT NULL,
    staff_id      INT     NOT NULL
);

CREATE TABLE sales.order_items (
    order_id   INT           NOT NULL,
    item_id    INT           NOT NULL,
    product_id INT           NOT NULL,
    quantity   INT           NOT NULL,
    list_price DECIMAL(10,2) NOT NULL,
    discount   DECIMAL(4,2)  NOT NULL,
    PRIMARY KEY (order_id, item_id)
);