REM ========================================================
REM   Template Version: 2.00
REM ========================================================

@ECHO OFF
SETLOCAL
SET APP_NAME=TFS - Windows 10 HP Image Enhancements - TDC - TDC - CPU Flag
SET APP_LOG=C:\System.sav\LOGS\BB\%~n0.LOG
IF NOT EXIST C:\System.sav\LOGS\BB MD C:\System.sav\LOGS\BB

ECHO ############################################################# >> %APP_LOG%
ECHO  [%DATE%]                                                     >> %APP_LOG%
ECHO  [%TIME%] Beginning of the %~nx0                              >> %APP_LOG%
ECHO ############################################################# >> %APP_LOG%

REM ------------------- Script Entry ------------------------
ECHO [%TIME%] Start %APP_NAME% >>%APP_LOG%

:Install
for /f "tokens=1,2 delims== " %%i in ('wmic /namespace:\\root\cimv2 path Win32_Processor get Manufacturer /value') do ( if /i %%~i == Manufacturer set CPU=%%~j )
if not defined CPU echo Could not found CPU Manufacturer. >> %APP_LOG% & goto RESULTPASSED
echo CPU=%CPU% >> %APP_LOG%
if /i %CPU% == GenuineIntel echo. >> C:\System.sav\flags\Intel.flg
if /i %CPU% == AuthenticAMD echo. >> C:\System.sav\flags\AMD.flg
GOTO RESULTPASSED

:RESULTPASSED
ECHO [%TIME%] Result of the %APP_NAME% >> %APP_LOG%
ECHO RESULT=PASSED >> %APP_LOG%
GOTO END

:RESULTFAILED
ECHO [%TIME%] Result of the %APP_NAME% >> %APP_LOG%
ECHO RESULT=FAILED >> %APP_LOG%
ECHO ERRORLEVEL=%errorlevel% >> %APP_LOG%
GOTO END


:END
ENDLOCAL
@ECHO ON
