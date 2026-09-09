-- =============================================================
-- BikeStoreDW - Paso 2: Poblar DIM_DATE
-- Requiere: DIM_DATE ya creada (ver 01_create_dw_tables.sql)
--
-- Genera una fila por dia de 2015-01-01 a 2019-12-31.
-- Rango mas amplio que los datos (2016-2018) para cubrir
-- cualquier required_date / shipped_date fuera de rango.
-- La fila centinela (-1) se inserta en el script 01, no aqui.
-- =============================================================

USE [BikeStoreDW];
GO

;WITH Dates AS (
    SELECT CAST('2015-01-01' AS DATE) AS d
    UNION ALL
    SELECT DATEADD(DAY, 1, d)
    FROM Dates
    WHERE d < '2019-12-31'
)
INSERT INTO dbo.DIM_DATE
    (date_key, full_date, day, month, month_name, quarter, year,
     day_of_week, day_name, is_weekend)
SELECT
    CONVERT(INT, FORMAT(d, 'yyyyMMdd')) AS date_key,   -- ej. 20170315
    d                                    AS full_date,
    DAY(d)                               AS day,
    MONTH(d)                             AS month,
    DATENAME(MONTH, d)                   AS month_name,
    DATEPART(QUARTER, d)                 AS quarter,
    YEAR(d)                              AS year,
    DATEPART(WEEKDAY, d)                 AS day_of_week,
    DATENAME(WEEKDAY, d)                 AS day_name,
    CASE WHEN DATEPART(WEEKDAY, d) IN (1, 7) THEN 1 ELSE 0 END AS is_weekend
FROM Dates
OPTION (MAXRECURSION 32767);   -- ~1826 dias, supera el default de 100
GO

-- Verificacion
SELECT COUNT(*) AS total_rows FROM dbo.DIM_DATE;   -- esperado: 1827 (1826 + centinela)
GO
