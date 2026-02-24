--===================================================================================================
-- Q4 – čtvrtý projekt do Engeto Online Akademie
-- Autor: Martin Gabriel
--===================================================================================================
-- Tento skript slouží k zodpovězení výzkumné otázky č.4
-- Samotná odpověď na otázku se nachází v souboru doc.md v github repozitáři
--===================================================================================================

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