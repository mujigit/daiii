@REM ------------------------------------------------------------
@REM  This command is supported from Win 8.1. Exit if Win 7.
@REM ------------------------------------------------------------
IF EXIST C:\system.sav\Flags\Win7.flg GOTO END

@REM ------------------------------------------------------------
@REM  set log path
@REM ------------------------------------------------------------
SET "APP_NAME=Windows 10 Image Enhancement - CPS Cleanup QFE"
SET "APP_LOG=C:\System.sav\Logs\ClnWinSxS.log"
SET "LOG_TEMP=C:\system.sav\Logs\DATACOLL.tmp.log"
SET "DATACOLL_LOG=C:\system.sav\EXCLUDE\Logs\DATACOLL.log"
if not exist "C:\system.sav\EXCLUDE\Logs" mkdir "C:\system.sav\EXCLUDE\Logs"

@REM ------------------------------------------------------------
@REM  Always do clean in PASS1
@REM ------------------------------------------------------------
Echo PASS information is [%2] >> %APP_LOG%
if /I "%2"=="PASS1" (
	find.exe /I "RunClnQFE_PASS1=ForceCancel" c:\system.sav\Flags\PINCTRLTwk.pf
	if not errorlevel 1 (
		Echo [%TIME%] PASS1, should always run clean but force cancel by PINCTRLTwk.pf. >> %APP_LOG%
		cscript.exe c:\System.sav\ExitProc\WriteIni.vbs "cNBImageInfo" "RunClnQFE_%1" "0" c:\system.sav\Logs\MYSYSTEM.ini
		goto RESULTPASSED
	)
	Echo [%TIME%] PASS1, always run clean, skip SSD detection. >> %APP_LOG%
	cscript.exe c:\System.sav\ExitProc\WriteIni.vbs "cNBImageInfo" "RunClnQFE_%1" "1" c:\system.sav\Logs\MYSYSTEM.ini
	goto :CLEAN_IT
) else (
	find.exe /I "RunClnQFE_PASS2=ForceCancel" c:\system.sav\Flags\PINCTRLTwk.pf
	if not errorlevel 1 (
		Echo [%TIME%] PASS2, should detect SSD but force cancel by PINCTRLTwk.pf. >> %APP_LOG%
		cscript.exe c:\System.sav\ExitProc\WriteIni.vbs "cNBImageInfo" "RunClnQFE_%1" "0" c:\system.sav\Logs\MYSYSTEM.ini
		goto RESULTPASSED
	)
	find.exe /I "RunClnQFE_PASS2=ForceClean" c:\system.sav\Flags\PINCTRLTwk.pf
	if not errorlevel 1 (
		Echo [%TIME%] PASS2, should detect SSD but force clean by PINCTRLTwk.pf. >> %APP_LOG%
		cscript.exe c:\System.sav\ExitProc\WriteIni.vbs "cNBImageInfo" "RunClnQFE_%1" "1" c:\system.sav\Logs\MYSYSTEM.ini
		goto CLEAN_IT
	)
	Echo [%TIME%] PASS2, goto SSD detection. >> %APP_LOG%
	goto SSD_Detection_START
)

:SSD_Detection_START
@REM ------------------------------------------------------------
@REM  Check SSD for PASS2, skip if SSD.
@REM ------------------------------------------------------------
set Is_SSD=
for /f "tokens=1,2 delims== " %%i in ('Wmic.exe /namespace:\\root\Microsoft\Windows\Storage path MSFT_PhysicalDisk where "SpindleSpeed=0" get SpindleSpeed /value') do (if /i "%%~i" == "SpindleSpeed" set Is_SSD=1)
if defined Is_SSD (
	echo [%TIME%] Found SSD storage, do QFE cleanup. >> %APP_LOG%
	cscript.exe c:\System.sav\ExitProc\WriteIni.vbs "cNBImageInfo" "RunClnQFE_%1" "1" c:\system.sav\Logs\MYSYSTEM.ini
) else (
	echo [%TIME%] Not found SSD storage, ignore QFE cleanup. >> %APP_LOG%
	cscript.exe c:\System.sav\ExitProc\WriteIni.vbs "cNBImageInfo" "RunClnQFE_%1" "0" c:\system.sav\Logs\MYSYSTEM.ini
	goto RESULTPASSED
)
:SSD_Detection_END

:CLEAN_IT
@REM ------------------------------------------------------------
@REM  Data collection on non-CFZ image
@REM ------------------------------------------------------------
IF NOT EXIST C:\System.sav\Flags\TestCert.flg (GOTO CLEAN_COMPONENTS)

Echo.>> %DATACOLL_LOG%
Echo [ClnQFE_%1]>> %DATACOLL_LOG%
Echo [%time%] ================================================== >> %DATACOLL_LOG%
Echo [%time%]  Data collection on non-CFZ image.>> %DATACOLL_LOG%
Echo [%time%]   at [%2][%1] phase>> %DATACOLL_LOG%
Echo [%time%] ================================================== >> %DATACOLL_LOG%

Echo [%time%] === Analysis start at [%2][%1] phase =============================================== >> %APP_LOG%
Dism.exe /Online /English /Cleanup-Image /AnalyzeComponentStore > %LOG_TEMP%
Echo [%time%] === Analysis end at [%2][%1] phase =============================================== >> %APP_LOG%
TYPE %LOG_TEMP% >> %DATACOLL_LOG%

SET ErrorLevel=
FindStr.exe /s /i /c:"Component Store Cleanup Recommended : No" "%LOG_TEMP%"
Echo ErrorLevel=[%ErrorLevel%].>> %DATACOLL_LOG%
IF [%ErrorLevel%]==[0] (
	cscript.exe c:\System.sav\ExitProc\WriteIni.vbs "Feedback" "ClnQFE_%1" "NO_REQUIRED" c:\system.sav\Logs\MYSYSTEM.ini
) ELSE (
	cscript.exe c:\System.sav\ExitProc\WriteIni.vbs "Feedback" "ClnQFE_%1" "REQUIRED" c:\system.sav\Logs\MYSYSTEM.ini
)
DEL /F /Q "%LOG_TEMP%"
Echo [%time%] ================================================== >> %DATACOLL_LOG%

:CLEAN_COMPONENTS
@REM ------------------------------------------------------------
@REM  Cleanup Components.
@REM ------------------------------------------------------------
Echo. >> %APP_LOG%
Echo [%time%] ================================================== >> %APP_LOG%
Echo [%time%] Before cleanup component store (WinSxS folder) >> %APP_LOG%
Echo [%time%]  at [%2][%1] phase... >> %APP_LOG%
Echo [%time%] ================================================== >> %APP_LOG%
DIR C:\ >> %APP_LOG%

Echo [%time%] ================================================== >> %APP_LOG%
Echo [%time%] Cleanup component store (WinSxS folder) >> %APP_LOG%
Echo [%time%]  at [%2][%1] phase... >> %APP_LOG%
Echo [%time%] ================================================== >> %APP_LOG%
SET ErrorLevel=
DISM.exe /Online /Cleanup-Image /StartComponentCleanup /ResetBase /NoRestart /LogPath=C:\System.sav\Logs\ClnWinSxS_%1.log
if errorlevel 1 [%time%] DISM QFE cleanup failed. Errorlevel=%ErrorLevel% >> %APP_LOG% & goto RESULTFAILED

@REM ------------------------------------------------------------
@REM  Backup logs
@REM ------------------------------------------------------------
COPY /Y C:\Windows\logs\CBS\CBS.log C:\System.sav\Exclude\Logs\ClnWinSxS_CBS_%1.log
FIND /I "deep-clean" C:\System.sav\Exclude\Logs\ClnWinSxS_CBS_%1.log >> C:\System.sav\Logs\QFEOff\UninstQFE_%1.log
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