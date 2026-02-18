Tento dokument obsahuje popis mezivýsledků a odpovědi na výzkumné otázky ze zadání Projektu SQL.

Popis tvorby tabulek:

Před vytvořením tabulky t_martin_gabriel_project_SQL_primary_final je byly vytvořené dva pohledy:

  1. v_martin_gabriel_czechia_price_joined
  2. v_martin_gabriel_czechia_payroll_joined

Tyto pohledy slouží zejména k:

  propojení sloupců s kódy v tabulkách czechia_payroll a czechia_price s jejich významem uchovaným v číselníkových tabulkách,
  rozdělení záznamu mezd na fyzické (nominální) a přepočtené (full-time equivalent / FTE),
  výpočtu meziročních změn mezd v odvětvích,
  výpočtu meziročních změn cen kategorií potravin.

1. Tvorba tabulky t_martin_gabriel_project_SQL_primary_final:

   1.1. Vytvoření pohledu v_martin_gabriel_czechia_price_joined
   
     Nejprve se vypočítá průměrná cena kategorie potravin za daný rok pomocí funkce AVG a propojí se s informacemi o jednotkách z číselníkových tabulek.
     Následně se z těchto průměrů vytvoří záznam o meziročním vývoji cen pomocí funkce LAG.
     Hodnoty jsou zaokrouhleny na desetinná procenta.

   1.2. Vytvoření pohledu v_martin_gabriel_czechia_payroll_joined
   
     Nejprve se propojí hodnoty kódů s číselníkovými tabulkami, analogicky jako u předchozího pohledu.
     Poté se pomocí CASE a agregační funkce MAX rozděluje záznam o mzdách do dvou sloupců podle hodnoty cpc.code,
     která odpovídá calculation_code z tabulky czechia_payroll.
     Filtruje se pomocí cp.value_type_code = 5958, aby zůstaly pouze informace o mzdách.
    
  
2. Tvorba tabulky t_martin_gabriel_project_SQL_secondary_final:

   Jednoduchý výběr potenciálně relevantních dat z tabulky economies.



Popis tvorby dotazů a odpovědi na výzkumné otázky.

1. Otázka: Rostou v průběhu let mzdy ve všech odvětvích, nebo v některých klesají?

  Provedení dotazu: Dotaz má 2 varianty. Záleží jestli nás zajímá meziroční pokles mezd, nebo pokles za celé měřené období.
  V první variantě se jedná o prostý SELECT s klauzulí WHERE.
  V druhé variantě musíme získat první a poslední rok měření, nominální mzdu a přepočetnou mzdu pro všchna odvětví. Toho je dosaženo pomocí funkce FIRST_VALUE.

  Odpověď: Existují jednotlivé roky, ve kterých nominální nebo přepočetná mzda výrazně klesá, zejména pak roky 2008-2010 (nejspíše důsledkem finanční krize) a 
           také roky 2013 a 2014.
           Za zmínku stojí odvětví Administrativní a podpůrné činnosti v letech 2013/2014,
           Peněžnictví a pojišťovnictví v období po finanční krizi v roce 2008,
           Těžba a dobývání zaznamenávají prudký pokles v období 2013 - 2016.
           Celkově však mzdy mají rostoucí trend a neexistuje odvětví, které by za měřené období nezaznamenalo celkový nárůst.
   
3. Otázka: Kolik je možné si koupit litrů mléka a kilogramů chleba za první a poslední srovnatelné období v dostupných datech cen a mezd?

   Provedení dotazu: 

   Odpověď:

5. Otázka: Která kategorie potravin zdražuje nejpomaleji (je u ní nejnižší percentuální meziroční nárůst)?

   Provedení dotazu: 

   Odpověď:
   
7. Otázka: Existuje rok, ve kterém je rozdíl mezi růstem průměrných cen potravin a mezd vyšší než 10 procent?

    Provedení dotazu: 

    Odpověď:
   
9. Otázka: Má výška HDP vliv na změny ve mzdách a cenách potravin? Neboli, pokud HDP vzroste výrazněji v jednom roce,
           projeví se to na cenách potravin či mzdách ve stejném nebo následujícím roce výraznějším růstem?

     Provedení dotazu: 

      Odpověď:
