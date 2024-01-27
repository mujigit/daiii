REM ========================================================
REM   Template Version: 2.00
REM   WinPE online drvload
REM ========================================================

@ECHO OFF
SETLOCAL
SET APP_NAME=Windows 10 HP Image Enhancements - CPS - Online Driver Install for WinPE
SET APP_LOG=%~dp0%~n0.LOG

ECHO ############################################################# >> %APP_LOG%
ECHO  [%DATE%]                                                     >> %APP_LOG%
ECHO  [%TIME%] Beginning of the %~nx0                              >> %APP_LOG%
ECHO ############################################################# >> %APP_LOG%

REM ------------------- Script Entry ------------------------
ECHO [%TIME%] Start %APP_NAME% >>%APP_LOG%

:Initial
echo [%TIME%] wpeinit.exe >>%APP_LOG%
wpeinit.exe
echo [%TIME%] Errorlevel=%errorlevel% >>%APP_LOG%

for /f "tokens=1,2 delims==" %%i in ('Wmic.exe /namespace:\\root\cimv2 path Win32_BaseBoard get Product /value') do (if /i %%~i == Product set "SystemId=%%~j")
if not defined SystemId echo Unknow System Id >> %APP_LOG% & goto RESULTFAILED
echo System Id=[%SystemId%] >>%APP_LOG%

:DrvInst
set "drvInstErr=FALSE"
pushd "%~dp0"
for /f "delims=" %%i in ('dir /ad /b "*"') do (
	echo [%TIME%] Found "%%~i", checking %SystemId% in sysid.txt. >>%APP_LOG%
	pushd "%%~i"
	if not exist "sysid.txt" ( 
			echo No sysid.txt, online drvload folder. >>%APP_LOG%
			call :DrvloadFldr
	) else (
		find /i "%SystemId%" "sysid.txt" >nul 2>&1
		if not errorlevel 1 (
			echo SysId matched, online drvload folder. >>%APP_LOG%
			call :DrvloadFldr
		) else ( 
			echo SysId mismatch.>>%APP_LOG% 
		)
	)
	popd
)
popd

if /I "%drvInstErr%"=="TRUE" goto RESULTFAILED
GOTO RESULTPASSED

:RESULTPASSED
ECHO [%TIME%] Result of the %APP_NAME% >> %APP_LOG%
ECHO RESULT=PASSED >> %APP_LOG%
GOTO END

:RESULTFAILED
ECHO [%TIME%] Result of the %APP_NAME% >> %APP_LOG%
ECHO RESULT=FAILED >> %APP_LOG%
GOTO END

:DrvloadFldr
for /f "delims=" %%i in ('dir /a-d /b /s "*.inf"') do (
	echo drvload.exe "%%~i" >>%APP_LOG%
	drvload.exe "%%~i" >>%APP_LOG% 2>&1
	if Errorlevel 1 set "drvInstErr=TRUE" & echo RESULT=FAILED >>%APP_LOG%
)
exit /b 0


:END
if exist C:\System.sav\Logs\BB type "%APP_LOG%" >> C:\System.sav\Logs\BB\%~n0.LOG
ENDLOCAL
@ECHO ON
