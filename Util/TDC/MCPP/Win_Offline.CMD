REM ========================================================
REM   Template Version: 2.00
REM ========================================================

@ECHO OFF
SETLOCAL
SET APP_NAME=Windows 10 HP Image Enhancements - CPS - Driver Install for Windows 10 Offline
SET APP_LOG=C:\System.sav\LOGS\BB\%~n0.LOG
IF NOT EXIST C:\System.sav\LOGS\BB MD C:\System.sav\LOGS\BB

ECHO ############################################################# >> %APP_LOG%
ECHO  [%DATE%]                                                     >> %APP_LOG%
ECHO  [%TIME%] Beginning of the %~nx0                              >> %APP_LOG%
ECHO ############################################################# >> %APP_LOG%

REM ------------------- Script Entry ------------------------
ECHO [%TIME%] Start %APP_NAME% >>%APP_LOG%

:Detection
Set DriverPath=
for /f "delims=" %%i in ('dir /ad /b C:\System.sav\Win_Offline') do (
    if exist "C:\System.sav\flags\%%~i???.flg" if exist "C:\System.sav\flags\HAL64.flg" if exist C:\System.sav\Win_Offline\%%~i\x64 Set DriverPath=C:\System.sav\Win_Offline\%%~i\x64
    if exist "C:\System.sav\flags\%%~i???.flg" if exist "C:\System.sav\flags\HAL32.flg" if exist C:\System.sav\Win_Offline\%%~i\x86 Set DriverPath=C:\System.sav\Win_Offline\%%~i\x86
)
if not defined DriverPath echo No Windows offline driver found. >>%APP_LOG% & GOTO RESULTPASSED

:Install
for /f "delims=" %%i in ('dir /ad /b "%DriverPath%"') do (
	echo [%TIME%] Offline install %DriverPath%\%%~i driver to Windows >>%APP_LOG%
	Dism.exe /image:C:\ /Add-Driver /driver:"%DriverPath%\%%~i" >>%APP_LOG%
	echo [%TIME%] Errorlevel=%errorlevel% >>%APP_LOG%
	if errorlevel 1 ECHO RESULT=FAILED >>%APP_LOG%
)
goto RESULTPASSED

:RESULTPASSED
ECHO [%TIME%] Result of the %APP_NAME% >> %APP_LOG%
ECHO RESULT=PASSED >> %APP_LOG%
GOTO END

:RESULTFAILED
IF EXIST X:\windows\Logs\DISM\dism.log copy.exe /y X:\windows\Logs\DISM\dism.log C:\System.sav\LOGS\WinPE_DRV_DISM.LOG
ECHO [%TIME%] Result of the %APP_NAME% >> %APP_LOG%
ECHO RESULT=FAILED >> %APP_LOG%
GOTO END

:END
ENDLOCAL
@ECHO ON
