-- ==========================================================
-- martin_gabriel_table_generation_script – čtvrtý projekt do Engeto Online Akademie
-- Autor: Martin Gabriel
-- ==========================================================
-- Tento skript vytváří dvě výsledné tabulky.
-- Skript je navržen ke spuštění jako celek v uvedeném pořadí.

-- Příkazy DROP IF EXISTS jsou uvedeny zakomentované nad
-- jednotlivými objekty pro případ opakovaného spuštění.

-- Po spuštění skriptu budou v databázi vytvořeny tyto objekty:
--   TABLE t_martin_gabriel_project_SQL_primary_final
--   TABLE t_martin_gabriel_project_SQL_secondary_final

--Z těchto dat je možné spouštět skripty připravené k zodpovězení výzkumných otázek
-- ==========================================================

--DROP TABLE IF EXISTS t_martin_gabriel_project_SQL_primary_final;
CREATE TABLE t_martin_gabriel_project_sql_primary_final AS (
WITH price_data AS (
	SELECT
		measured_year,
		category_name,
		avg_price,
		ROUND(avg_price::numeric / LAG(avg_price::numeric) OVER (
			PARTITION BY category_name
			ORDER BY measured_year) * 100 - 100, 2) AS price_annual_perc_growth,
		price_value,
		price_unit
	FROM
		(SELECT
			ROUND(AVG(cp.value)::numeric, 2) AS avg_price,
			cpc.name AS category_name,
			date_part('year', cp.date_from)::int AS measured_year,
        	cpc.price_value,
			cpc.price_unit
		FROM
           	czechia_price cp
        LEFT JOIN czechia_price_category cpc
        	ON cp.category_code = cpc.code
        GROUP BY
        	category_name,
        	measured_year,
        	price_value,
        	price_unit )
),
payroll_data AS (
	SELECT
		industry_branch,
		nominal_wage,
		ROUND(nominal_wage::numeric / LAG(nominal_wage::numeric) OVER (
			PARTITION BY industry_branch
			ORDER BY payroll_year) * 100 - 100, 2) AS NW_perc_growth,
		fte_wage,
		ROUND(fte_wage::numeric / LAG(fte_wage::numeric) OVER (
			PARTITION BY industry_branch
			ORDER BY payroll_year) * 100 - 100, 2) AS FTE_perc_growth,
		payroll_year
	FROM
		(SELECT
			--Rozdělení záznamu o mzdách na sloupce o nominálních a fte mzdách
			MAX(CASE WHEN cpc.code = 100 THEN value END) AS nominal_wage,
    		MAX(CASE WHEN cpc.code = 200 THEN value END) AS fte_wage,
			cpib.name AS industry_branch,
			cp.payroll_year
		FROM
			czechia_payroll cp
		LEFT JOIN czechia_payroll_unit cpu 
			ON cpu.code = cp.unit_code
		LEFT JOIN czechia_payroll_calculation cpc 
			ON cpc.code = cp.calculation_code
		LEFT JOIN czechia_payroll_industry_branch cpib
			ON cpib.code = cp.industry_branch_code 
		WHERE 
			cp.value_type_code = 5958
			AND cp.value IS NOT NULL
			AND cpib.name IS NOT NULL
		--GROUP BY klauzule pro MAX funkce
		GROUP BY
			cpib.name,
			cp.payroll_year
		ORDER BY
			industry_branch,
			payroll_year)
)
SELECT 
	pr.measured_year AS year,
	pa.industry_branch,
	pa.nominal_wage,
	pa.nw_perc_growth,
	pa.fte_wage,
	pa.fte_perc_growth,
	pr.category_name,
	pr.avg_price,
	pr.price_annual_perc_growth,
	pr.price_value,
	pr.price_unit
FROM
	price_data pr
JOIN 
	payroll_data pa
	ON pr.measured_year = pa.payroll_year
);



--DROP TABLE IF EXISTS t_martin_gabriel_project_SQL_secondary_final;
CREATE TABLE t_martin_gabriel_project_sql_secondary_final AS (
SELECT
	e.year,
	e.country,
	e.gdp,
	e.gini,
	e.taxes,
	e.population
FROM
	economies e
JOIN countries c
	ON e.country = c.country
WHERE
	c.continent = 'Europe'
	AND e.year BETWEEN 
		(SELECT MIN(tmgpspf.year) FROM t_martin_gabriel_project_sql_primary_final tmgpspf) AND
		(SELECT MAX(tmgpspf.year) FROM t_martin_gabriel_project_sql_primary_final tmgpspf)
ORDER BY
	e.country,
	e.year);
