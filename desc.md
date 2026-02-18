Tento dokument obsahuje popis mezivýsledků a odpovědi na výzkumné otázky ze zadání Projektu SQL.

Popis tvorby tabulek:

Před vytvořením tabulky t_martin_gabriel_project_SQL_primary_final je byly vytvořené dva pohledy:
  1. v_martin_gabriel_czechia_price_joined
  2. v_martin_gabriel_czechia_payroll_joined

Tyto pohledy slouží k zejména k propojení sloupců s kódy v tabulkách czechia_payroll a czechia_price s jejich významem uchovaným v číselníkových tabulkách,
rozdělení záznamu mezd na fyzické (nominální) a přepočetné (full-time equivalent / fte),
výpočtu meziročních změn mezd v odvětvích a výpočtu mezročních změn cen kategorií potravin.

1. Tvorba tabulky t_martin_gabriel_project_SQL_primary_final:

   1.1. Vytvoření pohledu v_martin_gabriel_czechia_price_joined
     Nejdříve je nutné vypočítat průměrnou cenu kategorie potravin za daný rok pomocí funkce AVG a propojit s informacemi o jednotkách v číselníkových tabulkách.
     Dále je z těchto půměrů vytvořen záznam o meziročním vývoji cen pomocí funkce LAG. Hodnoty jsou zaokrouhleny desetinny procent.

   1.2. Vytvoření pohledu v_martin_gabriel_czechia_payroll_joined
     Nejdříve se propojí hodnoty kódů s číslníkovými tabukami analogicky s tvorbou předchozího pohledu.
     Dále je zde je použit "trik" na rozdělení záznamu o mzdách pomocí CASE a agregační funkce MAX. Efektivně se tak vytvoří 2 sloupce z jednoho v závislosti na
     hodnotě cpc.code, která odpovídá hodnotě calculation_code z tabulky czechia_payroll.
     Je zde použito filtrování pomocí cp.value_type_code = 5958, což nám zanechá pouze informace o mzdách.
    
  
2. Tvorba tabulky t_martin_gabriel_project_SQL_secondary_final:

   Jednoduchý výběr potenciálně relevantních dat z tabulky economies.
