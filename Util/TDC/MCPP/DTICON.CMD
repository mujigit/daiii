REM ========================================================
REM   Template Version: 2.00
REM ========================================================

@ECHO OFF
SETLOCAL
SET APP_NAME=TFS - Windows 10 HP Image Enhancements - TDC - DTICON
SET APP_LOG=C:\System.sav\LOGS\BB\%~n0.LOG
IF NOT EXIST C:\System.sav\LOGS\BB MD C:\System.sav\LOGS\BB

ECHO ############################################################# >> %APP_LOG%
ECHO  [%DATE%]                                                     >> %APP_LOG%
ECHO  [%TIME%] Beginning of the %~nx0                              >> %APP_LOG%
ECHO ############################################################# >> %APP_LOG%

REM ------------------- Script Entry ------------------------
:RemoveIcon
echo Remove Desktop Icon>>%APP_LOG%
echo DELINK.vbs /List="%~dp0EnhIcon.lst">>%APP_LOG%
cscript /nologo C:\SWSetup\hpImgEnh\DELINK.vbs /List="%~dp0EnhIcon.lst">>%APP_LOG%
GOTO RESULTPASSED

:RESULTPASSED
ECHO [%TIME%] Result of the %APP_NAME% >> %APP_LOG%
ECHO RESULT=PASSED >> %APP_LOG%
GOTO END

:RESULTFAILED
ECHO [%TIME%] Result of the %APP_NAME% >> %APP_LOG%
ECHO RESULT=FAILED >> %APP_LOG%
ECHO ERRORLEVEL=%errorlevel% >> %APP_LOG%

:END
ENDLOCAL
@ECHO ON