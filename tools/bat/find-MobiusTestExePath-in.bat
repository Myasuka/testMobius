@echo off
rem input parent/ancestor directory, and out MobiusTestExePath MobiusTestExeDir MobiusTestExeName
if "%~1" == "" (
    echo Should input test exe's parent/ancestor directory! quit %0 
    exit /b 5
)

if not [%MobiusTestJarPath%] == [] (
    for %%a in ( %MobiusTestJarPath% ) do ( 
        set MobiusTestJarDir=%%~dpa
        set MobiusTestJarName=%%~nxa
    )
    if not [!MobiusTestJarDir!] == [] if !MobiusTestJarDir:~-1!==\ set "MobiusTestJarDir=!MobiusTestJarDir:~0,-1!"
)

if [%MobiusTestExePath%]==[] for /f %%g in (' for /R %1 %%f in ^( *.exe ^) do @echo %%f ^| findstr /I /C:vshost /V ^| findstr /I /C:obj /V ') do set MobiusTestExePath=%%g
if not [%MobiusTestExePath%] == [] (
    for %%a in ( %MobiusTestExePath% ) do set "MobiusTestExeDir=%%~dpa"
    if not [!MobiusTestExeDir!] == [] if !MobiusTestExeDir:~-1!==\ set "MobiusTestExeDir=!MobiusTestExeDir:~0,-1!"
    for %%a in ( %MobiusTestExePath% ) do set "MobiusTestExeName=%%~nxa"
)
