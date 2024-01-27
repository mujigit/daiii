REM ========================================================
REM   Template Version: 2.00
REM ========================================================

@ECHO OFF
SETLOCAL
SET APP_NAME=Windows 10 HP Image Enhancements - CPS - Disable MS Defender
SET APP_LOG=C:\System.sav\LOGS\BB\%~n0.LOG
IF NOT EXIST C:\System.sav\LOGS\BB MD C:\System.sav\LOGS\BB

ECHO ############################################################# >> %APP_LOG%
ECHO  [%DATE%]                                                     >> %APP_LOG%
ECHO  [%TIME%] Beginning of the %~nx0                              >> %APP_LOG%
ECHO ############################################################# >> %APP_LOG%

REM ------------------- Script Entry ------------------------
ECHO [%TIME%] Start %APP_NAME% >>%APP_LOG%

:RS1DETECT
ECHO [%TIME%] RS1 Detection >>%APP_LOG%
IF EXIST C:\System.sav\flags\W10RS1.FLG ECHO For RS1, offline disable defender. >> %APP_LOG% & GOTO RESULTPASSED

:DETECTION
findstr.exe /i /x "McAfeeFlag=[0-6]" C:\HP\BIN\RStone_BBV.INI >NUL
IF ERRORLEVEL 1 ECHO Image w/o Mcafee, ignore MS Defender disable. >> %APP_LOG% & GOTO RESULTPASSED

:MIRDETECT
ECHO [%TIME%] MIR Detection >>%APP_LOG%
IF EXIST C:\System.sav\flags\RMinImg.flg ECHO "%APP_NAME%" did not support MIR. >> %APP_LOG% & GOTO RESULTPASSED

:INSTALL
ECHO [%TIME%] Install %APP_NAME% >>%APP_LOG%
IF EXIST C:\System.sav\flags\HAL64.flg (
    start /w C:\SWSETUP\hpImgEnh\DisableDefender\DisableMSDefender64.msi /qn /norestart>> %APP_LOG%
    IF ERRORLEVEL 1 GOTO RESULTFAILED
) ELSE (
    start /w C:\SWSETUP\hpImgEnh\DisableDefender\DisableMSDefender32.msi /qn /norestart>> %APP_LOG%
    IF ERRORLEVEL 1 GOTO RESULTFAILED
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