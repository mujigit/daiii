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
REM If HKLM\Software\Microsoft\MSDTC [SysprepInProgress=1], set it to 0
REM ------------------------------
SET PIN.SysprepInProgress=999
ECHO [%time%][%~nx0] reg.exe load HKLM\test %PIN.WorkingDrv%\windows\system32\config\Software
reg.exe load HKLM\test %PIN.WorkingDrv%\windows\system32\config\Software

ECHO [%time%][%~nx0] reg.exe query "HKLM\TEST\Microsoft\MSDTC"
reg.exe query "HKLM\TEST\Microsoft\MSDTC"

FOR /F "TOKENS=1,2* DELIMS= " %%i IN ('Reg query "HKLM\TEST\Microsoft\MSDTC" /v SysprepInProgress') do (
	ECHO %%i %%j %%k
	IF /I "%%i"=="SysprepInProgress" (SET PIN.SysprepInProgress=%%k)
)

IF [%PIN.SysprepInProgress%]==[999] (
  ECHO [%time%][%~nx0] Can't Find SysprepInProgress
) ELSE (
  ECHO [%time%][%~nx0] SysprepInProgress = %PIN.SysprepInProgress%
  IF /I [%PIN.SysprepInProgress%]==[0x1] (
    ECHO [%TIME%][%~nx0] reg.exe add "HKLM\TEST\Microsoft\MSDTC" /v SysprepInProgress /t REG_DWORD /d 0 /f 
    reg.exe add "HKLM\TEST\Microsoft\MSDTC" /v SysprepInProgress /t REG_DWORD /d 0 /f
  )
)

ECHO [%time%][%~nx0] reg.exe query "HKLM\TEST\Microsoft\MSDTC"
reg.exe query "HKLM\TEST\Microsoft\MSDTC"

ECHO [%time%][%~nx0] reg.exe unload HKLM\test
reg.exe unload HKLM\test


:END
ECHO [%time%][%~nx0] END
REM EXIT