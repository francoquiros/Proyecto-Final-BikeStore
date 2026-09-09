-- =============================================================
-- BikeStoreDW - Modelo dimensional
-- Requiere: base BikeStoreDW ya creada
--
-- Diseno:
--   2 tablas de hechos (FACT_SALES nivel linea, FACT_ORDERS nivel pedido)
--   5 dimensiones, 4 de ellas conformadas (compartidas)
--   Llaves subrogadas en las dimensiones + llave de negocio de origen
--   DIM_DATE con llave YYYYMMDD y fila centinela -1 (desconocida)
-- =============================================================

USE [BikeStoreDW];
GO

-- -------------------------------------------------------------
-- DIMENSIONES
-- -------------------------------------------------------------

-- Una fila por dia. Llave YYYYMMDD (ej. 20170315).
-- Fila -1 = fecha desconocida / no enviado.
CREATE TABLE dbo.DIM_DATE (
    date_key      INT          NOT NULL PRIMARY KEY,   -- YYYYMMDD  (o -1)
    full_date     DATE         NULL,
    day           TINYINT      NULL,
    month         TINYINT      NULL,
    month_name    VARCHAR(15)  NULL,
    quarter       TINYINT      NULL,
    year          SMALLINT     NULL,
    day_of_week   TINYINT      NULL,
    day_name      VARCHAR(15)  NULL,
    is_weekend    BIT          NULL
);

CREATE TABLE dbo.DIM_CUSTOMER (
    customer_key    INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
    customer_id_src INT          NOT NULL,     -- llave de negocio (origen)
    full_name       VARCHAR(255) NULL,
    city            VARCHAR(50)  NULL,
    state           VARCHAR(25)  NULL,
    zip_code        VARCHAR(5)   NULL
);

CREATE TABLE dbo.DIM_PRODUCT (
    product_key     INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
    product_id_src  INT           NOT NULL,
    name            VARCHAR(255)  NULL,
    brand           VARCHAR(255)  NULL,
    category        VARCHAR(255)  NULL,
    model_year      SMALLINT      NULL
);

CREATE TABLE dbo.DIM_STORE (
    store_key       INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
    store_id_src    INT          NOT NULL,
    name            VARCHAR(255) NULL,
    city            VARCHAR(255) NULL,
    state           VARCHAR(10)  NULL,
    zip_code        VARCHAR(5)   NULL
);

CREATE TABLE dbo.DIM_EMPLOYEE (
    employee_key    INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
    staff_id_src    INT          NOT NULL,
    full_name       VARCHAR(255) NULL,
    active          BIT          NULL,
    store_id_src    INT          NULL    -- tienda a la que pertenece
);
GO

-- -------------------------------------------------------------
-- HECHOS
-- -------------------------------------------------------------

-- Grano: una fila por linea de pedido (sales.order_items)
CREATE TABLE dbo.FACT_SALES (
    sale_key        BIGINT IDENTITY(1,1) NOT NULL PRIMARY KEY,
    date_key        INT           NOT NULL,   -- fecha del pedido
    customer_key    INT           NOT NULL,
    product_key     INT           NOT NULL,
    store_key       INT           NOT NULL,
    employee_key    INT           NOT NULL,
    order_id        INT           NOT NULL,   -- dimension degenerada
    item_id         INT           NOT NULL,   -- dimension degenerada
    quantity        INT           NOT NULL,
    list_price      DECIMAL(10,2) NOT NULL,
    discount        DECIMAL(4,2)  NOT NULL,
    line_amount     DECIMAL(12,2) NOT NULL,   -- quantity * list_price * (1 - discount)
    CONSTRAINT FK_FSales_Date     FOREIGN KEY (date_key)     REFERENCES dbo.DIM_DATE(date_key),
    CONSTRAINT FK_FSales_Customer FOREIGN KEY (customer_key) REFERENCES dbo.DIM_CUSTOMER(customer_key),
    CONSTRAINT FK_FSales_Product  FOREIGN KEY (product_key)  REFERENCES dbo.DIM_PRODUCT(product_key),
    CONSTRAINT FK_FSales_Store    FOREIGN KEY (store_key)    REFERENCES dbo.DIM_STORE(store_key),
    CONSTRAINT FK_FSales_Employee FOREIGN KEY (employee_key) REFERENCES dbo.DIM_EMPLOYEE(employee_key)
);

-- Grano: una fila por pedido (sales.orders) -- responde R3 y R4
CREATE TABLE dbo.FACT_ORDERS (
    order_key           BIGINT IDENTITY(1,1) NOT NULL PRIMARY KEY,
    order_date_key      INT           NOT NULL,          -- rol 1: order_date
    required_date_key   INT           NOT NULL,          -- rol 2: required_date
    shipped_date_key    INT           NOT NULL,          -- rol 3: shipped_date (-1 si no enviado)
    customer_key        INT           NOT NULL,
    store_key           INT           NOT NULL,
    employee_key        INT           NOT NULL,
    order_id            INT           NOT NULL,           -- dimension degenerada
    order_status        TINYINT       NULL,
    days_late           INT           NULL,   -- DATEDIFF(dia, required, shipped); NULL si no enviado
    is_late             BIT           NULL,   -- 1 si shipped > required
    is_shipped          BIT           NOT NULL, -- 1 si tiene fecha de envio
    order_total_amount  DECIMAL(12,2) NULL,   -- suma de line_amount de sus lineas
    CONSTRAINT FK_FOrders_ODate    FOREIGN KEY (order_date_key)    REFERENCES dbo.DIM_DATE(date_key),
    CONSTRAINT FK_FOrders_RDate    FOREIGN KEY (required_date_key)  REFERENCES dbo.DIM_DATE(date_key),
    CONSTRAINT FK_FOrders_SDate    FOREIGN KEY (shipped_date_key)   REFERENCES dbo.DIM_DATE(date_key),
    CONSTRAINT FK_FOrders_Customer FOREIGN KEY (customer_key) REFERENCES dbo.DIM_CUSTOMER(customer_key),
    CONSTRAINT FK_FOrders_Store    FOREIGN KEY (store_key)    REFERENCES dbo.DIM_STORE(store_key),
    CONSTRAINT FK_FOrders_Employee FOREIGN KEY (employee_key) REFERENCES dbo.DIM_EMPLOYEE(employee_key)
);
GO

-- Fila centinela: fechas desconocidas / pedidos no enviados
INSERT INTO dbo.DIM_DATE (date_key, full_date) VALUES (-1, NULL);
GO
