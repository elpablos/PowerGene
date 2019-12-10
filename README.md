# PowerGene
(Power)shell (Gene)rátor je jednoduchá modulární aplikace, která usnadňuje volání powershellových skriptů zejména vizualizací dat a zjednodušeným provoláním dilčích skriptů přímo nad zobrazenými daty ať už formou kontextové nabídky, toolbaru či tlačítek.

Jednotlivé akce jsou konfigurovatelné "zvenčí" pomocí json soubor.

PowerGene nově zavádí novou souborovou koncovku *.pwgen.

# Požadavky

 - Windows 10 (pravděpodobně půjde i na nižších Windows ale netestováno)
 - Powershell 5.1 (je součástí Windows 10)
 - .NET framework 4.7.2

# Instalace

1) Stáhnout si aktuální release
 - https://github.com/elpablos/PowerGene/releases
 
2) Odblokování exe/dll
 - Windows někdy označí soubory jako nebezpečné, je nutné je odblokovat
 - pr. tl. na PowerGene.App (a i moduly), vlastnosti a úplně dole je "odblokovat"
 
3) Instalace modulů
 - modul se aktivuje pouhým překopírováním do adresáře s aplikací PowerGene.App
 - lze využít i podadresáře (např. složka Modules)
 
4) Nastavení powershellu na Unrestricted
 - PowerShell má expicitně zakázané volání "neznámých" skriptů, protože je to potenciálně nebezpečné
 - nejjednodušší způsob je si nastavit ExecutionPolicy na Unrestricted
 - zde je seznam příkazů:

```
Get-ExecutionPolicy -List
Set-ExecutionPolicy -ExecutionPolicy Unrestricted -Scope CurrentUser
Set-ExecutionPolicy -ExecutionPolicy Unrestricted -Scope LocalMachine
```

5) asociace s *.pwgen koncovkou
 - před spárováním doporučuji uložit složku PowerGene na nějaké "rozumné" místo
 - Windows si pak tuto lokaci pamatuji a zde hledá něco, čím by otevřel *.pwgen soubor
 - Doporučené:
   - Program Files
   - Vlastní adresářová struktura pro prográmky
 - Nedoporučené:
   - Plocha
   - Dokumenty
   - Externí disk, atd.
   
6) První spuštění
 - V tomto bodě by měl jít spustit program PowerGene.App
 - měla by naběhnout obrazovka se základní konfigurací (template.pwgen) a přidanými moduly

7) Moduly
 - pokud aplikace obsabuje tyto taby:
  - Items - byl načten modul "PowerGene.Module.ItemList"
  - Tables, Views, Procedures, Functions - byl načten modul "PowerGene.Module.MsSQL"
  
8) Test
 - pro začátek doporučuji stáhnout "ProcessesExample.zip" z "releases"
 - https://github.com/elpablos/PowerGene/releases
 - ve složce "Processes" je soubor "Processes.pwgen"
 - otevřít double-clickem, pokud je koncovka zasociována anebo drag&drop do app
 - Processes pracují pouze v záložce "Items"
 - Pomocí tl. "Import processes" se načtou aktuální procesy v systému
 - Double click na řádku zobrazí detail procesu
 - pr. tl. zobrazí kontext a nabízí např. "Stop process"
 - v toolbaru se pak nachází tlačítka jako "PowerShell ISE" či "Visual Code", které otevírají příslušné aplikace
