REM ========================================================
REM   Template Version: 2.00
REM   Offline add driver to WinPE
REM   Copy drivers for WinPE_DrvInst.cmd to online drvload.
REM ========================================================

@ECHO OFF
SETLOCAL
SET APP_NAME=Windows 10 HP Image Enhancements - CPS - Driver Install for WinPE
SET APP_LOG=C:\System.sav\LOGS\BB\%~n0.LOG
IF NOT EXIST C:\System.sav\LOGS\BB MD C:\System.sav\LOGS\BB

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
set "drvInstErr=FALSE"

:Detection

REM Folders in c:\System.sav\WinPE_OnLine\ or c:\system.sav\winpe_drv\ are about OS, such as "Win10" / "Win8" / "Win7".
REM Support WinPE_Offline, equal to WinPE_DRV. WinPE_DRV still be kept for backward capatible.
if not exist c:\System.sav\WinPE_OnLine ( if not exist c:\System.sav\WinPE_Offline ( if not exist c:\System.sav\WinPE_DRV ( echo No WinPE driver found. >>%APP_LOG% & GOTO RESULTPASSED ) ) )


Set OSArch=
for /f "tokens=1,2 delims== " %%i in ('Wmic.exe /namespace:\\root\cimv2 path Win32_OperatingSystem get OSArchitecture /value') do (if /i %%~i == OSArchitecture set OSArch=%%~j)
if not defined OSArch echo [%time%] Could not identify OS architecture. >> %APP_LOG% & goto RESULTFAILED
echo OS Architecture=[%OSArch%] >> %APP_LOG%
set cpuArch=x64
if /I "%OSArch%"=="32-bit" set cpuArch=x86
echo cpuArch=[%cpuArch%] >> %APP_LOG%

Set DriverPath=
set OfflineDriverPath=
for /f "delims=" %%i in ('dir /ad /b C:\System.sav\WinPE_DRV')     do call :CheckOsFlg C:\System.sav\flags %%~i c:\System.sav\WinPE_DRV
for /f "delims=" %%i in ('dir /ad /b C:\System.sav\WinPE_Offline') do call :CheckOsFlg C:\System.sav\flags %%~i c:\System.sav\WinPE_Offline
if defined DriverPath set "OfflineDriverPath=%DriverPath%"

Set DriverPath=
set OnlineDriverPath=
for /f "delims=" %%i in ('dir /ad /b c:\System.sav\WinPE_OnLine\') do (
	call :CheckOsFlg C:\System.sav\flags              %%~i c:\System.sav\WinPE_OnLine
	call :CheckOsFlg c:\System.sav\WinPE_OnLine\flags %%~i c:\System.sav\WinPE_OnLine
)
if defined DriverPath set "OnlineDriverPath=%DriverPath%"

if not defined OfflineDriverPath ( if not defined OnlineDriverPath ( echo No match WinPE driver found. >>%APP_LOG% & GOTO RESULTPASSED ) )

if defined OfflineDriverPath echo WinPE offline driver path is "%OfflineDriverPath%" >>%APP_LOG%
if defined OnlineDriverPath  echo WinPE oline   driver path is "%OnlineDriverPath%"  >>%APP_LOG%

Set WimPath=
for /f "skip=2 delims=" %%i in ('Wmic.exe path win32_logicaldisk where ^(DriveType^="3"^) get DeviceID^,VolumeName^,Description /format:csv') do (
	for /f "tokens=2,3* delims=," %%x in ("%%~i") do (
		echo Search in %%~dy\ [%%~z] ^(%%~x^)>> %APP_LOG%
		if exist "%%~dy\System.sav\Flags\BP.flg" if exist "%%~dy\Sources\boot.wim" echo Found %%~dy\Sources\boot.wim >> %APP_LOG% & Set "WimPath=%%~dy\Sources" & goto Install
		if exist "%%~dy\System.sav\Flags\UP.flg" if exist "%%~dy\Sources\boot.wim" echo Found %%~dy\Sources\boot.wim >> %APP_LOG% & Set "WimPath=%%~dy\Sources" & goto Install
	)
)
if not defined WimPath echo [%TIME%] No boot.wim found. >>%APP_LOG%
GOTO RESULTPASSED

:Install
if not exist %WimPath%\boot.wim echo [%TIME%] No %WimPath%\boot.wim found. >>%APP_LOG% & GOTO RESULTPASSED
echo [%TIME%] Clean mount folder C:\SWSetup\hpImgEnh\mount >>%APP_LOG%
if exist "C:\SWSetup\hpImgEnh\mount" rd /s /q "C:\SWSetup\hpImgEnh\mount"
if exist "C:\SWSetup\hpImgEnh\mount" echo "C:\SWSetup\hpImgEnh\mount" delete failed.>> %APP_LOG% & goto RESULTFAILED
if not exist "C:\SWSetup\hpImgEnh\mount" mkdir "C:\SWSetup\hpImgEnh\mount"
echo [%TIME%] Mount %WimPath%\boot.wim >>%APP_LOG%
Dism.exe /mount-wim /wimfile:"%WimPath%\boot.wim" /index:1 /mountdir:"C:\SWSetup\hpImgEnh\mount" >>%APP_LOG% 2>&1
echo [%TIME%] Errorlevel=%errorlevel% >>%APP_LOG%
if errorlevel 1 echo %WimPath%\boot.wim WinPE mount failed.>> %APP_LOG% & goto RESULTFAILED


if defined OfflineDriverPath call :Drv_Offline
if defined OnlineDriverPath  call :Drv_Online

echo [%TIME%] Unmount C:\SWSetup\hpImgEnh\mount >>%APP_LOG%
Dism.exe /unmount-wim /mountdir:"C:\SWSetup\hpImgEnh\mount" /commit >>%APP_LOG% 2>&1
echo [%TIME%] Errorlevel=%errorlevel% >>%APP_LOG%
if errorlevel 1 ECHO Unmount failed >>%APP_LOG% & goto RESULTFAILED

if /I "%drvInstErr%"=="TRUE" goto RESULTFAILED
GOTO RESULTPASSED


:RESULTPASSED
ECHO [%TIME%] Result of the %APP_NAME% >> %APP_LOG%
ECHO RESULT=PASSED >> %APP_LOG%
GOTO END

:RESULTFAILED
IF EXIST X:\windows\Logs\DISM\dism.log (
	ECHO [%TIME%] copy /y X:\windows\Logs\DISM\dism.log C:\System.sav\LOGS\WinPE_DRV_DISM.LOG >> %APP_LOG%
	copy /y X:\windows\Logs\DISM\dism.log C:\System.sav\LOGS\WinPE_DRV_DISM.LOG >> %APP_LOG% 2>&1
)
ECHO [%TIME%] Result of the %APP_NAME% >> %APP_LOG%
ECHO RESULT=FAILED >> %APP_LOG%
GOTO END

:END
ENDLOCAL
@ECHO ON
goto :EOF



:Drv_Offline
echo [%TIME%] Offline install "%OfflineDriverPath%" driver to WinPE >>%APP_LOG%
for /f "tokens=1,2 delims==" %%i in ('Wmic.exe /namespace:\\root\cimv2 path Win32_BaseBoard get Product /value') do (if /i %%~i == Product set "SystemId=%%~j")
if not defined SystemId echo Unknow System Id >> %APP_LOG% & goto RESULTFAILED
echo System Id=[%SystemId%] >>%APP_LOG%

for /f "delims=" %%i in ('dir /ad /b "%OfflineDriverPath%"') do (
	echo [%TIME%] Checking folder %OfflineDriverPath%\%%~i for offline WinPE driver injection >>%APP_LOG%
	if not exist "%OfflineDriverPath%\%%~i\sysid.txt" ( 
			echo No "%OfflineDriverPath%\%%~i\sysid.txt", force install driver. >>%APP_LOG%
			call :AddDrvToMountPE "%OfflineDriverPath%\%%~i"
	) else (
		find /i "%SystemId%" "%OfflineDriverPath%\%%~i\sysid.txt" >nul 2>&1
		if not errorlevel 1 (
			echo SysId matched, offline inject driver. >>%APP_LOG%
			call :AddDrvToMountPE "%OfflineDriverPath%\%%~i"
		) else ( 
			echo SysId mismatch.>>%APP_LOG%
		)
	)
)
exit /b 0

:AddDrvToMountPE
echo [%TIME%] Offline install "%~1" driver to WinPE >>%APP_LOG%
echo [%TIME%] Use folder resursive install >>%APP_LOG%
Dism.exe /image:C:\SWSetup\hpImgEnh\mount /Add-Driver /driver:"%~1" /recurse >>%APP_LOG% 2>&1
echo [%TIME%] Errorlevel=%errorlevel% >>%APP_LOG%
if errorlevel 1 ECHO RESULT=FAILED >>%APP_LOG% & set "drvInstErr=TRUE"
exit /b 0


:Drv_Online
echo Driver Path="%OnlineDriverPath%" >>%APP_LOG%

echo [%TIME%] Copy DrvInst.cmd for WinPE. >>%APP_LOG%
xcopy /y /f %~dp0WinPE_DrvInst.cmd C:\SWSetup\hpImgEnh\mount\WINPE_OnLine\ >>%APP_LOG%
if not exist C:\SWSetup\hpImgEnh\mount\WINPE_OnLine\WinPE_DrvInst.cmd ECHO RESULT=FAILED >>%APP_LOG% & goto RESULTFAILED
echo [%TIME%] Copy Online driver source for WinPE. >>%APP_LOG%
xcopy /icherkyf "%OnlineDriverPath%\*.*" "C:\SWSetup\hpImgEnh\mount\WinPE_OnLine\" >>%APP_LOG% 2>&1
if errorlevel 1 echo Xcopy failed. >>%APP_LOG% & ECHO RESULT=FAILED >>%APP_LOG% & set "drvInstErr=TRUE"

echo [%TIME%] Copy DrvInst.cmd for WinRE. >>%APP_LOG%
xcopy /y /f %~dp0WinPE_DrvInst.cmd c:\System.sav\WinPE_OnLine_4WinRE\ >>%APP_LOG%
if not exist c:\System.sav\WinPE_OnLine_4WinRE\WinPE_DrvInst.cmd ECHO RESULT=FAILED >>%APP_LOG% & goto RESULTFAILED
echo [%TIME%] Copy Online driver source for WinRE. >>%APP_LOG%
xcopy /icherkyf "%OnlineDriverPath%\*.*" "c:\System.sav\WinPE_OnLine_4WinRE\" >>%APP_LOG% 2>&1
if errorlevel 1 echo Xcopy failed. >>%APP_LOG% & ECHO RESULT=FAILED >>%APP_LOG% & set "drvInstErr=TRUE"
echo [%TIME%] Rename WinPE_OnLine to WinPE_OnLine_BK >>%APP_LOG%
ren c:\System.sav\WinPE_OnLine        WinPE_OnLine_BK
if errorlevel 1                            echo Rename failed. >>%APP_LOG% & ECHO RESULT=FAILED >>%APP_LOG% & goto RESULTFAILED
if not exist c:\System.sav\WinPE_OnLine_BK echo Rename failed. >>%APP_LOG% & ECHO RESULT=FAILED >>%APP_LOG% & goto RESULTFAILED
echo [%TIME%] Rename WinPE_OnLine_4WinRE to WinPE_OnLine >>%APP_LOG%
ren c:\System.sav\WinPE_OnLine_4WinRE WinPE_OnLine
if errorlevel 1                            echo Rename failed. >>%APP_LOG% & ECHO RESULT=FAILED >>%APP_LOG% & goto RESULTFAILED
if not exist c:\System.sav\WinPE_OnLine    echo Rename failed. >>%APP_LOG% & ECHO RESULT=FAILED >>%APP_LOG% & goto RESULTFAILED

exit /b 0


:CheckOsFlg
REM Format: call :CheckFlg c:\System.sav\WinPE_OnLine\flags "Win10" c:\System.sav\WinPE_OnLine
if not exist "%3\%2\%cpuArch%" echo "%3\%2\%cpuArch%" not exist. >> %APP_LOG% & %exit /b 1
set "tmpDriverPath=%3\%~2\%cpuArch%"
REM WIN7.FLG
REM WIN7SP1.FLG
REM WIN10.FLG
REM WIN10TH2.FLG
REM WIN10RS1.FLG
REM ??? restrict the max length
set "FolderName=%~2"
if exist "%1\%FolderName%???.flg" (
	echo [Match] "%1\%FolderName%???.flg" >> %APP_LOG%
	dir /b "%1\%FolderName%???.flg" >> %APP_LOG%
	set "DriverPath=%tmpDriverPath%"
	exit /b 0
)
REM W7.FLG
REM W7SP1.FLG
REM W10.FLG
REM W10TH2.FLG
REM W10RS1.FLG
REM ??? restrict the max length
set "FolderName=%FolderName:in=%"
set "FolderName=%FolderName:IN=%"
if exist "%1\%FolderName%???.flg" (
	echo [Match] "%1\%FolderName%???.flg" >> %APP_LOG%
	dir /b "%1\%FolderName%???.flg" >> %APP_LOG%
	set "DriverPath=%tmpDriverPath%"
	exit /b 0
)
echo [Mismatch] Mismatch any OS flag, never set variable DrivePath >> %APP_LOG%
exit /b 1

