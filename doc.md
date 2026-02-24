Tento dokument obsahuje popis mezivýsledků a odpovědi na výzkumné otázky ze zadání Projektu SQL.



# Popis tvorby tabulek:

Tabulky byly vytvořeny pomocí CTE, vnořených SELECT dotazů, agregačních a analytických (window) funkcí.

### Účel mezivýpočtů a CTE:

  - propojení sloupců s kódy v tabulkách czechia_payroll a czechia_price s jejich významem uchovaným v číselníkových tabulkách,
  - rozdělení záznamu mezd na fyzické (nominální) a přepočtené (full-time equivalent / FTE),
  - výpočet meziročních změn mezd v odvětvích,
  - výpočet meziročních změn cen kategorií potravin.


## 1. Vytvoření tabulky t_martin_gabriel_project_SQL_primary_final:

   ### 1.1 CTE price_data
   Pomocí agregační funkce AVG je vypočtena průměrná cena jednotlivých kategorií potravin za daný rok. Tyto hodnoty jsou propojeny s číselníkovými tabulkami, aby byly doplněny informace o jednotkách.

Pomocí analytické funkce LAG je následně spočten meziroční vývoj cen. Výsledné změny jsou převedeny na procenta a zaokrouhleny na 2 desetinná místa.

   ### 1.2. CTE payroll_data
   
   Stejně jako v předchozím případě dochází nejprve k propojení kódů s číselníkovými tabulkami.

Pomocí konstrukce CASE a agregační funkce MAX jsou hodnoty mezd rozděleny do dvou sloupců podle hodnoty cpc.code, která odpovídá calculation_code z tabulky czechia_payroll.

Filtr cp.value_type_code = 5958 zajišťuje, že zůstávají pouze údaje o mzdách

    
## 2. Vytvoření tabulky t_martin_gabriel_project_SQL_secondary_final:

Tabulka byla vytvořena výběrem relevantních dat z tabulky economies. Pomocí filtru podle kontinentu a časového období byla omezena množina zemí i sledovaných let. Tabulka obsahuje zejména údaje o HDP, které jsou následně využity k analýze vztahu mezi vývojem ekonomiky, mezd a cen.

Tabulka byla vytvořena na základě dat z tabulky t_martin_gabriel_project_SQL_primary_final. Bez této tabulky nelze sekundární tabulku vytvořit pomocí původního (neupraveného) skriptu.



# Popis tvorby dotazů a odpovědi na výzkumné otázky.

## 1. Otázka: Rostou v průběhu let mzdy ve všech odvětvích, nebo v některých klesají?

### Provedení dotazu: 
  
Dotaz má 2 varianty:

1. Analýza meziročního poklesu mezd pomocí jednoduchého SELECT s podmínkou WHERE.

2. Analýza celkového vývoje za celé období – zde je nutné získat první a poslední rok měření a odpovídající hodnoty nominální i přepočtené mzdy pomocí funkce FIRST_VALUE.

### Odpověď: 
  
Existují jednotlivé roky, ve kterých nominální i přepočtené mzdy výrazně klesají, zejména období 2008–2010 (pravděpodobně v důsledku globální finanční krize) a také roky 2013 a 2014.

Výraznější pokles byl zaznamenán například:

- v odvětví Administrativní a podpůrné činnosti (2013–2014),
- v odvětví Peněžnictví a pojišťovnictví po finanční krizi roku 2008.
- v odvětví Těžba a dobývání (2013–2016).

Celkově však mzdy vykazují dlouhodobě rostoucí trend a neexistuje odvětví, které by za celé sledované období nezaznamenalo celkový nárůst.
   
## 2. Otázka: Kolik je možné si koupit litrů mléka a kilogramů chleba za první a poslední srovnatelné období v dostupných datech cen a mezd?

### Provedení dotazu:

Výpočet je proveden jako podíl nominální mzdy a průměrné ceny konkrétní potraviny v daném roce.

### Odpověď:

Růst cen chleba v daném období v řadě odvětví převyšoval růst mezd, a to zejména v relativně lépe placených odvětvích, jako je Peněžnictví a pojišťovnictví a Těžba a dobývání. Kupní síla ve vztahu ke chlebu se tak v průběhu sledovaných let celkově výrazně nezměnila, případně v některých odvětvích mírně klesla.

Naopak růst cen mléka byl ve sledovaném období nižší než růst mezd téměř ve všech odvětvích, s výjimkou odvětví Peněžnictví a pojišťovnictví, kde došlo k poklesu kupní síly. Obecně tedy lze konstatovat, že kupní síla u mléka ve většině odvětví rostla.

## 3. Otázka: Která kategorie potravin zdražuje nejpomaleji (je u ní nejnižší percentuální meziroční nárůst)?

### Provedení dotazu:

Opět existují dvě varianty:

1. Výběr nejnižšího meziročního nárůstu pomocí funkce RANK ve vnořeném dotazu.
2. Výpočet změny mezi prvním a posledním rokem sledovaného období.

V obou variantách je možné filtrovat pouze kladné meziroční změny (ignorovat pokles).

### Odpověď:

Odpověď pro 1. variantu lze získat po provedení dotazu pro každý rok zvlášť.
Největší meziroční pokles cen zaznamenala kategorie Rajská jablka červená kulatá v roce 2007, kdy ceny klesly o 30% v porovnání s rokem 2006.

Celkově největší pokles cen zaznamenal cukr krystalový.
Celkově nejmenší nárůst cen zaznamenaly banány žluté.

## 4. Otázka: Existuje rok, ve kterém je rozdíl mezi růstem průměrných cen potravin a mezd vyšší než 10 procent?

### Provedení dotazu:

Nejprve je nutné spočítat průměrnou nominální mzdu a průměrnou cenu potravin pomocí funkce AVG.
Meziroční změna je následně vypočtena pomocí funkce LAG.

### Odpověď:

V roce 2009 je rozdíl mezi růstem průměrné nominální mzdy a poklesem průměrných cen potravin 10,42 procent.

Rozdíly v jiných letech nepřesáhly 10 procent.
   
## 5. Otázka: Má výška HDP vliv na změny ve mzdách a cenách potravin? Neboli, pokud HDP vzroste výrazněji v jednom roce, projeví se to na cenách potravin či mzdách ve stejném nebo následujícím roce výraznějším růstem?

### Provedení dotazu: 

Analogicky k předchozí otázce je nejprve spočítána průměrná nominální mzda a průměrná cena potravin a jejich meziroční změna.

Následně je provedeno spojení se sekundární tabulkou obsahující údaje o HDP České republiky, což umožňuje analyzovat vztah mezi vývojem HDP, mezd a cen.

Protože nejsou dostupná data pro výpočet meziroční změny za rok 2006, tento rok není do analýzy zahrnut.

### Odpověď:

Existuje vztah mezi změnou HDP a změnou mezd, mzdy typciky následují vývoj HDP se spožděním do 1 roku.

Vztah mezi HDP a cenami potravin je méně jednoznačný. Ceny obecně reagují na vývoj HDP se zpožděním 1 roku (období 2008–2010) až 3 let (období 2012–2017).
