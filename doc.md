Tento dokument obsahuje popis mezivýsledků a odpovědi na výzkumné otázky ze zadání Projektu SQL.



# Popis tvorby tabulek:

Před vytvořením tabulky t_martin_gabriel_project_SQL_primary_final byly vytvořené dva pohledy:

  1. v_martin_gabriel_czechia_price_joined
  2. v_martin_gabriel_czechia_payroll_joined

### Účel vytvořených pohledů:

  - propojení sloupců s kódy v tabulkách czechia_payroll a czechia_price s jejich významem uchovaným v číselníkových tabulkách,
  - rozdělení záznamu mezd na fyzické (nominální) a přepočtené (full-time equivalent / FTE),
  - výpočtu meziročních změn mezd v odvětvích,
  - výpočtu meziročních změn cen kategorií potravin.


## 1. Vytvoření tabulky t_martin_gabriel_project_SQL_primary_final:

   ### 1.1. Vytvoření pohledu v_martin_gabriel_czechia_price_joined
   Nejprve je pomocí agregační funkce AVG vypočtena průměrná cena jednotlivých kategorií potravin za daný rok. Tyto hodnoty jsou následně propojeny s číselníkovými tabulkami, aby byly doplněny informace o jednotkách.

Pomocí analytické funkce LAG je následně spočten meziroční vývoj cen. Výsledné procentuální změny jsou zaokrouhleny na jedno desetinné místo.

   ### 1.2. Vytvoření pohledu v_martin_gabriel_czechia_payroll_joined
   
   Stejně jako v předchozím případě dochází nejprve k propojení kódů s číselníkovými tabulkami.

Pomocí konstrukce CASE a agregační funkce MAX jsou hodnoty mezd rozděleny do dvou sloupců podle hodnoty cpc.code, která odpovídá calculation_code z tabulky czechia_payroll.

Filtr cp.value_type_code = 5958 zajišťuje, že zůstávají pouze údaje o mzdách

    
## 2. Vytvoření tabulky t_martin_gabriel_project_SQL_secondary_final:

   Tabulka vznikla jednoduchým výběrem potenciálně relevantních dat z tabulky economies. Obsahuje zejména údaje o HDP, které jsou dále využity při analýze vztahu mezi vývojem ekonomiky, mezd a cen.



# Popis tvorby dotazů a odpovědi na výzkumné otázky.

## 1. Otázka: Rostou v průběhu let mzdy ve všech odvětvích, nebo v některých klesají?

### Provedení dotazu: 
  
Dotaz má 2 varianty:

1.Analýza meziročního poklesu mezd pomocí jednoduchého SELECT s podmínkou WHERE.

2. Analýza celkového vývoje za celé období – zde je nutné získat první a poslední rok měření a odpovídající hodnoty nominální i přepočtené mzdy pomocí funkce FIRST_VALUE.

### Odpověď: 
  
Existují jednotlivé roky, ve kterých nominální i přepočtené mzdy výrazně klesají, zejména období 2008–2010 (pravděpodobně v důsledku globální finanční krize, např. po pádu banky Lehman Brothers) a také roky 2013 a 2014.

Výraznější pokles byl zaznamenán například:

- v odvětví Administrativní a podpůrné činnosti (2013–2014),
- v odvětví Peněžnictví a pojišťovnictví po finanční krizi roku 2008.
- v odvětví Těžba a dobývání (2013–2016).

Celkově však mzdy vykazují dlouhodobě rostoucí trend a neexistuje odvětví, které by za celé sledované období nezaznamenalo celkový nárůst.
   
## 2. Otázka: Kolik je možné si koupit litrů mléka a kilogramů chleba za první a poslední srovnatelné období v dostupných datech cen a mezd?

### Provedení dotazu:

Výpočet je proveden jako podíl nominální mzdy a průměrné ceny konkrétní potraviny v daném roce.

### Odpověď:

Konkrétní hodnoty jsou uvedeny ve výsledku dotazu pro jednotlivá odvětví. Obecně lze pozorovat, že kupní síla v odvětví v průběhu času vzrostla.

## 3. Otázka: Která kategorie potravin zdražuje nejpomaleji (je u ní nejnižší percentuální meziroční nárůst)?

### Provedení dotazu:

Opět existují dvě varianty:

1. Výběr nejnižšího meziročního nárůstu pomocí funkce RANK ve vnořeném dotazu.
2. Výpočet změny mezi prvním a posledním rokem sledovaného období.

V obou variantách je možné filtrovat pouze kladné meziroční změny (ignorovat pokles).

### Odpověď:

Odpověď pro 1. variantu lze získat po provedení dotazu pro každý rok zvlášť.

Celkově největší pokles cen zaznamenal cukr krystalový.
Celkově nejmenší nárůst cen zaznamenaly banány žluté.

## 4. Otázka: Existuje rok, ve kterém je rozdíl mezi růstem průměrných cen potravin a mezd vyšší než 10 procent?

### Provedení dotazu:

Zde je nejdříve nutné spočítat průměrnou všech nominálních mezd a cen potravin, aby bylo možné spočítat jejich změnu.
Toho je dosaženo pomocí funkcí AVG a LAG.

### Odpověď:

V roce 2009 je rozdíl mezi růstem průměrné nominální mzdy a poklesem průměrných cen potravin 10,42 procent.
   
## 5. Otázka: Má výška HDP vliv na změny ve mzdách a cenách potravin? Neboli, pokud HDP vzroste výrazněji v jednom roce,
projeví se to na cenách potravin či mzdách ve stejném nebo následujícím roce výraznějším růstem?

### Provedení dotazu: 

Podobně jako u předchozí otázky je nejdříve nutné spočítat průměrnou nominální mzdu průmerné ceny, aby bylo možné dopočítat jejich meziroční změnu.
Protože nemáme dostupné průměrné hodnoty mezd a cen, nemůžeme spočítat jejich změnu pro rok 2006.
Poté následuje spojení se sekundární tabulkou, pomocí které lze dopočítat růst HDP v Česku.

### Odpověď:

Existuje vztah mezi změnou HDP a změnou mezd, mzdy typciky následují vývoj HDP se spožděním do 1 roku.
Vztah mezi změnou HDP a změnou cen není tak jasný, ale cney obecně následují vývoj HDP se spožděním 1 (období 2008 až 2010) až 3 (období 2012 až 2017) let.
