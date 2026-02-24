--===================================================================================================
-- Q5 – čtvrtý projekt do Engeto Online Akademie
-- Autor: Martin Gabriel
--===================================================================================================
-- Tento skript slouží k zodpovězení výzkumné otázky č.5
-- Samotná odpověď na otázku se nachází v souboru doc.md v github repozitáři
--===================================================================================================

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
WHERE 1=1
	AND wages_and_prices.avg_nw_perc_growth IS NOT NULL
	AND wages_and_prices.avg_prices_perc_growth IS NOT NULL
	AND gdp_growth.nom_gdp_growth IS NOT NULL
ORDER BY
	wages_and_prices.year;