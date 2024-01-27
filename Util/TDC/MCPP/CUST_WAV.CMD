REM ========================================================
REM   Template Version: 2.00
REM ========================================================

@ECHO OFF
SETLOCAL
SET APP_NAME=Windows 10 Image Customization Tweaks for 3C16 - CPS
SET APP_LOG=C:\System.sav\LOGS\BB\%~n0.LOG
IF NOT EXIST C:\System.sav\LOGS\BB MD C:\System.sav\LOGS\BB

ECHO ############################################################# >> %APP_LOG%
ECHO  [%DATE%]                                                     >> %APP_LOG%
ECHO  [%TIME%] Beginning of the %~nx0 during %1 phase              >> %APP_LOG%
ECHO ############################################################# >> %APP_LOG%

REM ------------------- Script Entry ------------------------

Echo WAV info before replace >>%APP_LOG%
dir "C:\Windows\Media\Windows*ground.wav" >> %APP_LOG%
dir "C:\Windows\Media\Windows Notify*.wav" >> %APP_LOG%

if not exist C:\System.sav\Flags\W10NOV15.FLG echo Not Win10 Nov15 OS, skip. >>%APP_LOG% & goto RESULTPASSED

Echo Start of platform search.>>%APP_LOG%
REM if not exist C:\System.sav\Flags\CNB.FLG echo Not CNB, skip. >>%APP_LOG% & goto RESULTPASSED
REM Masaki solution for CNB/CDT detection
SET dpsPath=
SET mlPrefix=
FOR /F %%a IN ('dir C:\system.sav\*_DPS /b') DO SET dpsPath=C:\system.sav\%%a
if not defined dpsPath echo dpsPath not found >>%APP_LOG% & goto RESULTFAILED
ECHO [%time%][%~nx0] DPS File : %dpsPath% >>%APP_LOG%
FOR /F "tokens=2 delims==" %%a IN ('find /n /i "ML_Prefix" %dpsPath%') DO SET mlPrefix=%%a
if not defined mlPrefix echo mlPrefix not found >>%APP_LOG% & goto RESULTFAILED
ECHO [%time%][%~nx0] %mlPrefix% >>%APP_LOG%
if /i not "%mlPrefix%"=="CNB" echo Not CNB, skip. >>%APP_LOG% & goto RESULTPASSED

:WaveChange
echo [%TIME%] Wave files replacement process. >>%APP_LOG%
xcopy /icherky C:\SWSetup\CustTweak\WaveFiles c:\Windows\Media >>%APP_LOG% 2>&1
if errorlevel 1 echo Wave file replace failed. >>%APP_LOG% & goto RESULTFAILED
echo [%TIME%] File replace success. >>%APP_LOG%

Echo WAV info after replace >>%APP_LOG%
dir "C:\Windows\Media\Windows*ground.wav" >> %APP_LOG%
dir "C:\Windows\Media\Windows Notify*.wav" >> %APP_LOG%

goto RESULTPASSED


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