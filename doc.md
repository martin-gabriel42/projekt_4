Tento dokument obsahuje popis mezivýsledků a odpovědi na výzkumné otázky ze zadání Projektu SQL.

#Popis tvorby tabulek:

Před vytvořením tabulky t_martin_gabriel_project_SQL_primary_final byly vytvořené dva pohledy:

  1. v_martin_gabriel_czechia_price_joined
  2. v_martin_gabriel_czechia_payroll_joined

###Tyto pohledy slouží zejména k:

  propojení sloupců s kódy v tabulkách czechia_payroll a czechia_price s jejich významem uchovaným v číselníkových tabulkách,
  rozdělení záznamu mezd na fyzické (nominální) a přepočtené (full-time equivalent / FTE),
  výpočtu meziročních změn mezd v odvětvích,
  výpočtu meziročních změn cen kategorií potravin.

##1. Tvorba tabulky t_martin_gabriel_project_SQL_primary_final:

   ###1.1. Vytvoření pohledu v_martin_gabriel_czechia_price_joined
   Nejprve se vypočítá průměrná cena kategorie potravin za daný rok pomocí funkce AVG a propojí se s informacemi o jednotkách z číselníkových tabulek.
   Následně se z těchto průměrů vytvoří záznam o meziročním vývoji cen pomocí funkce LAG.
   Hodnoty jsou zaokrouhleny na desetinná procenta.

   ###1.2. Vytvoření pohledu v_martin_gabriel_czechia_payroll_joined
   
   Nejprve se propojí hodnoty kódů s číselníkovými tabulkami, analogicky jako u předchozího pohledu.
   Poté se pomocí CASE a agregační funkce MAX rozděluje záznam o mzdách do dvou sloupců podle hodnoty cpc.code,
   která odpovídá calculation_code z tabulky czechia_payroll.
   Filtruje se pomocí cp.value_type_code = 5958, aby zůstaly pouze informace o mzdách.
    
  
##2. Tvorba tabulky t_martin_gabriel_project_SQL_secondary_final:

   Jednoduchý výběr potenciálně relevantních dat z tabulky economies.



#Popis tvorby dotazů a odpovědi na výzkumné otázky.

##1. Otázka: Rostou v průběhu let mzdy ve všech odvětvích, nebo v některých klesají?

###Provedení dotazu: 
  
Dotaz má 2 varianty. Záleží jestli nás zajímá meziroční pokles mezd, nebo pokles za celé měřené období.
V první variantě se jedná o prostý SELECT s klauzulí WHERE.
V druhé variantě musíme získat první a poslední rok měření, nominální mzdu a přepočetnou mzdu pro všchna odvětví. Toho je dosaženo pomocí funkce FIRST_VALUE.

###Odpověď: 
  
Existují jednotlivé roky, ve kterých nominální nebo přepočetná mzda výrazně klesá, zejména pak roky 2008-2010 (nejspíše důsledkem finanční krize) a 
také roky 2013 a 2014.
Za zmínku stojí odvětví Administrativní a podpůrné činnosti v letech 2013/2014,
Peněžnictví a pojišťovnictví v období po finanční krizi v roce 2008,
Těžba a dobývání zaznamenávají prudký pokles v období 2013 - 2016.
Celkově však mzdy mají rostoucí trend a neexistuje odvětví, které by za měřené období nezaznamenalo celkový nárůst.
   
##2. Otázka: Kolik je možné si koupit litrů mléka a kilogramů chleba za první a poslední srovnatelné období v dostupných datech cen a mezd?

###Provedení dotazu:

Jednoduchý výpočet v závislosti na výši nominálních mezd a průměrných cen.

###Odpověď:

Odpovědi lze najít pro každé odvětví zvlášť ve výsledku dotazu.

##3. Otázka: Která kategorie potravin zdražuje nejpomaleji (je u ní nejnižší percentuální meziroční nárůst)?

###Provedení dotazu:

Analogicky jako u 1. otázky existují 2 varianty v závislosti na měřeném období.
V první variantě je pro výběr použita funkce RANK ve vnořeném SELECTu a WHERE filtr.
V druhé variantě je použitý analogický postup jako v 1. otázce.
V obou variantých je zakomentována možnost filtrovat pouze pro nárůst cen (nepočítáme pokles).

###Odpověď:

Odpověď pro 1. variantu lze získat po provedení dotazu pro každý rok zvlášť.
Celkově největší pokles cen zaznamenal cukr krystalový.
Celkově nejmenší nárůst cen zaznamenaly banány žluté.

##4. Otázka: Existuje rok, ve kterém je rozdíl mezi růstem průměrných cen potravin a mezd vyšší než 10 procent?

###Provedení dotazu:

Zde je nejdříve nutné spočítat průměrnou všech nominálních mezd a cen potravin, aby bylo možné spočítat jejich změnu.
Toho je dosaženo pomocí funkcí AVG a LAG.

###Odpověď:

V roce 2009 je rozdíl mezi růstem průměrné nominální mzdy a poklesem průměrných cen potravin 10,42 procent.
   
##5. Otázka: Má výška HDP vliv na změny ve mzdách a cenách potravin? Neboli, pokud HDP vzroste výrazněji v jednom roce,
projeví se to na cenách potravin či mzdách ve stejném nebo následujícím roce výraznějším růstem?

###Provedení dotazu: 

Podobně jako u předchozí otázky je nejdříve nutné spočítat průměrnou nominální mzdu průmerné ceny, aby bylo možné dopočítat jejich meziroční změnu.
Protože nemáme dostupné průměrné hodnoty mezd a cen, nemůžeme spočítat jejich změnu pro rok 2006.
Poté následuje spojení se sekundární tabulkou, pomocí které lze dopočítat růst HDP v Česku.

###Odpověď:

Existuje vztah mezi změnou HDP a změnou mezd, mzdy typciky následují vývoj HDP se spožděním do 1 roku.
Vztah mezi změnou HDP a změnou cen není tak jasný, ale cney obecně následují vývoj HDP se spožděním 1 (období 2008 až 2010) až 3 (období 2012 až 2017) let.
