REM ========================================================
REM   P2PP execution file for PostLast
REM 
REM   Template Version: V1.00
REM ========================================================

@ECHO OFF
SETLOCAL
SET APP_NAME=TFS - Windows 10 HP Image Enhancements - TDC - Last Clean
SET APP_LOG=C:\System.sav\LOGS\BB\%~n0.LOG
IF NOT EXIST C:\System.sav\LOGS\BB MD C:\System.sav\LOGS\BB

ECHO ############################################################# >> %APP_LOG%
ECHO  [%DATE%]                                                     >> %APP_LOG%
ECHO  [%TIME%] Beginning of the %~nx0                              >> %APP_LOG%
ECHO ############################################################# >> %APP_LOG%

REM ------------------- Script Entry ------------------------
ECHO [%TIME%] Start %APP_NAME% >>%APP_LOG%

REM ------------------- Script Entry ------------------------
echo Start to remove folders which [DeleteThese] failed >>%APP_LOG%
for /f "delims=" %%i in (%~dp0DELETE.LST) do (
   echo Remove %%i folder >>%APP_LOG%
   RD /S /Q %%i >>%APP_LOG% 2>>&1
)

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