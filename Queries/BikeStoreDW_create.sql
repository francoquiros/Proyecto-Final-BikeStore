USE [BikeStoreDW];
GO

-- -------------------------------------------------------------
-- DIMENSIONES
-- -------------------------------------------------------------

-- Una fila por dia. Llave YYYYMMDD (ej. 20170315).
-- Fila -1 = fecha desconocida / pedido no enviado.
CREATE TABLE dbo.DIM_FECHA (
    fecha_key       INT          NOT NULL PRIMARY KEY,   -- YYYYMMDD  (o -1)
    fecha_completa  DATE         NULL,
    dia             TINYINT      NULL,
    mes             TINYINT      NULL,
    nombre_mes      VARCHAR(15)  NULL,
    trimestre       TINYINT      NULL,
    ano             SMALLINT     NULL,
    dia_semana      TINYINT      NULL,
    nombre_dia      VARCHAR(15)  NULL,
    es_fin_semana   BIT          NULL
);

CREATE TABLE dbo.DIM_CLIENTE (
    cliente_key        INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
    customer_id_origen INT          NOT NULL,     -- llave de negocio
    nombre_completo    VARCHAR(255) NULL,
    city               VARCHAR(50)  NULL,
    state              VARCHAR(25)  NULL,
    zip_code           VARCHAR(5)   NULL
);

CREATE TABLE dbo.DIM_PRODUCTO (
    producto_key       INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
    producto_id_origen INT           NOT NULL,
    nombre             VARCHAR(255)  NULL,
    marca              VARCHAR(255)  NULL,   -- aplanado desde production.brands
    categoria          VARCHAR(255)  NULL,   -- aplanado desde production.categories
    model_year         SMALLINT      NULL
);

CREATE TABLE dbo.DIM_TIENDA (
    tienda_key       INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
    store_id_origen  INT          NOT NULL,
    nombre           VARCHAR(255) NULL,
    city             VARCHAR(255) NULL,
    state            VARCHAR(10)  NULL,
    zip_code         VARCHAR(5)   NULL
);

CREATE TABLE dbo.DIM_EMPLEADO (
    empleado_key     INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
    staff_id_origen  INT          NOT NULL,
    nombre_completo  VARCHAR(255) NULL,
    activo           BIT          NULL,
    store_id_origen  INT          NULL    -- tienda a la que pertenece
);
GO

-- -------------------------------------------------------------
-- HECHOS
-- -------------------------------------------------------------

-- Grano: una fila por linea de pedido (sales.order_items)
CREATE TABLE dbo.FACT_VENTAS (
    venta_key       BIGINT IDENTITY(1,1) NOT NULL PRIMARY KEY,
    fecha_key       INT           NOT NULL,   -- fecha del pedido
    cliente_key     INT           NOT NULL,
    producto_key    INT           NOT NULL,
    tienda_key      INT           NOT NULL,
    empleado_key    INT           NOT NULL,
    order_id        INT           NOT NULL,   -- dim degenerada
    item_id         INT           NOT NULL,   -- dim degenerada  (faltaba en la v1)
    quantity        INT           NOT NULL,
    list_price      DECIMAL(10,2) NOT NULL,
    discount        DECIMAL(4,2)  NOT NULL,
    venta_linea     DECIMAL(12,2) NOT NULL,   -- quantity * list_price * (1 - discount)
    CONSTRAINT FK_FVentas_Fecha    FOREIGN KEY (fecha_key)    REFERENCES dbo.DIM_FECHA(fecha_key),
    CONSTRAINT FK_FVentas_Cliente  FOREIGN KEY (cliente_key)  REFERENCES dbo.DIM_CLIENTE(cliente_key),
    CONSTRAINT FK_FVentas_Producto FOREIGN KEY (producto_key) REFERENCES dbo.DIM_PRODUCTO(producto_key),
    CONSTRAINT FK_FVentas_Tienda   FOREIGN KEY (tienda_key)   REFERENCES dbo.DIM_TIENDA(tienda_key),
    CONSTRAINT FK_FVentas_Empleado FOREIGN KEY (empleado_key) REFERENCES dbo.DIM_EMPLEADO(empleado_key)
);

-- Grano: una fila por pedido (sales.orders) -- responde R3 y R4
CREATE TABLE dbo.FACT_PEDIDOS (
    pedido_key          BIGINT IDENTITY(1,1) NOT NULL PRIMARY KEY,
    fecha_pedido_key    INT           NOT NULL,          -- rol 1: order_date
    fecha_requerida_key INT           NOT NULL,          -- rol 2: required_date
    fecha_envio_key     INT           NOT NULL,          -- rol 3: shipped_date (-1 si no enviado)
    cliente_key         INT           NOT NULL,
    tienda_key          INT           NOT NULL,
    empleado_key        INT           NOT NULL,
    order_id            INT           NOT NULL,           -- dim degenerada
    order_status        TINYINT       NULL,
    dias_atraso         INT           NULL,   -- DATEDIFF(dia, requerida, envio); NULL si no enviado
    flag_tardio         BIT           NULL,   -- 1 si envio > requerida
    flag_enviado        BIT           NOT NULL, -- 1 si tiene fecha de envio
    monto_total_pedido  DECIMAL(12,2) NULL,   -- suma de venta_linea de sus lineas
    CONSTRAINT FK_FPedidos_FPedido    FOREIGN KEY (fecha_pedido_key)    REFERENCES dbo.DIM_FECHA(fecha_key),
    CONSTRAINT FK_FPedidos_FRequerida FOREIGN KEY (fecha_requerida_key) REFERENCES dbo.DIM_FECHA(fecha_key),
    CONSTRAINT FK_FPedidos_FEnvio     FOREIGN KEY (fecha_envio_key)     REFERENCES dbo.DIM_FECHA(fecha_key),
    CONSTRAINT FK_FPedidos_Cliente    FOREIGN KEY (cliente_key)  REFERENCES dbo.DIM_CLIENTE(cliente_key),
    CONSTRAINT FK_FPedidos_Tienda     FOREIGN KEY (tienda_key)   REFERENCES dbo.DIM_TIENDA(tienda_key),
    CONSTRAINT FK_FPedidos_Empleado   FOREIGN KEY (empleado_key) REFERENCES dbo.DIM_EMPLEADO(empleado_key)
);
GO

-- Fila centinela: fechas desconocidas / pedidos no enviados
INSERT INTO dbo.DIM_FECHA (fecha_key, fecha_completa) VALUES (-1, NULL);
GO
