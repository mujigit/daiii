@ECHO OFF

SET CRM.WINRE.DrvLetter=%1
SET CRM.ESP.DrvLetter=%2
SET CRM.UP.DrvLetter=%3

SET CRM.LOG=%CRM.UP.DrvLetter%\SYSTEM.SAV\LOGS\RM\F11Setting.log
SET CRM.HPBCDLOG=%CRM.UP.DrvLetter%\SYSTEM.SAV\LOGS\RM\F11-HPBCDTable.log


IF EXIST %CRM.LOG% DEL /F /Q %CRM.LOG%

ECHO [%time%][%~nx0] xcopy /s /e /y /i /r /h  %CRM.ESP.DrvLetter%\EFI\Microsoft\*.* %CRM.ESP.DrvLetter%\EFI\HP\*.*  >>  %CRM.LOG%
xcopy /s /e /y /i /r /h  %CRM.ESP.DrvLetter%\EFI\Microsoft\*.* %CRM.ESP.DrvLetter%\EFI\HP\*.*  >>  %CRM.LOG%


ECHO [%time%][%~nx0] bcdedit /createstore %CRM.ESP.DrvLetter%\BCD  >>  %CRM.LOG%
bcdedit /createstore %CRM.ESP.DrvLetter%\BCD  >>  %CRM.LOG%


REM ====================================================== >>  %CRM.LOG%
REM Create Windows Boot Manager                            >>  %CRM.LOG%
REM ====================================================== >>  %CRM.LOG%
ECHO [%time%][%~nx0] bcdedit /store %CRM.ESP.DrvLetter%\BCD /create {bootmgr} /d "Windows Boot Manager"  >>  %CRM.LOG%
bcdedit /store %CRM.ESP.DrvLetter%\BCD /create {bootmgr} /d "Windows Boot Manager"  >>  %CRM.LOG%

ECHO [%time%][%~nx0] bcdedit /store %CRM.ESP.DrvLetter%\BCD /set {bootmgr} device partition=%CRM.ESP.DrvLetter%  >>  %CRM.LOG%
bcdedit /store %CRM.ESP.DrvLetter%\BCD /set {bootmgr} device partition=%CRM.ESP.DrvLetter%  >>  %CRM.LOG%

ECHO [%time%][%~nx0] bcdedit /store %CRM.ESP.DrvLetter%\BCD /set {bootmgr} locale en-US  >>  %CRM.LOG%
bcdedit /store %CRM.ESP.DrvLetter%\BCD /set {bootmgr} locale en-US  >>  %CRM.LOG%

ECHO [%time%][%~nx0] bcdedit /store %CRM.ESP.DrvLetter%\BCD /set {bootmgr} integrityservices Enable  >>  %CRM.LOG%
bcdedit /store %CRM.ESP.DrvLetter%\BCD /set {bootmgr} integrityservices Enable  >>  %CRM.LOG%





REM ====================================================== >>  %CRM.LOG%
REM Create Ramdisk device options for the boot.sdi file    >>  %CRM.LOG%
REM ====================================================== >>  %CRM.LOG%
ECHO [%time%][%~nx0] bcdedit /store %CRM.ESP.DrvLetter%\BCD /create {7619dcc8-fafe-11d9-b411-000476eba25f} /d "Windows Recovery" /device  >>  %CRM.LOG%
bcdedit /store %CRM.ESP.DrvLetter%\BCD /create {7619dcc8-fafe-11d9-b411-000476eba25f} /d "Windows Recovery" /device  >>  %CRM.LOG%

ECHO [%time%][%~nx0] bcdedit /store %CRM.ESP.DrvLetter%\BCD /set {7619dcc8-fafe-11d9-b411-000476eba25f} ramdisksdidevice partition=%CRM.WinRE.DrvLetter%  >>  %CRM.LOG%
bcdedit /store %CRM.ESP.DrvLetter%\BCD /set {7619dcc8-fafe-11d9-b411-000476eba25f} ramdisksdidevice partition=%CRM.WinRE.DrvLetter%  >>  %CRM.LOG%

ECHO [%time%][%~nx0] bcdedit /store %CRM.ESP.DrvLetter%\BCD /set {7619dcc8-fafe-11d9-b411-000476eba25f} ramdisksdipath \Recovery\WindowsRE\boot.sdi  >>  %CRM.LOG%
bcdedit /store %CRM.ESP.DrvLetter%\BCD /set {7619dcc8-fafe-11d9-b411-000476eba25f} ramdisksdipath \Recovery\WindowsRE\boot.sdi  >>  %CRM.LOG%



REM ====================================================== >>  %CRM.LOG%
REM Create WinRE Entry and Set it as default               >>  %CRM.LOG%
REM ====================================================== >>  %CRM.LOG%
ECHO [%time%][%~nx0] bcdedit /store %CRM.ESP.DrvLetter%\BCD /create {22222222-2222-2222-2222-222222222222} /d "Windows Recovery Environment" /application osloader  >>  %CRM.LOG%
bcdedit /store %CRM.ESP.DrvLetter%\BCD /create {22222222-2222-2222-2222-222222222222} /d "Windows Recovery Environment" /application osloader  >>  %CRM.LOG%

ECHO [%time%][%~nx0] bcdedit /store %CRM.ESP.DrvLetter%\BCD /set {bootmgr} default {22222222-2222-2222-2222-222222222222}  >>  %CRM.LOG%
bcdedit /store %CRM.ESP.DrvLetter%\BCD /set {bootmgr} default {22222222-2222-2222-2222-222222222222}  >>  %CRM.LOG%

ECHO [%time%][%~nx0] bcdedit /store %CRM.ESP.DrvLetter%\BCD /set {bootmgr} displayorder {22222222-2222-2222-2222-222222222222}  >>  %CRM.LOG%
bcdedit /store %CRM.ESP.DrvLetter%\BCD /set {bootmgr} displayorder {22222222-2222-2222-2222-222222222222}  >>  %CRM.LOG%



REM ====================================================== >>  %CRM.LOG%
REM Setting WinRE Entry                                    >>  %CRM.LOG%
REM ====================================================== >>  %CRM.LOG%
ECHO [%time%][%~nx0] bcdedit /store %CRM.ESP.DrvLetter%\BCD /set {default} device ramdisk=[%CRM.WinRE.DrvLetter%]\Recovery\WindowsRE\winre.wim,{7619dcc8-fafe-11d9-b411-000476eba25f}  >>  %CRM.LOG%
bcdedit /store %CRM.ESP.DrvLetter%\BCD /set {default} device ramdisk=[%CRM.WinRE.DrvLetter%]\Recovery\WindowsRE\winre.wim,{7619dcc8-fafe-11d9-b411-000476eba25f}  >>  %CRM.LOG%

ECHO [%time%][%~nx0] bcdedit /store %CRM.ESP.DrvLetter%\BCD /set {default} path \Windows\System32\winload.efi  >>  %CRM.LOG%
bcdedit /store %CRM.ESP.DrvLetter%\BCD /set {default} path \Windows\System32\winload.efi  >>  %CRM.LOG%

ECHO [%time%][%~nx0] bcdedit /store %CRM.ESP.DrvLetter%\BCD /set {default} locale en-US  >>  %CRM.LOG%
bcdedit /store %CRM.ESP.DrvLetter%\BCD /set {default} locale en-US  >>  %CRM.LOG%

ECHO [%time%][%~nx0] bcdedit /store %CRM.ESP.DrvLetter%\BCD /set {default} displaymessage "Recovery"  >>  %CRM.LOG%
bcdedit /store %CRM.ESP.DrvLetter%\BCD /set {default} displaymessage "Recovery"  >>  %CRM.LOG%

ECHO [%time%][%~nx0] bcdedit /store %CRM.ESP.DrvLetter%\BCD /set {default} osdevice ramdisk=[%CRM.WinRE.DrvLetter%]\Recovery\WindowsRE\winre.wim,{7619dcc8-fafe-11d9-b411-000476eba25f}  >>  %CRM.LOG%
bcdedit /store %CRM.ESP.DrvLetter%\BCD /set {default} osdevice ramdisk=[%CRM.WinRE.DrvLetter%]\Recovery\WindowsRE\winre.wim,{7619dcc8-fafe-11d9-b411-000476eba25f}  >>  %CRM.LOG%

ECHO [%time%][%~nx0] bcdedit /store %CRM.ESP.DrvLetter%\BCD /set {default} systemroot \Windows  >>  %CRM.LOG%
bcdedit /store %CRM.ESP.DrvLetter%\BCD /set {default} systemroot \Windows  >>  %CRM.LOG%

ECHO [%time%][%~nx0] bcdedit /store %CRM.ESP.DrvLetter%\BCD /set {default} nx OptIn  >>  %CRM.LOG%
bcdedit /store %CRM.ESP.DrvLetter%\BCD /set {default} nx OptIn  >>  %CRM.LOG%

ECHO [%time%][%~nx0] bcdedit /store %CRM.ESP.DrvLetter%\BCD /set {default} bootmenupolicy Standard  >>  %CRM.LOG%
bcdedit /store %CRM.ESP.DrvLetter%\BCD /set {default} bootmenupolicy Standard  >>  %CRM.LOG%

ECHO [%time%][%~nx0] bcdedit /store %CRM.ESP.DrvLetter%\BCD /set {default} winpe Yes  >>  %CRM.LOG%
bcdedit /store %CRM.ESP.DrvLetter%\BCD /set {default} winpe Yes  >>  %CRM.LOG%

ECHO [%time%][%~nx0] MOVE %CRM.ESP.DrvLetter%\BCD %CRM.ESP.DrvLetter%\EFI\HP\Boot\  >>  %CRM.LOG%
MOVE %CRM.ESP.DrvLetter%\BCD %CRM.ESP.DrvLetter%\EFI\HP\Boot\  >>  %CRM.LOG%

SET CRM.TMP=%CRM.ESP.DrvLetter%\BCD.LOG
IF EXIST %CRM.TMP% (
	ECHO [%time%][%~nx0] DEL /F /Q %CRM.TMP% >>  %CRM.LOG%
	ATTRIB -s -H -I -A -R %CRM.TMP% >>  %CRM.LOG%
	DEL /Q /F %CRM.TMP% >>  %CRM.LOG%
)

REM ECHO [%time%][%~nx0] COPY /Y  %CRM.ESP.DrvLetter%\EFI\HP\Boot\boot.sdi %CRM.WINRE.DrvLetter%\recovery\WindowsRE\ >>  %CRM.LOG%
REM ATTRIB -s -H %CRM.ESP.DrvLetter%\EFI\HP\Boot\boot.sdi
REM COPY /Y  %CRM.ESP.DrvLetter%\EFI\HP\Boot\boot.sdi %CRM.WINRE.DrvLetter%\recovery\WindowsRE\ >>  %CRM.LOG%
REM ATTRIB +s +H %CRM.ESP.DrvLetter%\EFI\HP\Boot\boot.sdi
REM ATTRIB +s +H %CRM.WINRE.DrvLetter%\recovery\WindowsRE\boot.sdi
REM 
REM ECHO [%time%][%~nx0] ATTRIB %CRM.WINRE.DrvLetter%\recovery\WindowsRE\boot.sdi >>  %CRM.LOG%
REM ATTRIB %CRM.WINRE.DrvLetter%\recovery\WindowsRE\boot.sdi >>  %CRM.LOG%


REM ----------------------
REM Output Information
REM ----------------------
ECHO [%time%][%~nx0] HP BCD Table >>  %CRM.LOG%
ECHO [%time%][%~nx0] BCDEDIT -store %CRM.ESP.DrvLetter%\EFI\HP\Boot\BCD -enum all  >>  %CRM.LOG%
BCDEDIT -store %CRM.ESP.DrvLetter%\EFI\HP\Boot\BCD -enum all >> %CRM.HPBCDLOG%

EXIT