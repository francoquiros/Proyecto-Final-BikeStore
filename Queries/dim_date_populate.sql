-- =============================================================
-- BikeStoreDW - Paso 2: Poblar DIM_FECHA
-- Ejecutar CONECTADO a BikeStoreDW
-- Requiere: DIM_FECHA ya creada (ver 01_create_dw_tables.sql)
--
-- Genera una fila por dia de 2015-01-01 a 2019-12-31.
-- Rango mas amplio que los datos (2016-2018) para cubrir
-- cualquier required_date / shipped_date fuera de rango.
-- La fila centinela (-1) se inserta en el script 01, no aqui.
-- =============================================================

USE [BikeStoreDW];
GO

;WITH Fechas AS (
    SELECT CAST('2015-01-01' AS DATE) AS f
    UNION ALL
    SELECT DATEADD(DAY, 1, f)
    FROM Fechas
    WHERE f < '2019-12-31'
)
INSERT INTO dbo.DIM_FECHA
    (fecha_key, fecha_completa, dia, mes, nombre_mes, trimestre, ano,
     dia_semana, nombre_dia, es_fin_semana)
SELECT
    CONVERT(INT, FORMAT(f, 'yyyyMMdd')) AS fecha_key,   -- ej. 20170315
    f                                    AS fecha_completa,
    DAY(f)                               AS dia,
    MONTH(f)                             AS mes,
    DATENAME(MONTH, f)                   AS nombre_mes,
    DATEPART(QUARTER, f)                 AS trimestre,
    YEAR(f)                              AS ano,
    DATEPART(WEEKDAY, f)                 AS dia_semana,
    DATENAME(WEEKDAY, f)                 AS nombre_dia,
    CASE WHEN DATEPART(WEEKDAY, f) IN (1, 7) THEN 1 ELSE 0 END AS es_fin_semana
FROM Fechas
OPTION (MAXRECURSION 32767);   -- ~1826 dias, supera el default de 100
GO

-- Verificacion
SELECT COUNT(*) AS total_filas FROM dbo.DIM_FECHA;   -- esperado: 1827 (1826 + centinela)
GO
