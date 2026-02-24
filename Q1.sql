--===================================================================================================
-- Q1 – čtvrtý projekt do Engeto Online Akademie
-- Autor: Martin Gabriel
--===================================================================================================
-- Tento skript slouží k zodpovězení výzkumné otázky č.1
-- Dotaz má dvě varianty, které odpovídají meziročním změnám, respektive změnám za celé období
-- Samotná odpověď na otázku se nachází v souboru doc.md v github repozitáři
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