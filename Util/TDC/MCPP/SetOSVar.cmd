@ECHO OFF
pushd "%~dp0"

set "APP_NAME=Setup OS BCU variable for Battery remaining report"
set "APP_LOG=c:\system.sav\logs\bb\%~n0.log"

set isWin10RS1=
for /f "tokens=1,2 delims==." %%i in ('wmic /namespace:"\\root\HP\InstrumentedBIOS" path HP_BIOSEnumeration where ^(name^="Win 10 RS1"^) get CurrentValue /value') do (if /i %%i == CurrentValue set "isWin10RS1=%%~j")
if not defined isWin10RS1 echo BIOS don't support variable Win 10 RS1 >> %APP_LOG% & goto RESULTPASSED
echo isWin10RS1=[%isWin10RS1%] >>%APP_LOG%

call :getmachinetype
if errorlevel 1 echo Failed to get getmachinetype & goto RESULTFAILED
call :CpuDet
if %OSBit% == x64 (set "bcutool=%~dp0BCU_%machinetype%\BiosConfigUtility_x64.exe" ) else (set "bcutool=%~dp0BCU_%machinetype%\BiosConfigUtility.exe" )
echo bcutool=[%bcutool%] >>%APP_LOG%

if exist C:\SYSTEM.SAV\Flags\W10RS1.FLG ( call :setValueToBCU RS1_Yes.txt ) else ( call :setValueToBCU RS1_No.txt )
if errorlevel 1 echo setValueToBCU failed. >>%APP_LOG% & goto RESULTFAILED
goto RESULTPASSED

REM ------------------- Script exit ------------------------

:RESULTPASSED
ECHO [%TIME%] Result of the %APP_NAME% >> %APP_LOG%
ECHO RESULT=PASSED >> %APP_LOG%
GOTO END

:RESULTFAILED
ECHO [%TIME%] Result of the %APP_NAME% >> %APP_LOG%
ECHO RESULT=FAILED >> %APP_LOG%
GOTO END

:CpuDet
for /f "tokens=1,2 delims== " %%i in ('Wmic.exe /namespace:\\root\cimv2 path Win32_OperatingSystem get OSArchitecture /value') do (if /i %%~i == OSArchitecture set OSArch=%%~j)
if not defined OSArch echo [%TIME%] Could not identify OS architecture. >> %APP_LOG% & goto fail
echo OS Architecture=%OSArch% >>%APP_LOG%
REM if /i "%OSArch%" == "64-bit" (set OSBit=x64) else (set OSBit=x86)
REM OSArchitecture can be MUI, cannot do exactly text compare, replaced by following solution
echo Assume OSBit=x64, check 86 and 32 wording >>%APP_LOG%
set OSBit=x64
echo "%OSArch%" | find /I "86" > NUL
if not errorlevel 1 set OSBit=x86
echo "%OSArch%" | find /I "32" > NUL
if not errorlevel 1 set OSBit=x86
echo No 86 and 32 wording, it's x64 >>%APP_LOG%
exit /b 0

:getmachinetype
SET dpsPath=
SET mlPrefix=
SET machinetype=
FOR /F %%a IN ('dir C:\system.sav\*_DPS /b') DO SET dpsPath=C:\system.sav\%%a
if not defined dpsPath echo dpsPath not found >>%APP_LOG% & goto RESULTFAILED
ECHO DPS File=[%dpsPath%] >>%APP_LOG%
FOR /F "tokens=2 delims==" %%a IN ('find /n /i "ML_Prefix" %dpsPath%') DO SET mlPrefix=%%a
if not defined mlPrefix echo mlPrefix not found >>%APP_LOG% & exit /b 1
ECHO mlPrefix=[%mlPrefix%] >>%APP_LOG%
if /I "%mlPrefix%"=="CNB" set "machinetype=NB"
if /I "%mlPrefix%"=="CDT" set "machinetype=DT"
if not defined machinetype echo machinetype not definded >>%APP_LOG% & exit /b 1
ECHO machinetype=[%machinetype%] >>%APP_LOG%
exit /b 0

:setValueToBCU
echo "%bcutool%" /setconfig:%1 /verbose >>%APP_LOG%
"%bcutool%" /setconfig:"%1" /verbose >>%APP_LOG% 2>&1
if errorlevel 1 echo Set Win10 RS1 with %1 failed. >>%APP_LOG% & exit /b 1
exit /b 0

:END
@ECHO ON
popd
