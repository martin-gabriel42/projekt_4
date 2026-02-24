--===================================================================================================
-- Q2 – čtvrtý projekt do Engeto Online Akademie
-- Autor: Martin Gabriel
--===================================================================================================
-- Tento skript slouží k zodpovězení výzkumné otázky č.2
-- Samotná odpověď na otázku se nachází v souboru doc.md v github repozitáři
--===================================================================================================

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
	tmgpspf.industry_branch,
	tmgpspf.category_name,
	tmgpspf.year;
