# Proyecto Final - BikeStore

Franco Quiros - 304850621

Fernanda Porras - 116940902

## Base de Datos - BikeStore

![Database diagram](assets/SQL-Server-Sample-Database.png)

## ETL

Extraccion de datos de BikeStore -> BikeStoreStage -> BikeStoreDW

**Dimensiones:**

- Clientes
- Tiendas
- Empleados
- Fecha
- Productos
- Órdenes



Propuesta DW

```mermaid
erDiagram

    DIM_PRODUCTO {
        int producto_key PK
        int producto_id_origen
        string nombre
        string marca
        string categoria
        int model_year
    }

    DIM_CLIENTE {
        int cliente_key PK
        int customer_id_origen
        string nombre_completo
        string city
        string state
        string zip_code
    }

    DIM_TIENDA {
        int tienda_key PK
        int store_id_origen
        string nombre
        string city
        string state
        string zip_code
    }

    DIM_EMPLEADO {
        int empleado_key PK
        int staff_id_origen
        string nombre_completo
        boolean activo
    }

    DIM_FECHA {
        int fecha_key PK
        date fecha_completa
        int dia
        int mes
        string nombre_mes
        int trimestre
        int ano
    }

    FACT_VENTAS {
        int venta_key PK
        int order_id
        int producto_key FK
        int cliente_key FK
        int tienda_key FK
        int empleado_key FK
        int fecha_key FK
        int quantity
        decimal list_price
        decimal discount
        decimal venta_linea
    }

    DIM_PRODUCTO ||--o{ FACT_VENTAS : "producto"
    DIM_CLIENTE ||--o{ FACT_VENTAS : "cliente"
    DIM_TIENDA ||--o{ FACT_VENTAS : "tienda"
    DIM_EMPLEADO ||--o{ FACT_VENTAS : "empleado"
    DIM_FECHA ||--o{ FACT_VENTAS : "fecha de venta"
```
