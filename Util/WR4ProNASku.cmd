@ECHO OFF

SET PIN.WorkingPath=%~dp0
SET PIN.WorkingDrv=%~d0
SET PIN.FB.FILE=%PIN.WorkingPath%VARS.ini 


REM ----------------------
REM Get Windows build# 
REM ----------------------
SET PIN.WINDOWS.VERSION=0
ECHO [%time%][%~nx0] Get Windows Current build#
ECHO [%time%][%~nx0] Reg load HKLM\test %PIN.WorkingDrv%\windows\system32\config\software
Reg load HKLM\test %PIN.WorkingDrv%\windows\system32\config\software
ECHO [%time%][%~nx0] Reg query "HKLM\TEST\Microsoft\Windows NT\CurrentVersion" /v CurrentBuild
FOR /F "TOKENS=1,2* DELIMS= " %%i IN ('Reg query "HKLM\TEST\Microsoft\Windows NT\CurrentVersion" /v CurrentBuild') do (
	ECHO %%i %%j %%k
	IF /I "%%i"=="CurrentBuild" (SET PIN.WINDOWS.VERSION=%%k)
)
ECHO [%time%][%~nx0] Reg unload HKLM\test
Reg unload HKLM\test
ECHO [%time%][%~nx0] WINDOWS VERSION=%PIN.WINDOWS.VERSION%
IF NOT [%PIN.WINDOWS.VERSION%]==[14393] (
  ECHO [%time%][%~nx0] This is NOT RS1 Build
	GOTO END
)


REM ------------------------------
REM Check If Image is Pro(Vos.B) and NA(NaAc)
REM ------------------------------
ECHO [%time%][%~nx0] FIND /I "Vos.B=1" %PIN.FB.FILE% 
FIND /I "Vos.B=1" %PIN.FB.FILE%
IF NOT [%ErrorLevel%]==[0] (
  ECHO [%time%][%~nx0] Can't Find "Vos.B=1"
  ECHO [%time%][%~nx0] The image NOT include Vos.B ,and don't target the workaround 
	GOTO END
)

ECHO [%time%][%~nx0] FIND /I "NaAc=1" %PIN.FB.FILE% 
FIND /I "NaAc=1" %PIN.FB.FILE%
IF NOT [%ErrorLevel%]==[0] (
  ECHO [%time%][%~nx0] Can't Find "NaAc=1"
  ECHO [%time%][%~nx0] The image NOT include NaAc ,and don't target the workaround
	GOTO END
)

ECHO [%time%][%~nx0] This Image is Pro(Vos.B) and NA(NaAc)


REM ------------------------------
REM Set "SetupDisplayedProductKey"
REM ------------------------------
ECHO [%time%][%~nx0] reg.exe load HKLM\test %PIN.WorkingDrv%\windows\system32\config\Software
reg.exe load HKLM\test %PIN.WorkingDrv%\windows\system32\config\Software

ECHO [%time%][%~nx0] reg.exe query "HKLM\TEST\microsoft\Windows\CurrentVersion\Setup\OOBE" 
reg.exe query "HKLM\TEST\microsoft\Windows\CurrentVersion\Setup\OOBE"

ECHO [%TIME%][%~nx0] reg.exe add "HKLM\TEST\microsoft\Windows\CurrentVersion\Setup\OOBE" /v SetupDisplayedProductKey /t REG_DWORD /d 1 /f 
reg.exe add "HKLM\TEST\microsoft\Windows\CurrentVersion\Setup\OOBE" /v SetupDisplayedProductKey /t REG_DWORD /d 1 /f

ECHO [%time%][%~nx0] reg.exe query "HKLM\TEST\microsoft\Windows\CurrentVersion\Setup\OOBE" 
reg.exe query "HKLM\TEST\microsoft\Windows\CurrentVersion\Setup\OOBE"   

ECHO [%time%][%~nx0] reg.exe unload HKLM\test
reg.exe unload HKLM\test



REM ------------------------------
REM Delete "ProcessBiosKey"
REM ------------------------------
ECHO [%time%][%~nx0] reg.exe load HKLM\test %PIN.WorkingDrv%\windows\system32\config\SYSTEM
reg.exe load HKLM\test %PIN.WorkingDrv%\windows\system32\config\SYSTEM

ECHO [%time%][%~nx0] reg.exe query "HKLM\TEST\ControlSet001\Services\ClipSVC\Parameters" 
reg.exe query "HKLM\TEST\ControlSet001\Services\ClipSVC\Parameters"

ECHO [%TIME%][%~nx0] reg.exe DELETE "HKLM\TEST\ControlSet001\Services\ClipSVC\Parameters" /v ProcessBiosKey /f 
reg.exe DELETE "HKLM\TEST\ControlSet001\Services\ClipSVC\Parameters" /v ProcessBiosKey /f

ECHO [%time%][%~nx0] reg.exe query "HKLM\TEST\ControlSet001\Services\ClipSVC\Parameters" 
reg.exe query "HKLM\TEST\ControlSet001\Services\ClipSVC\Parameters"   

ECHO [%time%][%~nx0] reg.exe unload HKLM\test
reg.exe unload HKLM\test



:END
ECHO [%time%][%~nx0] END
REM EXIT
