@ECHO OFF
setlocal enabledelayedexpansion

REM ====================================================
REM   Setting Required Variable
REM ====================================================
SET CRM.ERR.NUM=0
SET CRM.ERR.MSG=NO ERROR DURING %~n0 PROCESSING

SET CRM.UP.DrvLetter=C:

SET CRM.FLAG.NOHPRERM=%CRM.UP.DrvLetter%\system.sav\flags\NOHPRERM.FLG
SET CRM.FLAG.NORP=%CRM.UP.DrvLetter%\system.sav\flags\NORP.FLG

SET CRM.UP.FS=NTFS
SET CRM.UP.Name=WINDOWS
SET CRM.UP.RESTORE.DRIVELETTER=Z:

SET CRM.WinRE.DrvLetter=W:
SET CRM.WinRE.GUID=de94bba4-06d1-4d40-a16a-bfd50179d6ac
SET CRM.WINRE.Name=WINRE
SET CRM.WINRE.ATTRIBUTE=0x8000000000000001
SET CRM.WINRE.FS=NTFS

SET CRM.ESP.DrvLetter=P:
SET CRM.ESP.GUID=c12a7328-f81f-11d2-ba4b-00a0c93ec93b
SET CRM.ESP.FS=FAT32
SET CRM.ESP.NAME=SYSTEM

SET CRM.DATA.SIZE.BYTE=0
SET CRM.DATA.SIZE.MB=0

SET CRM.RMLOG.UPPath=%CRM.UP.DrvLetter%\system.sav\logs\RM\
SET CRM.DeployToolPath=%CRM.UP.DrvLetter%\RM\RERM\DeployRP\
SET CRM.PBR.Src=%CRM.UP.DrvLetter%\Recovery\OEM\
SET CRM.PBR.Dest=%CRM.UP.DrvLetter%\Recovery\OEM\

SET CRM.RESERVE.FolderName=RM_RESERVE
SET CRM.RESERVE.Src=%CRM.DeployToolPath%\RM_RESERVE\
SET CRM.RESERVE.Dest=%CRM.UP.DrvLetter%\Recovery\OEM\RM_RESERVE\

SET CRM.PATCH.FolderName=RM_PATCH
SET CRM.PATCH.Src=%CRM.UP.DrvLetter%\RM\RERM\DeployRP\RM_PATCH\
SET CRM.PATCH.Dest=%CRM.UP.DrvLetter%\Recovery\OEM\RM_PATCH\

REM ====================================================
REM   START
REM ====================================================

REM ----------------------
REM Prepare Required Files and Folders For PBR
REM ----------------------

SET CRM.TMP=%CRM.PBR.Src%ReCustomization.xml
IF EXIST %CRM.FLAG.NORP% (
  IF EXIST %CRM.TMP% ( 
  	ECHO [%time%][%~nx0] Found %CRM.FLAG.NOHPRERM%, and delete %CRM.TMP%
  	ATTRIB -S -H -R %CRM.TMP%
  	DEL /F /Q %CRM.TMP%
  	IF NOT EXIST %CRM.TMP% ECHO [%time%][%~nx0] Deleted %CRM.TMP%  
  )   
)

REM ----------------------
REM Repartition Script for PBR Bare Metal
REM ----------------------
ECHO [%time%][%~nx0] Query partition Information
SET CRM.TEMP=%CRM.RMLOG.UPPath%PartInfo_DeployPBR.cmd
ECHO [%time%][%~nx0] CALL %CRM.DeployToolPath%PartInfo.exe %CRM.DeployToolPath%DASHPartition.ini  %CRM.TEMP% HPRM
CALL %CRM.DeployToolPath%PartInfo.exe %CRM.DeployToolPath%DASHPartition.ini  %CRM.TEMP% HPRM
IF NOT EXIST %CRM.TEMP% (
	SET CRM.ERR.NUM=795
	SET CRM.ERR.MSG=Can't find [%CRM.TEMP%]
	GOTO END
)
CALL %CRM.TEMP%
CALL %CRM.TEMP%



REM == Find Data ==
SET /A CRM.DISKINDEX=%HPRM.UP.DISKINDEX%
SET CRM.GetValue=0
SET CRM.FINDDATA=0
SET CRM.DATA.PARTINDEX=99
SET CRM.RUNONCE=0
FOR /F "tokens=1-9* delims=[]^.=" %%i IN ('set') do (
	REM ECHO %%i %%j %%k %%l %%m %%n %%o
	IF /I [%%i.%%j.%%k.%%l.%%n.%%o]==[HPRM.DISK.%CRM.DISKINDEX%.PART.NAME.DATA] (
		ECHO %%i %%j %%k %%l %%m %%n %%o
		SET CRM.FINDDATA=1
		SET CRM.DATA.PARTINDEX=%%m
	)
  
	IF /I [!CRM.FINDDATA!]==[1] IF /I [!CRM.RUNONCE!]==[0] (
		IF /I [%%i.%%j.%%k.%%l.%%m.%%n]==[HPRM.DISK.%CRM.DISKINDEX%.PART.!CRM.DATA.PARTINDEX!.SIZE] (
			ECHO %%i %%j %%k %%l %%m %%n %%o
			SET CRM.GetValue=%%o
		)  
	)
)

SET CRM.DATA.SIZE.BYTE=%CRM.GetValue%
ECHO [%time%][%~nx0] Find the Data Partition and size=%CRM.DATA.SIZE.BYTE% bytes

for /f "delims=" %%a in ('cscript //nologo %CRM.DeployToolPath%Byte2KBMBGB.vbs MB %CRM.DATA.SIZE.BYTE%') do (
	SET CRM.DATA.SIZE.MB=%%a
)
ECHO [%time%][%~nx0] Find the Data Partition and size=%CRM.DATA.SIZE.MB% MB
REM ===============






SET CRM.ESP.SIZE.MB=0
for /f "delims=" %%a in ('cscript //nologo %CRM.DeployToolPath%Byte2KBMBGB.vbs MB %HPRM.ESP.SIZE%') do (
	SET CRM.ESP.SIZE.MB=%%a
)
ECHO [%time%][%~nx0] ESP Size = %CRM.ESP.SIZE.MB% MB

SET CRM.ESP.OFFSET.KB=0
for /f "delims=" %%a in ('cscript //nologo %CRM.DeployToolPath%Byte2KBMBGB.vbs KB %HPRM.ESP.OFFSET%') do (
	SET CRM.ESP.OFFSET.KB=%%a
)
ECHO [%time%][%~nx0] ESP OFFSET = %CRM.ESP.OFFSET.KB% KB

SET CRM.MSR.SIZE.MB=0
for /f "delims=" %%a in ('cscript //nologo %CRM.DeployToolPath%Byte2KBMBGB.vbs MB %HPRM.MSR.SIZE%') do (
	SET CRM.MSR.SIZE.MB=%%a
)
ECHO [%time%][%~nx0] MSR Size = %CRM.MSR.SIZE.MB% MB

SET CRM.MSR.OFFSET.KB=0
for /f "delims=" %%a in ('cscript //nologo %CRM.DeployToolPath%Byte2KBMBGB.vbs KB %HPRM.MSR.OFFSET%') do (
	SET CRM.MSR.OFFSET.KB=%%a
)
ECHO [%time%][%~nx0] MSR OFFSET = %CRM.ESP.OFFSET.KB% KB

SET CRM.UP.SIZE.MB=0
for /f "delims=" %%a in ('cscript //nologo %CRM.DeployToolPath%Byte2KBMBGB.vbs MB %HPRM.UP.SIZE%') do (
	SET CRM.UP.SIZE.MB=%%a
)
ECHO [%time%][%~nx0] UP Size = %CRM.UP.SIZE.MB% MB

SET CRM.UP.OFFSET.KB=0
for /f "delims=" %%a in ('cscript //nologo %CRM.DeployToolPath%Byte2KBMBGB.vbs KB %HPRM.UP.OFFSET%') do (
	SET CRM.UP.OFFSET.KB=%%a
)
ECHO [%time%][%~nx0] UP OFFSET = %CRM.UP.OFFSET.KB% KB

SET CRM.WINRE.SIZE.MB=0
for /f "delims=" %%a in ('cscript //nologo %CRM.DeployToolPath%Byte2KBMBGB.vbs MB %HPRM.WINRE.SIZE%') do (
	SET CRM.WINRE.SIZE.MB=%%a
)
ECHO [%time%][%~nx0] WINRE Size = %CRM.WINRE.SIZE.MB% MB

SET CRM.WINRE.OFFSET.KB=0
for /f "delims=" %%a in ('cscript //nologo %CRM.DeployToolPath%Byte2KBMBGB.vbs KB %HPRM.WINRE.OFFSET%') do (
	SET CRM.WINRE.OFFSET.KB=%%a
)
ECHO [%time%][%~nx0] WINRE OFFSET = %CRM.WINRE.OFFSET.KB% KB

SET CRM.BareMetal.SP=%CRM.PBR.Dest%Repartition.sp
IF EXIST %CRM.BareMetal.SP% DEL /F /Q %CRM.BareMetal.SP%

                                                         
ECHO convert gpt                                                                >> %CRM.BareMetal.SP%
ECHO REM == ESP ==                                                              >> %CRM.BareMetal.SP%
ECHO CREATE PARTITION EFI SIZE=%CRM.ESP.SIZE.MB%                                >> %CRM.BareMetal.SP%
ECHO FORMAT FS=%CRM.ESP.FS% LABEL=%CRM.ESP.Name% QUICK                          >> %CRM.BareMetal.SP%
ECHO ASSIGN LETTER=%CRM.ESP.DrvLetter%                                          >> %CRM.BareMetal.SP%
ECHO.                                                                           >> %CRM.BareMetal.SP%
ECHO REM == MSR ==                                                              >> %CRM.BareMetal.SP%
ECHO CREATE PARTITION MSR SIZE=%CRM.MSR.SIZE.MB%                                >> %CRM.BareMetal.SP%
ECHO.                                                                           >> %CRM.BareMetal.SP%
ECHO CREATE PARTITION PRIMARY                                                   >> %CRM.BareMetal.SP%
ECHO.                                                                           >> %CRM.BareMetal.SP%
ECHO SHRINK MINIMUM=5                                                           >> %CRM.BareMetal.SP%
ECHO SHRINK MINIMUM=%CRM.WINRE.SIZE.MB%                                         >> %CRM.BareMetal.SP%
REM IF NOT [%CRM.DATA.SIZE.MB%]==[0] (
REM ECHO SHRINK MINIMUM=%CRM.DATA.SIZE.MB%                                          >> %CRM.BareMetal.SP%              
REM )
ECHO.                                                                           >> %CRM.BareMetal.SP%
ECHO REM == UP ==                                                               >> %CRM.BareMetal.SP%
ECHO FORMAT QUICK FS=%CRM.UP.FS% LABEL=%CRM.UP.NAME%                            >> %CRM.BareMetal.SP%
ECHO ASSIGN LETTER=%CRM.UP.RESTORE.DRIVELETTER%                                 >> %CRM.BareMetal.SP%
ECHO.                                                                           >> %CRM.BareMetal.SP%
ECHO REM == WINRE ==                                                            >> %CRM.BareMetal.SP%
ECHO CREATE PARTITION PRIMARY SIZE=%CRM.WINRE.SIZE.MB%                          >> %CRM.BareMetal.SP%
ECHO FORMAT QUICK FS=%CRM.WINRE.FS% LABEL=%CRM.WINRE.Name%                      >> %CRM.BareMetal.SP%
ECHO SET ID=%CRM.WINRE.GUID% OVERRIDE                                           >> %CRM.BareMetal.SP%
ECHO GPT ATTRIBUTES=%CRM.WINRE.ATTRIBUTE%                                       >> %CRM.BareMetal.SP%
ECHO ASSIGN LETTER=%CRM.WINRE.DrvLetter%                                        >> %CRM.BareMetal.SP%

REM IF NOT [%CRM.DATA.SIZE.MB%]==[0] (
REM ECHO REM == DATA ==                                                             >> %CRM.BareMetal.SP%
REM ECHO CREATE PARTITION PRIMARY SIZE=%CRM.DATA.SIZE.MB%                           >> %CRM.BareMetal.SP%
REM ECHO FORMAT QUICK FS=%CRM.UP.FS% LABEL=DATA                                     >> %CRM.BareMetal.SP%
REM ECHO ASSIGN                                                                     >> %CRM.BareMetal.SP%
REM ) 
ECHO EXIT >> %CRM.BareMetal.SP%                                                 >> %CRM.BareMetal.SP%


REM ----------------------
REM RM Reserve
REM ----------------------
ECHO [%time%][%~nx0] RM Reserve
ECHO [%time%][%~nx0] CSCRIPT.EXE /NOLOGO %CRM.RESERVE.Src%RevFile.vbs %CRM.RESERVE.Src%Reserve.log %CRM.UP.DrvLetter% %CRM.RESERVE.Src%
CSCRIPT.EXE /NOLOGO %CRM.RESERVE.Src%RevFile.vbs %CRM.RESERVE.Src%Reserve.log %CRM.UP.DrvLetter% %CRM.RESERVE.Src%
ECHO [%time%][%~nx0] Move Reserved File to RP Path
SET CRM.COPY.SRC=%CRM.RESERVE.Src%
SET CRM.COPY.DEST=%CRM.RESERVE.Dest%
CALL :CreateFolder "%CRM.COPY.DEST%"
ECHO [%time%][%~nx0] XCOPY /S /E /Y /I /R /H %CRM.COPY.SRC%*.* "%CRM.COPY.Dest%"
XCOPY /S /E /Y /I /R /H %CRM.COPY.SRC%*.* "%CRM.COPY.Dest%"
IF NOT [%errorlevel%]==[0] (
	SET CRM.ERR.NUM=795
	SET CRM.ERR.MSG=FAIL: XCOPY /S /E /Y /I /R /H %CRM.COPY.SRC%*.* "%CRM.COPY.Dest%"
	GOTO END
)



REM ----------------------
REM RM Patch
REM ----------------------
ECHO [%time%][%~nx0] RM Patch
ECHO [%time%][%~nx0] Move RM Patch File to RP Path
SET CRM.COPY.SRC=%CRM.PATCH.Src%
SET CRM.COPY.DEST=%CRM.PATCH.Dest%
CALL :CreateFolder "%CRM.COPY.DEST%"
ECHO [%time%][%~nx0] XCOPY /S /E /Y /I /R /H %CRM.COPY.SRC%*.* "%CRM.COPY.Dest%"
XCOPY /S /E /Y /I /R /H %CRM.COPY.SRC%*.* "%CRM.COPY.Dest%"
IF NOT [%errorlevel%]==[0] (
	SET CRM.ERR.NUM=795
	SET CRM.ERR.MSG=FAIL: XCOPY /S /E /Y /I /R /H %CRM.COPY.SRC%*.* "%CRM.COPY.Dest%"
	GOTO END
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
	
	ECHO [%time%][%~nx0] %CRM.ERR.MSG% >> %CRM.RMErr.UPFullPath%
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