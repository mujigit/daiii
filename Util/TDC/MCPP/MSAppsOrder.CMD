REM ========================================================
REM   Template Version: 2.00
REM ========================================================

@ECHO OFF
SETLOCAL ENABLEDELAYEDEXPANSION
SET APP_NAME=TFS - Windows 10 HP Image Enhancements - TDC - MS APPs with WinJS Installation Sequence Reset
SET APP_LOG=C:\System.sav\LOGS\BB\%~n0.LOG
IF NOT EXIST C:\System.sav\LOGS\BB MD C:\System.sav\LOGS\BB

ECHO ############################################################# >> %APP_LOG%
ECHO  [%DATE%]                                                     >> %APP_LOG%
ECHO  [%TIME%] Beginning of the %~nx0                              >> %APP_LOG%
ECHO ############################################################# >> %APP_LOG%

REM ------------------- Script Entry ------------------------
ECHO --- Start Reset Process --- >> %APP_LOG%
if exist C:\System.sav\LOGS\winjsapps.lst del /f /q C:\System.sav\LOGS\winjsapps.lst
for /f "delims=" %%i in ('dir /s /ad /b c:\SWSetup\APP\Microsoft.WinJS.*') do (
	echo %%~nxi,%%~dpi>>C:\System.sav\LOGS\winjsapps.lst
	c:\windows\system32\sort.exe C:\System.sav\LOGS\winjsapps.lst /o C:\System.sav\LOGS\winjsapps.lst
)
if not exist C:\System.sav\LOGS\winjsapps.lst echo No APPs supports WinJS. >> %APP_LOG% & goto RESULTPASSED
Set /a Order=0
for /f "tokens=1,2 delims=," %%a in (C:\System.sav\LOGS\winjsapps.lst) do (
	echo Search %%b..\..\P???????.BTO >> %APP_LOG%
	for /f "delims=" %%i in ('dir /a-d /b /s ^"%%b..\..\P???????.BTO^"') do ( 
	    echo Found %%~i >> %APP_LOG%
		for /f "delims=" %%x in ('dir /s /a-d /b ^"c:\appl.zip\%%~nxi^"') do ( 
		    echo Move %%~x to c:\appl.zip\install2\_!Order!_%%~nxi >> %APP_LOG%
			if not exist c:\appl.zip\install2 echo Create c:\appl.zip\install2 folder. >> %APP_LOG% & md c:\appl.zip\install2
			move /y "%%~x" "c:\appl.zip\install2\_!Order!_%%~nxi" >> %APP_LOG%
			if not exist c:\appl.zip\install2\_!Order!_%%~nxi echo Failed to move %%~nxx file. >> %APP_LOG% & goto RESULTFAILED
			set /a Order+=1
		)
	)
)
echo Order=!Order! >> %APP_LOG%
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
