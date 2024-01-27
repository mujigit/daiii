REM ========================================================
REM   Template Version: 2.00
REM ========================================================

@ECHO OFF
SET APP_NAME=Windows 10 HP Image Enhancements - CPS - Start Policy Setting
SET APP_LOG=C:\System.sav\LOGS\BB\%~n0.LOG
IF NOT EXIST C:\System.sav\LOGS\BB MD C:\System.sav\LOGS\BB

ECHO ############################################################# >> %APP_LOG%
ECHO  [%DATE%]                                                     >> %APP_LOG%
ECHO  [%TIME%] Beginning of the %~nx0                              >> %APP_LOG%
ECHO ############################################################# >> %APP_LOG%


REM ------------------- Script Entry ------------------------

SET /A OpenAtLogon=1
SET /A GoToDesktopOnSignIn=0
FINDSTR.EXE /I /X /C:"OSSkuFlag=4" /C:"OSSkuFlag=5" "C:\HP\BIN\RStone_BBV.INI">>%APP_LOG%
IF ERRORLEVEL 1 ECHO This is not Windows 8.1/10 image, skip start policy setting. >>%APP_LOG% & GOTO Install
FINDSTR.EXE /I /X /C:"ChassisType=5" "C:\HP\BIN\RStone_BBV.INI">>%APP_LOG%
IF NOT ERRORLEVEL 1 ECHO This is Slate/Tablet platform, set start policy to start screen. >>%APP_LOG% & GOTO Install
ECHO This is Stardand platform, set start policy to Desktop. >>%APP_LOG%
SET /A OpenAtLogon=0
SET /A GoToDesktopOnSignIn=1

:Install
echo Query "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\DesktopOptimization" >>%APP_LOG%
reg.exe query "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\DesktopOptimization" /v "GoToDesktopOnSignIn" >>%APP_LOG%
echo Set "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\DesktopOptimization" of DesktopOptimization=%GoToDesktopOnSignIn% >>%APP_LOG%
reg.exe add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\DesktopOptimization" /v "GoToDesktopOnSignIn" /t REG_DWORD /d "%GoToDesktopOnSignIn%" /f >>%APP_LOG% 
if errorlevel 1 echo GoToDesktopOnSignIn setting failed >> %APP_LOG% & goto RESULTFAILED
reg.exe query "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\DesktopOptimization" /v "GoToDesktopOnSignIn" >>%APP_LOG%
if errorlevel 1 ECHO Query GoToDesktopOnSignIn failed >>%APP_LOG% & GOTO RESULTFAILED

echo Load C:\Users\Default\NTUSER.DAT hive file >>%APP_LOG%
reg.exe load HKLM\TempHive "C:\Users\Default\NTUSER.DAT" >>%APP_LOG% 2>>&1
if errorlevel 1 echo Load C:\Users\Default\NTUSER.DAT hive failed >>%APP_LOG% & goto RESULTFAILED
echo Query "HKLM\TempHive\Software\Microsoft\Windows\CurrentVersion\Explorer\StartPage" >>%APP_LOG%
reg.exe query "HKLM\TempHive\Software\Microsoft\Windows\CurrentVersion\Explorer\StartPage" /v "OpenAtLogon" >>%APP_LOG%
echo Set "HKLM\TempHive\Software\Microsoft\Windows\CurrentVersion\Explorer\StartPage" >>%APP_LOG%
reg.exe add "HKLM\TempHive\Software\Microsoft\Windows\CurrentVersion\Explorer\StartPage" /v "OpenAtLogon" /t REG_DWORD /d "%OpenAtLogon%" /f >>%APP_LOG% 
if errorlevel 1 CALL :UnloadHive & goto RESULTFAILED
reg.exe query "HKLM\TempHive\Software\Microsoft\Windows\CurrentVersion\Explorer\StartPage" /v "OpenAtLogon" >>%APP_LOG%
if errorlevel 1 ECHO Query failed >>%APP_LOG% & CALL :UnloadHive & GOTO RESULTFAILED
CALL :UnloadHive
GOTO  RESULTPASSED
 
REM ------------------- Script exit ------------------------
 
:UnloadHive
echo Unload HKLM\TempHive >>%APP_LOG%
reg.exe unload HKLM\TempHive >>%APP_LOG%
if errorlevel 1 echo Unload HKLM\TempHive failed >>%APP_LOG% & goto RESULTFAILED
exit /b 0

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
@ECHO ON