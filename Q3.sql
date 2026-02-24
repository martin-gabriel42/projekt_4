--===================================================================================================
-- Q3 – čtvrtý projekt do Engeto Online Akademie
-- Autor: Martin Gabriel
--===================================================================================================
-- Tento skript slouží k zodpovězení výzkumné otázky č.3
-- Dotaz má dvě varianty, které odpovídají meziročním změnám, respektive změnám za celé období
-- Samotná odpověď na otázku se nachází v souboru doc.md v github repozitáři
--===================================================================================================

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