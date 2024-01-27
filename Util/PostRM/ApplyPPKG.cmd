@ECHO OFF
setlocal enabledelayedexpansion

REM ====================================================
REM   Setting Required Variable
REM ====================================================
SET CRM.ERR.NUM=0
SET CRM.ERR.MSG=NO ERROR DURING %~n0 PROCESSING
SET CRM.WorkingPath=%~dp0
SET CRM.WorkingDrv=%~d0
SET CRM.RMFail=C:\SYSTEM.SAV\FLAGS\RMFail.flg
SET CRM.RMLOG.UPPath=C:\SYSTEM.SAV\LOGS\RM\
SET CRM.RECOVERY.FLAG=C:\SYSTEM.SAV\FLAGS\RImage.flg

SET CRM.DeployToolPath=C:\RM\RERM\DeployRP\
SET CRM.PostRMPath=%CRM.WorkingPath%
SET CRM.PPKG.Path=C:\Recovery\Customizations\usmt.ppkg
SET CRM.FLAG.SingleInstance=C:\system.sav\flags\RMSingleInstance.flg
SET CRM.FLAG.SingleInstance.FAIL=C:\system.sav\flags\RM_SingleIns_Fail.flg


REM ====================================================
REM   Generate PPKG
REM ====================================================
IF NOT EXIST %CRM.FLAG.SingleInstance% (
	ECHO [%time%][%~nx0] Can't find [%CRM.FLAG.SingleInstance%], do not apply PPKG
	GOTO END_SINGLEINSTANCE     
) 


SET CRM.FILE=%CRM.PPKG.Path%
IF NOT EXIST %CRM.FILE% (
	SET CRM.ERR.NUM=795
	SET CRM.ERR.MSG= Can't find [%CRM.FILE%]
	GOTO END
) 

ECHO [%time%][%~nx0] DISM.exe /Apply-CustomDataImage /CustomDataImage:%CRM.PPKG.Path% /ImagePath:C:\ /SingleInstance /logpath:C:\SYSTEM.SAV\LOGS\RM\DISM_APPLYPPKG.log
DISM.exe /Apply-CustomDataImage /CustomDataImage:%CRM.PPKG.Path% /ImagePath:C:\ /SingleInstance /logpath:C:\SYSTEM.SAV\LOGS\RM\DISM_APPLYPPKG.log
SET CRM.RETURNCODE=%errorlevel%
IF NOT [%CRM.RETURNCODE%]==[0] (
	SET CRM.ERR.NUM=795
	SET CRM.ERR.MSG=FAIL: DISM.exe /Apply-CustomDataImage /CustomDataImage:%CRM.PPKG.Path% /ImagePath:C:\ /SingleInstance /logpath:C:\SYSTEM.SAV\LOGS\RM\DISM_APPLYPPKG.log
	ECHO [%time%][%~nx0] FAIL: DISM.exe /Apply-CustomDataImage /CustomDataImage:%CRM.PPKG.Path% /ImagePath:C:\ /SingleInstance /logpath:C:\SYSTEM.SAV\LOGS\RM\DISM_APPLYPPKG.log >> %CRM.FLAG.SingleInstance.FAIL% 
	ECHO [%time%][%~nx0] Retrun Code : %CRM.RETURNCODE% >> %CRM.FLAG.SingleInstance.FAIL% 
	ECHO [%time%][%~nx0] FAIL: DISM.exe /Apply-CustomDataImage /CustomDataImage:%CRM.PPKG.Path% /ImagePath:C:\ /SingleInstance /logpath:C:\SYSTEM.SAV\LOGS\RM\DISM_APPLYPPKG.log >> %CRM.RMFail% 
	ECHO [%time%][%~nx0] Retrun Code : %CRM.RETURNCODE% >> %CRM.RMFail%
	GOTO END
)
ECHO [%time%][%~nx0] END

:END_SINGLEINSTANCE



GOTO END

:END
REM ====================================================
REM  Error detection
REM ====================================================
IF NOT [%CRM.ERR.NUM%]==[0] (
	ECHO.
	ECHO ******************************************************************************
	ECHO * ERROR: %CRM.ERR.NUM%
	ECHO *      : %CRM.ERR.MSG%
	ECHO ******************************************************************************
	ECHO.
	
	ECHO [%time%][%~nx0] %CRM.ERR.MSG% 
)

ECHO [%~nx0] %date% %time%
ECHO ********** FINISH %~nx0 **********
ECHO RETURN CODE - %CRM.ERR.NUM%

REM EXIT THE SCRIPT AND RETURN THE ERROR LEVEL
EXIT /b %CRM.ERR.NUM%


:CreateFolder
SET CRM.FullPATH=%1
SET CRM.PATH=NONE
for /f "delims==" %%F in ("%CRM.FullPATH%") do (
	SET CRM.PATH=%%~dpF
)

IF [%CRM.PATH%]==[NONE] (
	ECHO [%time%][%~nx0] WARNING, Create %CRM.FullPATH% Fail
) ELSE (
	IF NOT EXIST "%CRM.PATH%" (
		ECHO [%time%][%~nx0] MKDIR "%CRM.PATH%"
		MKDIR "%CRM.PATH%"
	)
)

EXIT /B