@ECHO OFF
setlocal enabledelayedexpansion

REM ====================================================
REM   Setting Required Variable
REM ====================================================
SET CRM.ERR.NUM=0
SET CRM.ERR.MSG=NO ERROR DURING %~n0 PROCESSING
SET CRM.WorkingPath=%~dp0
SET CRM.WorkingDrv=%~d0

SET CRM.RMLOG.UPPath=C:\SYSTEM.SAV\LOGS\RM\
SET CRM.LOG=%CRM.RMLOG.UPPath%%~n0.log
SET CRM.MSBCDLOG=%CRM.RMLOG.UPPath%BBV3-MSBCDTable.log
SET CRM.ReagentcLOG=%CRM.RMLOG.UPPath%BBV3-ReagentcInfo.log
SET CRM.RECOVERY.FLAG=C:\SYSTEM.SAV\FLAGS\RImage.flg
SET CRM.FLAG.NORP=C:\system.sav\flags\NORP.flg

SET CRM.DeployToolPath=C:\RM\RERM\DeployRP\
SET CRM.PostRMPath=%CRM.WorkingPath%

SET CRM.UP.DrvLetter=C:
SET CRM.WinRE.DrvLetter=W:
SET CRM.ESP.DrvLetter=S:

SET CRM.RP.DrvLetter=NONE
SET CRM.RP.CHECKFILE=\Recovery\_CNBRP2.FLG
SET CRM.UCRM.CHECKFILE=\_HPUCRM.FLG

SET CRM.PBR.Dest=C:\Recovery\OEM\

REM ----------------------
REM Find RP DRIVE LETTER
REM ----------------------
IF EXIST %CRM.FLAG.NORP% GOTO END_FINDRP

:ASSIGN_RP
ECHO [%time%][%~nx0] Find RP Drive Letter
FOR %%a IN ( c d e f g h i j k l m n o p q r s t u v w x y z ) DO (
  vol %%a: 2>NUL 1>NUL && IF EXIST "%%a:%CRM.RP.CHECKFILE%" IF NOT EXIST "%%a:%CRM.UCRM.CHECKFILE%" SET CRM.RP.DrvLetter=%%a:
)

ECHO [%time%][%~nx0] RP Drive Letter = %CRM.RP.DrvLetter%
IF [%CRM.RP.DrvLetter%]==[NONE] GOTO WHATEVER_RP

:END_FINDRP

REM ----------------------
REM RM Reserve
REM ----------------------
IF EXIST %CRM.RECOVERY.FLAG% GOTO END_RESERVEFILE
ECHO [%time%][%~nx0] RM Reserve
 
SET CRM.RESERVE.SrcPath=%CRM.RP.DrvLetter%\preload\RM_RESERVE\
IF EXIST %CRM.RESERVE.SrcPath% ( 
  ECHO [%time%][%~nx0] CSCRIPT.EXE /NOLOGO "%CRM.RESERVE.SrcPath%RevFile.vbs" "%CRM.RESERVE.SrcPath%Reserve.log" %CRM.UP.DrvLetter% "%CRM.RESERVE.SrcPath%"
  CSCRIPT.EXE /NOLOGO "%CRM.RESERVE.SrcPath%RevFile.vbs" "%CRM.RESERVE.SrcPath%Reserve.log" %CRM.UP.DrvLetter% "%CRM.RESERVE.SrcPath%"
)

:END_RESERVEFILE

REM ======================================================================================================================================================
REM
REM                                                           WHATEVER RP IS EXIST 
REM
REM ======================================================================================================================================================
:WHATEVER_RP
REM ----------------------
REM ASSIGN WINRE AND ESP DRIVE LETTER
REM ----------------------
SET HPRM.WINRE.PARTINDEX=
SET HPRM.ESP.PARTINDEX=

ECHO [%time%][%~nx0] Assign WinRE or ESP Drive Letter
SET CRM.TEMP=%CRM.RMLOG.UPPath%2ndSPE-PartitionInfo.cmd
ECHO [%time%][%~nx0] CALL %CRM.WorkingPath%PartInfo.exe %CRM.WorkingPath%WINREESP.ini %CRM.TEMP% HPRM
CALL %CRM.WorkingPath%PartInfo.exe %CRM.WorkingPath%WINREESP.ini %CRM.TEMP% HPRM
IF NOT EXIST %CRM.TEMP% (
	SET CRM.ERR.NUM=795
	SET CRM.ERR.MSG=Can't find [%CRM.TEMP%]
	GOTO END
)
CALL %CRM.TEMP%
CALL %CRM.TEMP%

IF DEFINED HPRM.WINRE.PARTINDEX (
	SET FixedDrvLetter=%CRM.WinRE.DrvLetter%
	SET CRM.SP=%CRM.WorkingPath%RemoveDrvLetter.sp
	DISKPART /S !CRM.SP!
	
	SET CRM.SP=%CRM.WorkingPath%AssignWINRE.sp
	DISKPART /S !CRM.SP!
	IF NOT [!errorlevel!]==[0] (
		SET CRM.ERR.NUM=795
		SET CRM.ERR.MSG=FAIL: DISKPART /S !CRM.SP!
		GOTO END
	)
)

IF DEFINED HPRM.ESP.PARTINDEX (
	SET FixedDrvLetter=%CRM.ESP.DrvLetter%
	SET CRM.SP=%CRM.WorkingPath%RemoveDrvLetter.sp
	DISKPART /S !CRM.SP!
	
	SET CRM.SP=%CRM.WorkingPath%AssignESP.sp
	DISKPART /S !CRM.SP!
	IF NOT [!errorlevel!]==[0] (
		SET CRM.ERR.NUM=795
		SET CRM.ERR.MSG=FAIL: DISKPART /S !CRM.SP!
		GOTO END
	)
)

REM ----------------------
REM Reagentc Setting
REM ----------------------
ECHO [%time%][%~nx0] Reagentc Function
SET CRM.Reagentc=%CRM.PostRMPath%ReagentcSetting.cmd
ECHO [%time%][%~nx0] CMD.EXE /C %CRM.Reagentc% %CRM.WinRE.DrvLetter% %CRM.UP.DrvLetter% %CRM.RP.DrvLetter%
CMD.EXE /C %CRM.Reagentc% %CRM.WinRE.DrvLetter% %CRM.UP.DrvLetter% %CRM.RP.DrvLetter%
ECHO [%time%][%~nx0] End

REM ----------------------
REM Deploy PBR
REM ----------------------
ECHO [%time%][%~nx0] Deploy PBR
SET CRM.CMD=%CRM.PostRMPath%DeployPBR.cmd
ECHO [%time%][%~nx0] CMD.EXE /C %CRM.CMD%
CMD.EXE /C %CRM.CMD% >> %CRM.RMLOG.UPPath%DeployPBR.log 
ECHO [%time%][%~nx0] End

REM ----------------------
REM Testsign
REM ----------------------
IF EXIST C:\system.sav\Flags\TestCert.flg (
	ECHO [%time%][%~nx0] Testsign
	ECHO [%time%][%~nx0] BCDEdit -set {bootloadersettings} testsigning on
	BCDEdit -set {bootloadersettings} testsigning on
)

REM ----------------------
REM Output Information
REM ----------------------
ECHO [%time%][%~nx0] Output Information
ECHO [%time%][%~nx0] BCD Table
ECHO [%time%][%~nx0] BCDEDIT -enum all
BCDEDIT -enum all >> %CRM.MSBCDLOG%

ECHO [%time%][%~nx0] Reagentc Information
ECHO [%time%][%~nx0] Reagentc /info
Reagentc /info >> %CRM.ReagentcLOG%

REM ----------------------
REM Create NOSWSETUP.FLG IF C:\SWSETUP WAS NOT EXIST
REM ----------------------
SET CRM.TMP=C:\SWSETUP\
SET CRM.FLAG.NOSWSETUP=C:\system.sav\flags\NOSWSETUP.flg
IF NOT EXIST %CRM.TMP% (
	ECHO [%time%][%~nx0] Can't find [%CRM.TMP%] and create [%CRM.FLAG.NOSWSETUP%]
	ECHO. >> %CRM.FLAG.NOSWSETUP%
)

REM ----------------------
REM Remove HP Recovery Media Creation shortcut if C:\System.sav\flags\NORP.FLG EXIST
REM ----------------------
SET CRM.FLAG.NORP=C:\System.sav\flags\NORP.flg
SET CRM.TMP="C:\ProgramData\Microsoft\Windows\Start Menu\Programs\HP Help and Support\HP Recovery Manager\HP Recovery Media Creation.lnk"
IF EXIST %CRM.FLAG.NORP% (
	ECHO [%time%][%~nx0] Find [%CRM.FLAG.NORP%] and remove [%CRM.TMP%]
	IF EXIST %CRM.TMP% Del /s /q %CRM.TMP%
)

SET CRM.TMP="C:\ProgramData\Microsoft\Windows\Start Menu\Programs\HP\HP Recovery Manager\HP Recovery Media Creation.lnk"
IF EXIST %CRM.FLAG.NORP% (
	ECHO [%time%][%~nx0] Find [%CRM.FLAG.NORP%] and remove [%CRM.TMP%]
	IF EXIST %CRM.TMP% Del /s /q %CRM.TMP%
)

SET CRM.TMP="C:\ProgramData\HP\Recovery\Links\RMC.lnk"
IF EXIST %CRM.FLAG.NORP% (
	ECHO [%time%][%~nx0] Find [%CRM.FLAG.NORP%] and remove [%CRM.TMP%]
	IF EXIST %CRM.TMP% Del /s /q %CRM.TMP%
)

REM ----------------------
REM Big File
REM ----------------------
ECHO [%time%][%~nx0] Big File
IF NOT EXIST c:\system.sav\util\BFMergeForSR.cmd (
	ECHO [%time%][%~nx0] Can't find [c:\system.sav\util\BFMergeForSR.cmd]
) ELSE (
	ECHO [%time%][%~nx0] CALL c:\system.sav\util\BFMergeForSR.cmd
	CALL c:\system.sav\util\BFMergeForSR.cmd
)
ECHO [%time%][%~nx0] END

REM ----------------------
REM For PE Team, Enable Kernel Debugging If EnableUSBDbg.FLG exist 
REM ----------------------
If EXIST C:\System.sav\Flags\EnableUSBDbg.FLG (
  If EXIST C:\Recovery\OEM\Point_B\Install.PI\EnableDebugMode.cmd (
    ECHO [%time%][%~nx0] CALL C:\Recovery\OEM\Point_B\Install.PI\EnableDebugMode.cmd 
    CALL C:\Recovery\OEM\Point_B\Install.PI\EnableDebugMode.cmd   
  )
)

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