--===================================================================================================
-- martin_gabriel_research_questions – čtvrtý projekt do Engeto Online Akademie
-- Autor: Martin Gabriel
--===================================================================================================
-- Tento skript slouží k zodpovězení výzkumných otázek
-- 1. a 3. dotaz má dvě varianty, které odpovídají meziročním změnám, respektive změnám za celé období

-- Samotné odpovědi na otázky se nachází v souboru doc.md v github repozitáři
--===================================================================================================

--1) Rostou v průběhu let mzdy ve všech odvětvích, nebo v některých klesají?

-- 1. varianta: pokles mezd v daných letech
SELECT DISTINCT
	tmgpspf.year,
	tmgpspf.industry_branch,
	tmgpspf.nw_perc_growth,
	tmgpspf.fte_perc_growth
FROM
	t_martin_gabriel_project_sql_primary_final tmgpspf
WHERE 1=2
	OR tmgpspf.nw_perc_growth <= 0
	OR tmgpspf.fte_perc_growth <= 0
ORDER BY
	tmgpspf.industry_branch,
	tmgpspf.year ASC;

-- 2. varianta: pokles mezd za celé měřené období
WITH measured_wages AS (
	SELECT DISTINCT
		tmgpspf.industry_branch,
		FIRST_VALUE(tmgpspf.year) OVER (
			PARTITION BY tmgpspf.industry_branch
			ORDER BY tmgpspf.year ASC) AS first_measured_year,
		FIRST_VALUE(tmgpspf.year) OVER (
			PARTITION BY tmgpspf.industry_branch
			ORDER BY tmgpspf.year DESC) AS last_measured_year,
		FIRST_VALUE(tmgpspf.nominal_wage) OVER (
			PARTITION BY tmgpspf.industry_branch
			ORDER BY tmgpspf.year ASC) AS first_measured_nw,
		FIRST_VALUE(tmgpspf.nominal_wage) OVER (
			PARTITION BY tmgpspf.industry_branch
			ORDER BY tmgpspf.year DESC) AS last_measured_nw,
		FIRST_VALUE(tmgpspf.fte_wage) OVER (
			PARTITION BY tmgpspf.industry_branch
			ORDER BY tmgpspf.year ASC) AS first_measured_fte,
		FIRST_VALUE(tmgpspf.fte_wage) OVER (
			PARTITION BY tmgpspf.industry_branch
			ORDER BY tmgpspf.year DESC) AS last_measured_fte
	FROM
		t_martin_gabriel_project_sql_primary_final tmgpspf)
SELECT
	mw.industry_branch,
	mw.first_measured_year,
	mw.last_measured_year,
	mw.first_measured_nw AS first_measured_nominal_wage,
	mw.last_measured_nw AS last_measured_nominal_wage,
	mw.first_measured_fte,
	mw.last_measured_fte
FROM
	measured_wages mw
WHERE 1=2
	OR mw.first_measured_nw > mw.last_measured_nw
	OR mw.first_measured_fte > mw.last_measured_fte;



--2) Kolik je možné si koupit litrů mléka a kilogramů chleba
--   za první a poslední srovnatelné období v dostupných datech cen a mezd?
SELECT
	tmgpspf.year,
	tmgpspf.industry_branch,
	tmgpspf.category_name,
	--tmgpspf.nominal_wage,
	--tmgpspf.avg_price,
	ROUND(tmgpspf.nominal_wage / avg_price, 0) AS available_amount, --množství dostupných potravin
	tmgpspf.price_unit
FROM
	t_martin_gabriel_project_sql_primary_final tmgpspf
WHERE 1=1
	AND tmgpspf.year IN (
		SELECT MAX(tmgpspf.year) FROM t_martin_gabriel_project_sql_primary_final tmgpspf
		UNION
		SELECT MIN(tmgpspf.year) FROM t_martin_gabriel_project_sql_primary_final tmgpspf)
	AND tmgpspf.category_name IN ('Chléb konzumní kmínový', 'Mléko polotučné pasterované')
ORDER BY
	tmgpspf.category_name,
	tmgpspf.year,
	tmgpspf.industry_branch;



-- 3) Která kategorie potravin zdražuje nejpomaleji
--    (je u ní nejnižší percentuální meziroční nárůst)?

-- 1. varianta: nejpomalejší růst cen v daných letech
SELECT
	year,
	category_name,
	price_annual_perc_growth
FROM
	(SELECT DISTINCT
		tmgpspf.year,
		tmgpspf.category_name,
		tmgpspf.price_annual_perc_growth,
		RANK() OVER (
			PARTITION BY tmgpspf.year
			ORDER BY tmgpspf.price_annual_perc_growth) AS ranking
	FROM
		t_martin_gabriel_project_sql_primary_final tmgpspf
	WHERE 1=1
		AND tmgpspf.price_annual_perc_growth IS NOT NULL
		-- Volitelný filtr: pouze kateogorie s neklesajícími cenami
		--AND tmgpspf.price_annual_perc_growth > 0
		)
WHERE
	ranking = 1
ORDER BY 
	year;

-- 2.varianta: nejpomalejší růst cen za celé měřené období
WITH measured_prices AS (
	SELECT DISTINCT
		tmgpspf.category_name,
		FIRST_VALUE(tmgpspf.year) OVER (
			PARTITION BY tmgpspf.category_name
			ORDER BY tmgpspf.year ASC) AS first_measured_year,
		FIRST_VALUE(tmgpspf.year) OVER (
			PARTITION BY tmgpspf.category_name
			ORDER BY tmgpspf.year DESC) AS last_measured_year,
		FIRST_VALUE(tmgpspf.avg_price) OVER (
			PARTITION BY tmgpspf.category_name
			ORDER BY tmgpspf.year ASC) AS first_measured_price,
		FIRST_VALUE(tmgpspf.avg_price) OVER (
			PARTITION BY tmgpspf.category_name
			ORDER BY tmgpspf.year DESC) AS last_measured_price
	FROM
		t_martin_gabriel_project_sql_primary_final tmgpspf)
SELECT
	mp.category_name,
	ROUND((mp.last_measured_price / mp.first_measured_price) * 100 - 100, 2) AS total_perc_price_change,
	mp.first_measured_year,
	mp.last_measured_year,
	mp.first_measured_price,
	mp.last_measured_price
FROM
	measured_prices mp
WHERE 1=1
	-- Volitelný filtr: pouze kateogorie s neklesajícími cenami
	--AND (mp.last_measured_price / mp.first_measured_price) - 1 > 0
ORDER BY
	total_perc_price_change
LIMIT 1;



--4) Existuje rok, ve kterém je rozdíl mezi růstem průměrných cen potravin a mezd vyšší než 10 procent?
WITH stats_growth AS (
	SELECT
		avg_stats.year,
		--avg_stats.avg_nw,
		--avg_stats.avg_prices,
		ROUND(avg_stats.avg_nw / LAG(avg_stats.avg_nw) OVER (
			ORDER BY avg_stats.year) * 100 - 100, 2) AS avg_nom_wage_perc_growth,
		ROUND(avg_stats.avg_prices / LAG(avg_stats.avg_prices) OVER (
			ORDER BY avg_stats.year) * 100 - 100, 2) AS avg_prices_perc_growth
	FROM (
		SELECT
			tmgpspf.year,
			AVG(tmgpspf.nominal_wage) AS avg_nw,
			AVG(tmgpspf.avg_price) AS avg_prices
		FROM
			t_martin_gabriel_project_sql_primary_final tmgpspf
		GROUP BY
			tmgpspf.year) AS avg_stats)
SELECT 
	*,
	sg.avg_nom_wage_perc_growth - sg.avg_prices_perc_growth AS diff
FROM
	stats_growth sg
WHERE 1=1
	AND ABS(sg.avg_nom_wage_perc_growth - sg.avg_prices_perc_growth) > 10
ORDER BY
	sg.year;



--5) Má výška HDP vliv na změny ve mzdách a cenách potravin?
--   Neboli, pokud HDP vzroste výrazněji v jednom roce,
--   projeví se to na cenách potravin či mzdách ve stejném nebo následujícím roce výraznějším růstem?
SELECT
	wages_and_prices.year,
	wages_and_prices.avg_nw_perc_growth AS avg_nom_wage_perc_growth,
	wages_and_prices.avg_prices_perc_growth,
	gdp_growth.nom_gdp_growth
FROM
	(SELECT
		tmgpspf.year,
		ROUND(AVG(tmgpspf.nominal_wage::NUMERIC)/ LAG(AVG(tmgpspf.nominal_wage::NUMERIC)) OVER (
			ORDER BY tmgpspf.year ) * 100 - 100, 2) AS avg_nw_perc_growth,
		ROUND(AVG(tmgpspf.avg_price::NUMERIC)/ LAG(AVG(tmgpspf.avg_price::NUMERIC)) OVER (
			ORDER BY tmgpspf.year ) * 100 - 100, 2) AS avg_prices_perc_growth
	FROM
		t_martin_gabriel_project_sql_primary_final tmgpspf
	GROUP BY
		tmgpspf.year) AS wages_and_prices
INNER JOIN (
	SELECT
		tmgpssf.year,
		ROUND(tmgpssf.gdp::numeric / LAG(tmgpssf.gdp::numeric) OVER (
			ORDER BY tmgpssf.year) * 100 - 100, 2) AS nom_gdp_growth
	FROM
		t_martin_gabriel_project_SQL_secondary_final tmgpssf
	WHERE
		tmgpssf.country = 'Czech Republic') AS gdp_growth
	ON wages_and_prices.year = gdp_growth.year
ORDER BY
	wages_and_prices.year;


