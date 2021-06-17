::Author: @bugsam
::Action: List data files from outlook
::Version: 1.0
::Date: 14 May, 2013
@echo off
C:
set rdm=%random%
cd "%appdata%\OFDList\"
echo %date% > %rdm%date.txt
copy /y %rdm%date.txt %rdm%date2.txt > null
sed "s,/,_,g" %rdm%date2.txt > %rdm%date.txt
sed -e "s/.*/set dated=&/" %rdm%date.txt > %rdm%date.bat
call "%rdm%date.bat"
echo %time% > %rdm%time.txt
sed s/.\{7\}$// %rdm%time.txt > %rdm%time2.txt
sed "s,:,_,g"; %rdm%time2.txt > %rdm%time.txt
sed -e "s/.*/set timet=&/" %rdm%time.txt > %rdm%time.bat
call "%rdm%time.bat"

set datetime=%dated%%timet%

reg query HKCU\Software\Microsoft\Office\12.0\Outlook\Catalog > %rdm%query.txt
if errorlevel == 0 (set errorlv07=0)
if errorlevel == 1 (set errorlv07=1)
if errorlevel == 2 (set errorlv07=2)
if errorlevel == 3 (set errorlv07=3)
if errorlevel == 4 (set errorlv07=4)
if errorlevel == 5 (set errorlv07=5)
if %errorlv07% EQU 0 (goto Outlook07)

reg query HKCU\Software\Microsoft\Office\14.0\Outlook\Search\Catalog > %rdm%query.txt
if errorlevel == 0 (set errorlv10=0)
if errorlevel == 1 (set errorlv10=1)
if errorlevel == 2 (set errorlv10=2)
if errorlevel == 3 (set errorlv10=3)
if errorlevel == 4 (set errorlv10=4)
if errorlevel == 5 (set errorlv10=5)
if %errorlv10% EQU 0 (goto Outlook10)

if %errorlv07% NEQ 0 if %errorlv10% NEQ 0 (echo "%username% %computername% %time% %date% NOT FOUND ANY OUTLOOK" > "S:\%username%%datetime%error.txt" && goto erro)

:bof
:: Remove valores DWORD
sed s/.\{32\}$// %rdm%query3.txt > %rdm%query4.txt
::Remove linhas em branco
sed /./,/^$/!d  %rdm%query4.txt > %rdm%query5.txt
::Remove 4 caracteres em branco no inicio da linha
sed s/.\{4\}// %rdm%query5.txt > %rdm%query6.txt

::remove 2 caracteres do fim da linha
sed s/.\{2\}$// %rdm%query6.txt > %rdm%query7.txt

sed -e "s/.*/set line=&/" %rdm%query7.txt > %rdm%query7_1.txt
::insere argumento de line
sed -e "s/.*/set line=&/" %rdm%query7.txt > %rdm%query8.txt


::conta linhas
sed -n $= %rdm%query8.txt > %rdm%rule.txt
::insere argumento set/a no inicio da linha
sed -e "s/.*/set \/a rule=&/" %rdm%rule.txt > %rdm%rule2.txt
copy %rdm%rule2.txt %rdm%rule2.bat /y > null

set /a count=0
call "%rdm%rule2.bat"

copy /y %rdm%query7.txt %rdm%result.txt > null
:decisao
set /a count=%count%+1
sed -n %count%p %rdm%query8.txt > %rdm%next.bat
call "%rdm%next.bat"
for %%I in ("%line%") do set size=" %%~zI"
if %count% GTR %rule% (goto eof) else (sed %count%"s"/$/_#_%size%/ %rdm%result.txt > %rdm%result2.txt
copy /y %rdm%result2.txt %rdm%result.txt > null
del %rdm%result2.txt)
goto decisao

goto eof
:Outlook07
:: Remove path do registro HCU
sed -e s/HKEY_CURRENT_USER\\Software\\Microsoft\\Office\\12.0\\Outlook\\Catalog//g; %rdm%query.txt > %rdm%query3.txt
goto bof

:Outlook10
:: Remove path do registro HCU
sed -e s/HKEY_CURRENT_USER\\Software\\Microsoft\\Office\\14.0\\Outlook\\Search\\Catalog//g; %rdm%query.txt > %rdm%query3.txt
goto bof

:eof
@echo.
sed /./,/^$/!d  %rdm%result.txt > %rdm%result3.txt
sed -e "s/.*/%computername%_$_%username%_$_&/" %rdm%result3.txt > %rdm%result.txt
copy /Y "%rdm%result.txt" "S:\%computername%_%username%_%datetime%.txt" > null

:erro
del %appdata%\OFDList /Q
net use s: /delete
exit
