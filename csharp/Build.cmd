@echo off
SetLocal EnableDelayedExpansion

echo Usage   : %0  BuildConfig{none^|Debug^|Release}  CppDll{none^|nocpp}
echo Example : %0  Release
if "%~1" == "-h" exit /b 0
if "%~1" == "--help" exit /b 0

set BuildConfig=%1
if "%2" == "nocpp" set CppDll=NoCpp

SET ShellDir=%~dp0
@REM Remove trailing backslash \
IF %ShellDir:~-1%==\ SET ShellDir=%ShellDir:~0,-1%
set PROJ_NAME=allSubmitingTest
set PROJ=%ShellDir%\%PROJ_NAME%.sln

call %ShellDir%\check-build-tools.bat

@REM Set msbuild location.
SET VisualStudioVersion=14.0
if EXIST "%VS140COMNTOOLS%" SET VisualStudioVersion=14.0

@REM Set Build OS
if not defined CppDll SET CppDll=HasCpp
SET VCBuildTool="%VS120COMNTOOLS:~0,-14%VC\bin\cl.exe"
if EXIST "%VS140COMNTOOLS%" SET VCBuildTool="%VS140COMNTOOLS:~0,-14%VC\bin\cl.exe"
if NOT EXIST %VCBuildTool% SET CppDll=NoCpp


SET MSBUILDEXEDIR=%programfiles(x86)%\MSBuild\%VisualStudioVersion%\Bin
if NOT EXIST "%MSBUILDEXEDIR%\." SET MSBUILDEXEDIR=%programfiles%\MSBuild\%VisualStudioVersion%\Bin
if NOT EXIST "%MSBUILDEXEDIR%\." GOTO :ErrorMSBUILD

SET MSBUILDEXE=%MSBUILDEXEDIR%\MSBuild.exe
SET MSBUILDOPT=/verbosity:minimal /p:WarningLevel=3

if "%builduri%" == "" set builduri=Build.cmd

cd /d "%ShellDir%"

@echo ===== Building %PROJ% =====

@echo Restore NuGet packages ===================
SET STEP=NuGet-Restore

nuget restore "%PROJ%"

@if ERRORLEVEL 1 GOTO :ErrorStop

if "%BuildConfig%" == "" set BuildDebug=1
if not "%BuildConfig%" == "" if /I "%BuildConfig%" == "Debug" set BuildDebug=1
if "%BuildDebug%" == "1" call :BuildByConfig Debug

if "%BuildConfig%" == "" set BuildRelease=1
if not "%BuildConfig%" == "" if /I "%BuildConfig%" == "Release" set BuildRelease=1
if "%BuildRelease%" == "1" call :BuildByConfig Release

if EXIST %PROJ_NAME%.nuspec (
  @echo ===== Build NuGet package for %PROJ% =====
  SET STEP=NuGet-Pack

  powershell -f %ShellDir%\..\build\localmode\nugetpack.ps1
  @if ERRORLEVEL 1 GOTO :ErrorStop
  @echo NuGet package ok for %PROJ%
)

@echo ===== Build succeeded for %PROJ% =====

@GOTO :EOF

:BuildByConfig
	SET Configuration=%1
	@echo Build %Configuration% ============================
	"%MSBUILDEXE%" /p:Configuration=%Configuration%;AllowUnsafeBlocks=true %MSBUILDOPT% "%PROJ%"
	@if ERRORLEVEL 1 GOTO :ErrorStop
	@echo BUILD ok for %Configuration% %PROJ%
	goto :EOF

:ErrorMSBUILD
	set RC=1
	@echo ===== Build FAILED due to missing MSBUILD.EXE. =====
	@echo ===== Mobius requires "Developer Command Prompt for VS2013" and above =====
	exit /B %RC%

:ErrorStop
	set RC=%ERRORLEVEL%
	if "%STEP%" == "" set STEP=%CONFIGURATION%
	@echo ===== Build FAILED for %PROJ% -- %STEP% with error %RC% - CANNOT CONTINUE =====
	exit /B %RC%
	
:EOF