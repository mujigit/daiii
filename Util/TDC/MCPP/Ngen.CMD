REM ========================================================
REM   Template Version: 2.00
REM ========================================================

@ECHO OFF
SETLOCAL
SET APP_NAME=TFS - Windows 10 HP Image Enhancements - TDC - ngen.exe to improve performance
SET APP_LOG=C:\System.sav\LOGS\BB\%~n0.LOG
IF NOT EXIST C:\System.sav\LOGS\BB MD C:\System.sav\LOGS\BB

ECHO ############################################################# >> %APP_LOG%
ECHO  [%DATE%]                                                     >> %APP_LOG%
ECHO  [%TIME%] Beginning of the %~nx0                              >> %APP_LOG%
ECHO ############################################################# >> %APP_LOG%

REM ------------------- Script Entry ------------------------
ECHO [%TIME%] Start %APP_NAME% >>%APP_LOG%

:Install
if exist C:\System.sav\flags\HAL64.flg (
    if exist %windir%\Microsoft.NET\Framework\v4.0.30319\ngen.exe (
		echo Run %windir%\Microsoft.NET\Framework\v4.0.30319\ngen.exe update /queue >> %APP_LOG%
	    start /w %windir%\Microsoft.NET\Framework\v4.0.30319\ngen.exe update /queue
		if errorlevel 1 goto RESULTFAILED
		echo Run %windir%\Microsoft.NET\Framework\v4.0.30319\ngen.exe eqi >> %APP_LOG%
        start /w %windir%\Microsoft.NET\Framework\v4.0.30319\ngen.exe eqi
		if errorlevel 1 goto RESULTFAILED
	)
    if exist %windir%\Microsoft.NET\Framework64\v4.0.30319\ngen.exe (
		echo Run %windir%\Microsoft.NET\Framework64\v4.0.30319\ngen.exe update /queue >> %APP_LOG%
		start /w %windir%\Microsoft.NET\Framework64\v4.0.30319\ngen.exe update /queue
		if errorlevel 1 goto RESULTFAILED
		echo Run %windir%\Microsoft.NET\Framework64\v4.0.30319\ngen.exe eqi >> %APP_LOG%
		start /w %windir%\Microsoft.NET\Framework64\v4.0.30319\ngen.exe eqi
		if errorlevel 1 goto RESULTFAILED
	)
)
if exist C:\System.sav\flags\HAL32.flg (
    if exist %windir%\Microsoft.NET\Framework\v4.0.30319\ngen.exe (
		echo Run %windir%\Microsoft.NET\Framework\v4.0.30319\ngen.exe update /queue >> %APP_LOG%
		start /w %windir%\Microsoft.NET\Framework\v4.0.30319\ngen.exe update /queue
		if errorlevel 1 goto RESULTFAILED
		echo Run %windir%\Microsoft.NET\Framework\v4.0.30319\ngen.exe eqi >> %APP_LOG%
		start /w %windir%\Microsoft.NET\Framework\v4.0.30319\ngen.exe eqi
		if errorlevel 1 goto RESULTFAILED
	)
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
