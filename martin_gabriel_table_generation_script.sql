-- ==========================================================
-- martin_gabriel_table_generation_script – čtvrtý projekt do Engeto Online Akademie
-- Autor: Martin Gabriel
-- ==========================================================
-- Tento skript vytváří dva pohledy a dvě výsledné tabulky.
-- Pohledy musí být vytvořeny před vytvořením primární tabulky.
-- Skript je navržen ke spuštění jako celek v uvedeném pořadí.

-- Příkazy DROP IF EXISTS jsou uvedeny zakomentované nad
-- jednotlivými objekty pro případ opakovaného spuštění.

-- Po spuštění skriptu budou v databázi vytvořeny tyto objekty:
--   VIEW  v_martin_gabriel_czechia_price_joined
--   VIEW  v_martin_gabriel_czechia_payroll_joined
--   TABLE t_martin_gabriel_project_SQL_primary_final
--   TABLE t_martin_gabriel_project_SQL_secondary_final

--Z těchto dat je možné spouštět skripty připravené k zodpovězení výzkumných otázek
-- ==========================================================

--DROP VIEW IF EXISTS  v_martin_gabriel_czechia_price_joined;
CREATE OR REPLACE VIEW v_martin_gabriel_czechia_price_joined AS (
	SELECT
		measured_year,
		category_name,
		avg_price,
		ROUND(avg_price::numeric / LAG(avg_price::numeric) OVER (
			PARTITION BY category_name
			ORDER BY measured_year) * 100 - 100, 2) AS price_annual_perc_growth,
		--ROUND(avg_price::numeric / FIRST_VALUE(avg_price::numeric) OVER (
			--PARTITION BY category_name
			--ORDER BY measured_year) * 100 - 100, 2) AS price_compound_perc_growth,
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
        	price_unit
        )
	);


--DROP VIEW IF EXISTS v_martin_gabriel_czechia_payroll_joined;
CREATE OR REPLACE VIEW v_martin_gabriel_czechia_payroll_joined AS (
	SELECT
		industry_branch,
		nominal_wage,
		ROUND(nominal_wage::numeric / LAG(nominal_wage::numeric) OVER (
			PARTITION BY industry_branch
			ORDER BY payroll_year) * 100 - 100, 2) AS NW_perc_growth,
		full_time_equivalent,
		ROUND(full_time_equivalent::numeric / LAG(full_time_equivalent::numeric) OVER (
			PARTITION BY industry_branch
			ORDER BY payroll_year) * 100 - 100, 2) AS FTE_perc_growth,
		payroll_year
	FROM
		(SELECT
			--Rozdělení záznamu o mzdách na sloupce o nominálních a fte mzdách
			MAX(CASE WHEN cpc.code = 100 THEN value END) AS nominal_wage,
    		MAX(CASE WHEN cpc.code = 200 THEN value END) AS full_time_equivalent,
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
	);


--DROP TABLE IF EXISTS t_martin_gabriel_project_SQL_primary_final;
CREATE TABLE t_martin_gabriel_project_SQL_primary_final AS (
	SELECT
		measured_year AS year,
		industry_branch,
		nominal_wage,
		nw_perc_growth,
		full_time_equivalent AS fte_wage,
		fte_perc_growth,
		category_name,
		avg_price,
		price_annual_perc_growth,
		price_value,
		price_unit
	FROM
		v_martin_gabriel_czechia_payroll_joined vmgcpj
	INNER JOIN v_martin_gabriel_czechia_price_joined vmgcpj2 
		ON vmgcpj.payroll_year = vmgcpj2.measured_year
	);


--DROP TABLE IF EXISTS t_martin_gabriel_project_SQL_secondary_final;
CREATE TABLE t_martin_gabriel_project_SQL_secondary_final AS (
	SELECT
		e.year,
		e.country,
		e.gdp,
		e.population
	FROM
		economies e
	WHERE
		e.gdp IS NOT NULL
	);
