REM ========================================================
REM   Template Version: 2.00
REM ========================================================

@ECHO OFF
SETLOCAL
set WP=
for /f "tokens=2 delims==" %%i in ('Wmic.exe /namespace:\\root\cimv2 path win32_logicaldisk where ^(DriveType^="3"^) get DeviceID /value') do (
   for /f "delims= " %%a in ("%%~i") do (
       echo [%TIME%] Check "%%~a\Windows\System32\ReAgentc.exe">> %~dpn0.log
       if exist "%%~a\Windows\System32\ReAgentc.exe" echo [%TIME%] Set "WP=%%~a">> %~dpn0.log & set "WP=%%~a"
   )
)
if not defined WP echo [%TIME%] Could not found the windows partition. >> %~dpn0.log & color 47 & exit /b 1

SET APP_NAME=Windows 10 HP Image Enhancements - CPS
SET "APP_LOG="%WP%\System.sav\Logs\BB\%~n0.LOG""
if not exist %WP%\System.sav\Logs\BB md %WP%\System.sav\Logs\BB
ECHO ############################################################# >> %APP_LOG%
ECHO  [%DATE%]                                                     >> %APP_LOG%
ECHO  [%TIME%] Beginning of the %~nx0                              >> %APP_LOG%
ECHO ############################################################# >> %APP_LOG%
echo [%TIME%] Windows Partition=%WP% >> %APP_LOG%

:RS1DETECT
ECHO [%TIME%] RS1 Detection >>%APP_LOG%
IF NOT EXIST C:\System.sav\flags\W10RS1.FLG ECHO Not RS1, already online disable defender. >> %APP_LOG% & GOTO RESULTPASSED

:MCAFEEDETECT
find.exe /i /c "McAfeeFlag=0" %WP%\HP\BIN\RStone_BBV.INI >NUL
IF NOT ERRORLEVEL 1 ECHO Image w/ Mcafee, disable MS Defender. >> %APP_LOG% & GOTO DISABLEIT
find.exe /i /c "McAfeeFlag=1" %WP%\HP\BIN\RStone_BBV.INI >NUL
IF NOT ERRORLEVEL 1 ECHO Image w/ Mcafee, disable MS Defender. >> %APP_LOG% & GOTO DISABLEIT
find.exe /i /c "McAfeeFlag=2" %WP%\HP\BIN\RStone_BBV.INI >NUL
IF NOT ERRORLEVEL 1 ECHO Image w/ Mcafee, disable MS Defender. >> %APP_LOG% & GOTO DISABLEIT
find.exe /i /c "McAfeeFlag=3" %WP%\HP\BIN\RStone_BBV.INI >NUL
IF NOT ERRORLEVEL 1 ECHO Image w/ Mcafee, disable MS Defender. >> %APP_LOG% & GOTO DISABLEIT
find.exe /i /c "McAfeeFlag=4" %WP%\HP\BIN\RStone_BBV.INI >NUL
IF NOT ERRORLEVEL 1 ECHO Image w/ Mcafee, disable MS Defender. >> %APP_LOG% & GOTO DISABLEIT
find.exe /i /c "McAfeeFlag=5" %WP%\HP\BIN\RStone_BBV.INI >NUL
IF NOT ERRORLEVEL 1 ECHO Image w/ Mcafee, disable MS Defender. >> %APP_LOG% & GOTO DISABLEIT
find.exe /i /c "McAfeeFlag=6" %WP%\HP\BIN\RStone_BBV.INI >NUL
IF NOT ERRORLEVEL 1 ECHO Image w/ Mcafee, disable MS Defender. >> %APP_LOG% & GOTO DISABLEIT
ECHO Image w/o Mcafee, ignore MS Defender disable. >> %APP_LOG% & GOTO RESULTPASSED

:MIRDETECT
ECHO [%TIME%] MIR Detection >>%APP_LOG%
IF EXIST C:\System.sav\flags\RMinImg.flg ECHO "%APP_NAME%" did not support MIR. >> %APP_LOG% & GOTO RESULTPASSED

:DISABLEIT
set isFail=

echo Load %WP%\windows\system32\config\Software hive file >>%APP_LOG%
reg.exe load HKLM\TempHive "%WP%\windows\system32\config\Software" >>%APP_LOG% 2>>&1
if errorlevel 1 echo Load %WP%\windows\system32\config\Software hive failed >>%APP_LOG% & goto RESULTFAILED

REG ADD   "HKLM\TempHive\Microsoft\Windows Defender" /v "DisableAntiSpyware" /t REG_DWORD /d 1 /f >>%APP_LOG% 2>>&1
reg query "HKLM\TempHive\Microsoft\Windows Defender" /v "DisableAntiSpyware" >>%APP_LOG% 2>>&1
if errorlevel 1 echo Load %WP%\windows\system32\config\Software hive failed >>%APP_LOG% & set isFail=1

REG ADD   "HKLM\TempHive\Microsoft\Windows Defender" /v "DisableAntiVirus" /t REG_DWORD /d 1 /f >>%APP_LOG% 2>>&1
reg query "HKLM\TempHive\Microsoft\Windows Defender" /v "DisableAntiVirus" >>%APP_LOG% 2>>&1
if errorlevel 1 echo Load %WP%\windows\system32\config\Software hive failed >>%APP_LOG% & set isFail=1

if defined isFail goto RESULTFAILED
CALL :UnloadHive
GOTO  RESULTPASSED



rem ============== SUB FUNCTIONS ===========================================================



:UnloadHive
echo Unload HKLM\TempHive >>%APP_LOG%
reg.exe unload HKLM\TempHive >>%APP_LOG%
if errorlevel 1 echo Unload HKLM\TempHive failed >>%APP_LOG% & goto RESULTFAILED
GOTO:EOF


:RESULTPASSED
ECHO [%TIME%] Result of the %APP_NAME% >> %APP_LOG%
ECHO RESULT=PASSED >> %APP_LOG%
GOTO END

:RESULTFAILED
ECHO [%TIME%] Result of the %APP_NAME% >> %APP_LOG%
ECHO RESULT=FAILED >> %APP_LOG%
ECHO ERRORLEVEL=%errorlevel% >> %APP_LOG%
reg.exe query "HKLM\TempHive">nul
IF NOT ERRORLEVEL 1 call :UnloadHive
GOTO END


:END
ENDLOCAL
@ECHO ON