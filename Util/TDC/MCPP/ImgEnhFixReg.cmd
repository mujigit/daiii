REM ========================================================
REM   Template Version: 2.00
REM ========================================================

rem C:\System.Sav\Util\postpin\PostOOBEM.CMD

@ECHO OFF
SETLOCAL
SET APP_NAME=Windows 10 HP Image Enhancements - CPS - Insert command to PostOOBEM.cmd
SET APP_LOG=C:\System.sav\LOGS\BB\%~n0.LOG
IF NOT EXIST C:\System.sav\LOGS\BB MD C:\System.sav\LOGS\BB

ECHO ############################################################# >> %APP_LOG%
ECHO  [%DATE%]                                                     >> %APP_LOG%
ECHO  [%TIME%] Beginning of the %~nx0                              >> %APP_LOG%
ECHO ############################################################# >> %APP_LOG%

ver >> %APP_LOG%
ver | find /I "10.0.14393" >> %APP_LOG%
if errorlevel 1 echo Not RS1, skip >> %APP_LOG% & goto RESULTPASSED


REM ------------------- Script Entry ------------------------
ECHO [%TIME%] Start %APP_NAME% >>%APP_LOG%

set "regPath=HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\AppModel\StateChange\PackageList"

echo Query "%regPath%" >> %APP_LOG%
reg query "%regPath%" >> %APP_LOG%
for /F "delims=" %%R IN ('reg query "%regPath%" ^| find.exe /I "ShellExperienceHost"') do (
	echo Delete "%%R" >> %APP_LOG%
	reg delete "%%R" /f >> %APP_LOG% 2>&1
	if errorlevel 1 echo Delete registry "%%R" failed. >> %APP_LOG% & goto RESULTFAILED
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