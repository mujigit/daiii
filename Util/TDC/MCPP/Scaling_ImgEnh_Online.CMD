REM ========================================================
REM   P2PP execution file for PININST_BBV2
REM   Another offline version in Point_D folder for PBR
REM   Template Version: V1.00
REM ========================================================

@ECHO OFF
SET APP_NAME=Windows 10 HP Image Enhancements - CPS - Scaling/DPI Setting
SET APP_LOG=C:\System.sav\LOGS\BB\%~n0.LOG
IF NOT EXIST C:\System.sav\LOGS\BB MD C:\System.sav\LOGS\BB

ECHO ############################################################# >> %APP_LOG%
ECHO  [%DATE%]                                                     >> %APP_LOG%
ECHO  [%TIME%] Beginning of the %~nx0                              >> %APP_LOG%
ECHO ############################################################# >> %APP_LOG%

ECHO [%TIME%] ================ The Installation of %APP_NAME% ================ >> %APP_LOG%
ECHO [%TIME%] Item=%APP_NAME% >> %APP_LOG%

ECHO [%TIME%] Default delete c:\Recovery\OEM\Point_D\myDPI.lst >> %APP_LOG%
if exist c:\Recovery\OEM\Point_D\myDPI.lst del /f /q c:\Recovery\OEM\Point_D\myDPI.lst >> %APP_LOG% 2>&1

if not exist %~dp0dpi.lst (
	echo No %~dp0dpi.lst, skip. >> %APP_LOG%
	goto RESULTPASSED
)

REM ------------------- Script Entry ------------------------
:Detection
REM Only Intel VGA support Widi
FOR /f "tokens=1,2,3 delims=, " %%i in (%~dp0dpi.lst) DO (
	ECHO Checking System id "%%~i". >> %APP_LOG%
	set "regDpi=%%~k"
	FIND.EXE /I "SystemID=%%~i" C:\HP\BIN\RStone_BBV.INI >NUL
	IF NOT ERRORLEVEL 1 (
		ECHO System id "%%~i" matched. >> %APP_LOG%
		IF /I "%%~j"=="ALL" (
			ECHO No resolution detection. DPI request required >> %APP_LOG%
			GOTO Install
		)
		call :ChkRes %%~j
		IF NOT ERRORLEVEL 1 (
			ECHO Resolution %%~j detection matched. DPI request required >> %APP_LOG%
			GOTO Install
		) ELSE (
			ECHO Resolution %%~j detection mismatched. DPI request not required >> %APP_LOG%
		)
	) ELSE (
		ECHO System id "%%~i" mismatched. >> %APP_LOG%
	)
)
ECHO No DPI setting required. >> %APP_LOG%
GOTO RESULTPASSED

:Install
echo dpi=%regDpi%>c:\Recovery\OEM\Point_D\myDPI.lst

echo Query "HKCU\Control Panel\Desktop" >>%APP_LOG%
reg.exe query "HKCU\Control Panel\Desktop" >>%APP_LOG%
echo Set "HKCU\Control Panel\Desktop" of LogPixels=%regDpi% >>%APP_LOG%
reg.exe add "HKCU\Control Panel\Desktop" /v "LogPixels" /t REG_DWORD /d "%regDpi%" /f >>%APP_LOG% 
if errorlevel 1 echo LogPixels setting failed. >> %APP_LOG% & goto RESULTFAILED
reg.exe query "HKCU\Control Panel\Desktop" /v "LogPixels" >>%APP_LOG%
if errorlevel 1 ECHO Query LogPixels failed >>%APP_LOG% & GOTO RESULTFAILED
echo Set "HKCU\Control Panel\Desktop" of Win8DPIScaling=1 >>%APP_LOG%
reg.exe add "HKCU\Control Panel\Desktop" /v "Win8DPIScaling" /t REG_DWORD /d "1" /f >>%APP_LOG% 
if errorlevel 1 echo Win8DPIScaling setting failed. >> %APP_LOG% & goto RESULTFAILED
reg.exe query "HKCU\Control Panel\Desktop" /v "Win8DPIScaling" >>%APP_LOG%
if errorlevel 1 ECHO Query Win8DPIScaling failed >>%APP_LOG% & GOTO RESULTFAILED

echo Load C:\Users\Default\NTUSER.DAT hive file >>%APP_LOG%
reg.exe load HKLM\TempHive "C:\Users\Default\NTUSER.DAT" >>%APP_LOG% 2>>&1
if errorlevel 1 echo Load C:\Users\Default\NTUSER.DAT hive failed >>%APP_LOG% & goto RESULTFAILED
echo Query "HKLM\TempHive\Control Panel\Desktop" >>%APP_LOG%
reg.exe query "HKLM\TempHive\Control Panel\Desktop" >>%APP_LOG%
echo Set "HKLM\TempHive\Control Panel\Desktop" of LogPixels=%regDpi% >>%APP_LOG%
reg.exe add "HKLM\TempHive\Control Panel\Desktop" /v "LogPixels" /t REG_DWORD /d "%regDpi%" /f >>%APP_LOG% 
if errorlevel 1 echo LogPixels setting failed. >> %APP_LOG% & CALL :UnloadHive & goto RESULTFAILED
reg.exe query "HKLM\TempHive\Control Panel\Desktop" /v "LogPixels" >>%APP_LOG%
if errorlevel 1 ECHO Query LogPixels failed >>%APP_LOG% & GOTO RESULTFAILED
echo Set "HKLM\TempHive\Control Panel\Desktop" of Win8DPIScaling=1 >>%APP_LOG%
reg.exe add "HKLM\TempHive\Control Panel\Desktop" /v "Win8DPIScaling" /t REG_DWORD /d "1" /f >>%APP_LOG% 
if errorlevel 1 echo Win8DPIScaling setting failed. >> %APP_LOG% & CALL :UnloadHive & goto RESULTFAILED
reg.exe query "HKLM\TempHive\Control Panel\Desktop" /v "Win8DPIScaling" >>%APP_LOG%
if errorlevel 1 ECHO Query Win8DPIScaling failed >>%APP_LOG% & GOTO RESULTFAILED

CALL :UnloadHive
GOTO  RESULTPASSED


:ChkRes
for /F "tokens=1,2 delims=x" %%A IN ("%1") do (
	FIND.EXE /I "ScreenResX=%%A" C:\HP\BIN\RStone_BBV.INI >NUL
	IF ERRORLEVEL 1 exit /b 1
	FIND.EXE /I "ScreenResY=%%B" C:\HP\BIN\RStone_BBV.INI >NUL
	IF ERRORLEVEL 1 exit /b 1
)
exit /b 0

 
:UnloadHive
echo Unload HKLM\TempHive >>%APP_LOG%
reg.exe unload HKLM\TempHive >>%APP_LOG%
if errorlevel 1 echo Unload HKLM\TempHive failed >>%APP_LOG% & goto RESULTFAILED
GOTO:EOF

GOTO RESULTPASSED

:RESULTPASSED
ECHO [%TIME%] Result of the %APP_NAME% >> %APP_LOG%
ECHO RESULT=PASSED >> %APP_LOG%
GOTO END

:RESULTFAILED
ECHO [%TIME%] Result of the %APP_NAME% >> %APP_LOG%
ECHO RESULT=FAILED >> %APP_LOG%
reg.exe query HKLM\TempHive >nul
if not errorlevel 1 reg.exe unload HKLM\TempHive
GOTO END

:END
ECHO [%TIME%] ============= End the Installation of %APP_NAME% ================ >> %APP_LOG%
@ECHO ON