@ECHO OFF

SET CRM.WINRE.DrvLetter=%1
SET CRM.UP.DrvLetter=%2
SET CRM.RP.DrvLetter=%3
SET CRM.ImageFolderName=preload
SET CRM.RestoreIndex=2
SET /A CRM.PBROEMEntry=1
SET CRM.BCD.OSGUID=NONE

SET CRM.LOG=%CRM.UP.DrvLetter%\SYSTEM.SAV\LOGS\RM\ReagentcSetting.log

SET CRM.FLAG.NORP=%CRM.UP.DrvLetter%\SYSTEM.SAV\FLAGS\NORP.FLG

IF EXIST %CRM.LOG% DEL /F /Q %CRM.LOG%


REM ----------------------
REM Check If setting OS Image with reagentc setting
REM ----------------------
IF EXIST %CRM.FLAG.NORP% SET /A CRM.PBROEMEntry=0
IF [%CRM.RP.DrvLetter%]==[NONE] SET /A CRM.PBROEMEntry=0


REM ----------------------
REM ReAgentc Setting
REM ----------------------
ECHO [%time%][%~nx0] %CRM.UP.DrvLetter%\Windows\System32\Reagentc.exe /Setreimage /Path "%CRM.WinRE.DrvLetter%\Recovery\WindowsRE" /Target %CRM.UP.DrvLetter%\Windows  >>  %CRM.LOG%
CMD.EXE /C %CRM.UP.DrvLetter%\Windows\System32\Reagentc.exe /Setreimage /Path "%CRM.WinRE.DrvLetter%\Recovery\WindowsRE" /Target %CRM.UP.DrvLetter%\Windows  >>  %CRM.LOG%

IF [%CRM.PBROEMEntry%]==[1] (
	ECHO [%time%][%~nx0] %CRM.UP.DrvLetter%\Windows\System32\Reagentc.exe /setbootshelllink /configfile %CRM.WINRE.DrvLetter%\Recovery\BootMenu\AddDiagnosticsToolToBootMenu.xml /target %CRM.UP.DrvLetter%\windows  >>  %CRM.LOG%
	CMD.EXE /C %CRM.UP.DrvLetter%\Windows\System32\Reagentc.exe /setbootshelllink /configfile %CRM.WINRE.DrvLetter%\Recovery\BootMenu\AddDiagnosticsToolToBootMenu.xml /target %CRM.UP.DrvLetter%\windows  >>  %CRM.LOG%
)

FOR /F "TOKENS=1,2* DELIMS==" %%i IN ('CSCRIPT /NOLOGO %CRM.UP.DrvLetter%\system.sav\util\PostRM\QueryOSGUID.vbs C:\system.sav\logs\RM\BCD4Reagentc.log') do (
	ECHO [%time%][%~nx0] %%i=%%j
	IF /I [%%i]==[OSGUID] SET CRM.BCD.OSGUID=%%j
)

ECHO [%time%][%~nx0] %CRM.UP.DrvLetter%\Windows\System32\Reagentc.exe /Enable /osguid %CRM.BCD.OSGUID% >>  %CRM.LOG%
CMD.EXE /C %CRM.UP.DrvLetter%\Windows\System32\Reagentc.exe /Enable /osguid %CRM.BCD.OSGUID% >>  %CRM.LOG%
IF NOT [%errorlevel%]==[0] (
	ECHO [%time%][%~nx0] %CRM.UP.DrvLetter%\Windows\System32\Reagentc.exe /Enable /auditmode >>  %CRM.LOG%
	CMD.EXE /C %CRM.UP.DrvLetter%\Windows\System32\Reagentc.exe /Enable /auditmode  >>  %CRM.LOG%
)

ECHO [%time%][%~nx0] %CRM.UP.DrvLetter%\Windows\System32\Reagentc.exe /info /target %CRM.UP.DrvLetter%\Windows  >>  %CRM.LOG%
CMD.EXE /C %CRM.UP.DrvLetter%\Windows\System32\Reagentc.exe /info /target %CRM.UP.DrvLetter%\Windows  >>  %CRM.LOG%



REM ----------------------
REM Check if WINRE:\Recovery\WindowsRE\boot.sdi exist, to avoid F11 BSOD: 0xc000000f 
REM ----------------------
SET CRM.SRC=%CRM.UP.DrvLetter%\SYSTEM.SAV\util\PostRM\boot.sdi
SET CRM.DEST=%CRM.WINRE.DrvLetter%\Recovery\WindowsRE\boot.sdi

IF NOT EXIST %CRM.DEST% (
	ECHO [%time%][%~nx0] COPY /Y %CRM.SRC% %CRM.DEST% >>  %CRM.LOG% 
	COPY /Y %CRM.SRC% %CRM.DEST% >>  %CRM.LOG%  
) 

ECHO [%time%][%~nx0] END  >>  %CRM.LOG%

GOTO END


:END
EXIT