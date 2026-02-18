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
    
  
3. Tvorba tabulky t_martin_gabriel_project_SQL_secondary_final:

   Jednoduchý výběr potenciálně relevantních dat z tabulky economies.
