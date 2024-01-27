REM ========================================================
REM   Template Version: 2.00
REM ========================================================

@ECHO OFF
SETLOCAL
SET APP_NAME=HP Windows Image Diagnostic Tools - CPS
SET APP_LOG=C:\System.sav\LOGS\BB\%~n0.LOG
IF NOT EXIST C:\System.sav\LOGS\BB MD C:\System.sav\LOGS\BB

IF exist C:\System.sav\Flags\RImage.flg        ECHO Recovery process [RImage.flg]......., skip diagnostic >> %APP_LOG% & ECHO RESULT=PASSED >> %APP_LOG% & ENDLOCAL & goto :EOF
if exist c:\System.sav\Flags\RMSysRecovery.flg ECHO Recovery process [RMSysRecovery.flg], skip diagnostic >> %APP_LOG% & ECHO RESULT=PASSED >> %APP_LOG% & ENDLOCAL & goto :EOF
IF exist C:\System.sav\Flags\UCRD.flg          ECHO Recovery process [UCRD.flg]........., skip diagnostic >> %APP_LOG% & ECHO RESULT=PASSED >> %APP_LOG% & ENDLOCAL & goto :EOF
IF exist C:\System.sav\Flags\PBR.flg           ECHO Recovery process [PBR.flg],........., skip diagnostic >> %APP_LOG% & ECHO RESULT=PASSED >> %APP_LOG% & ENDLOCAL & goto :EOF
IF exist C:\System.sav\Flags\PBRBareMetal.flg  ECHO Recovery process [PBRBareMetal.flg]., skip diagnostic >> %APP_LOG% & ECHO RESULT=PASSED >> %APP_LOG% & ENDLOCAL & goto :EOF
IF exist C:\System.sav\Flags\SSRD.flg          ECHO Recovery process [SSRD.flg]........., skip diagnostic >> %APP_LOG% & ECHO RESULT=PASSED >> %APP_LOG% & ENDLOCAL & goto :EOF
if exist C:\System.sav\Util\SSRD.flg           ECHO Recovery process [SSRD.flg]........., skip diagnostic >> %APP_LOG% & ECHO RESULT=PASSED >> %APP_LOG% & ENDLOCAL & goto :EOF


ECHO ############################################################# >> %APP_LOG%
ECHO  [%DATE%]                                                     >> %APP_LOG%
ECHO  [%TIME%] Beginning of the %~nx0                              >> %APP_LOG%
ECHO ############################################################# >> %APP_LOG%

REM ------------------- Script Entry ------------------------
set imgfailed=true

for /f "tokens=1,2 delims==." %%i in ('wmic /namespace:"\\root\HP\InstrumentedBIOS" path HP_BIOSSetting where ^(name^="Enter Feature Byte" OR name^="Feature Byte"^) get value /value') do (if /i %%i == Value set "FByte=%%~j")
if not defined FByte echo Feature Byte not found, ignore checking. >>%APP_LOG% & exit /b 0
echo Feature Byte is "%FByte%" >>%APP_LOG%



:TitleChk
set isFail=
ECHO [%TIME%] === ITEM=Deliverable SW Title Checking ... === >> %APP_LOG%
for /f "delims=" %%i in ('dir /s /a-d /b c:\swsetup\DRV\*.cva') do (
    cscript.exe /nologo "%~dp0rwini.vbs" read "%%~i" "Software Title" "US" | findstr.exe /i /c:"x - ">nul
    if not errorlevel 1 ECHO     Found %%~i software title is wrong. >> %APP_LOG% & ECHO     RESULT=FAILED >> %APP_LOG% & set isFail=1
)
if not defined isFail ECHO     Software title are correct. >> %APP_LOG% & ECHO     RESULT=PASSED >> %APP_LOG%
ECHO [%TIME%] === Deliverable SW Title Checking Completed === >> %APP_LOG%

:MSTestChk
set isFail=
ECHO [%TIME%] === ITEM=MSTest Folder Checking ... === >> %APP_LOG%
if exist C:\SWSetup\MSTest if not exist C:\System.sav\Flags\EnableDebugMode.flg ECHO     C:\SWSetup\MSTest folder still exist. >> %APP_LOG% & ECHO     RESULT=FAILED >> %APP_LOG% & set isFail=1
if not defined isFail ECHO     C:\SWSetup\MSTest folder behavior is correct. >> %APP_LOG% & ECHO     RESULT=PASSED >> %APP_LOG%
ECHO [%TIME%] === MSTest Folder Checking Completed === >> %APP_LOG%

:CountryChk
ECHO [%TIME%] === ITEM=Build ID of Source and Destination Option Code Checking ... IGNORED for Flex Config === >> %APP_LOG%
REM set isFail=
REM ECHO [%TIME%] === ITEM=Build ID of Source and Destination Option Code Checking ... === >> %APP_LOG%
REM for /f "tokens=1,2,3,4 delims==# " %%i in ('wmic /namespace:\\root\HP\InstrumentedBIOS path HP_BIOSSetting where ^(name^="Enter Build ID" OR name^="Build ID"^) get value /value') do ( if /i "%%~i" == "Value" set "BuildId=%%~j" & set "_SRC_=%%~k" & set "_DEST_=%%~l")
REM if not defined BuildId ECHO     Could not found build id, bypass checking. >> %APP_LOG% & set isFail=1
REM if not defined _SRC_ ECHO     Could not found source id, bypass checking. >> %APP_LOG% & set isFail=1
REM if not defined _DEST_ ECHO     Could not found destination id, bypass checking. >> %APP_LOG% & set isFail=1
REM if defined isFail ECHO     RESULT=PASSED >> %APP_LOG% & goto CountryChk_End
REM ECHO     BuildId=[%BuildId%] >> %APP_LOG%
REM ECHO     Compare [%_SRC_%] and [%_DEST_%] >> %APP_LOG%
REM if /i not [%_SRC_:~1%] == [%_DEST_:~1%] ECHO     Mismatch between source and destination id. >> %APP_LOG% & ECHO     RESULT=FAILED >> %APP_LOG% & set isFail=1
REM if not defined isFail ECHO     Source and Destination Option Code is match. >> %APP_LOG% & ECHO     RESULT=PASSED >> %APP_LOG%
REM :CountryChk_End
REM ECHO [%TIME%] === Build ID of Source and Destination Option Code Checking Completed === >> %APP_LOG%

:CertChk
set isFail=
ECHO [%TIME%] === ITEM=Trusted Root Certificates Checking ... === >> %APP_LOG%
if not exist %~dp0CertMgr.Exe ECHO     No certmgr.exe found, bypass checking. >> %APP_LOG% & ECHO     RESULT=PASSED >> %APP_LOG% & goto CertChk_End
%~dp0CertMgr.Exe /s root | findstr.exe /i /g:"%~dp0tdccert.lst">> %APP_LOG%
if not errorlevel 1   ECHO     Found the risk certificates in Trusted Root Certificates. >> %APP_LOG% & ECHO     RESULT=FAILED >> %APP_LOG% & set isFail=1
if not defined isFail ECHO     No risk certificates in Trusted Root Certificates. >> %APP_LOG% & ECHO     RESULT=PASSED >> %APP_LOG%
:CertChk_End
ECHO [%TIME%] === Trusted Root Certificates Checking Completed === >> %APP_LOG%

:CertChk2
set isFail=
ECHO [%TIME%] === ITEM=Trusted Root Certificates whitelist Checking ... === >> %APP_LOG%
if not exist %~dp0CertMgr.Exe ECHO     No certmgr.exe found, bypass checking. >> %APP_LOG% & ECHO     RESULT=PASSED >> %APP_LOG% & goto CertChk2_End
%~dp0CertMgr.Exe /s root /v > c:\System.sav\Logs\CertListDetail.lst
echo === %~dp0CompCert_rev002.VBS start =============================================================== >> %APP_LOG%
CScript.exe /nologo %~dp0CompCert_rev002.VBS c:\System.sav\Logs\CertListDetail.lst %~dp0tdccert2.lst c:\System.sav\Logs\Cert_OutOfExpected.lst >> %APP_LOG% 2>&1
echo === %~dp0CompCert_rev002.VBS end =============================================================== >> %APP_LOG%
findstr.exe /c:"SHA1" "c:\System.sav\Logs\Cert_OutOfExpected.lst"
if not errorlevel 1 (
	ECHO Found the risk certificates in Trusted Root Certificates. >> %APP_LOG%
	TYPE "c:\System.sav\Logs\Cert_OutOfExpected.lst" >> %APP_LOG%
	ECHO RESULT=FAILED >> %APP_LOG%
	set isFail=1
	if exist C:\System.sav\Flags\EnableDebugMode.flg (
		if not exist c:\system.sav\logs\cert mkdir c:\system.sav\logs\cert
		pushd c:\system.sav\logs\cert
		powershell.exe -executionpolicy unrestricted -command "c:\System.sav\Logs\Cert_OutOfExpected.lst.PS1"
		popd
	)
)
if not defined isFail ECHO     No risk certificates in Trusted Root Certificates.        >> %APP_LOG% & ECHO     RESULT=PASSED >> %APP_LOG%
:CertChk2_End
ECHO [%TIME%] === Trusted Root Certificates whitelist Checking Completed === >> %APP_LOG%

:PanelSizeChk
set isFail=
ECHO [%TIME%] === ITEM=Panel Size Checking ... === >> %APP_LOG%
if not exist C:\System.sav\Flags\PINCTRLTwk.pf ECHO     No PINCTRLTwk.pf found, bypass checking. >> %APP_LOG% & ECHO     RESULT=PASSED >> %APP_LOG% & goto PanelSizeChk_End
call:FBSEARCH "7T" "%FByte%"
if not errorlevel 1 ECHO According to FB CT.MT, Tower DT without monitor, bypass checking.       >> %APP_LOG% & ECHO     RESULT=PASSED >> %APP_LOG% & goto PanelSizeChk_End
FOR /F "tokens=1,2* delims==." %%I in ('FINDSTR /I /C:"SystemID=" /C:"ScreenDiagonal=" C:\HP\BIN\RStone.INI') DO (
   IF /I "%%~I" == "SystemID" SET SSID=%%~J
   IF /I "%%~I" == "ScreenDiagonal" SET PanelSize=%%~J
)
ECHO     Check %SSID%PanelSize=%PanelSize% in C:\System.sav\Flags\PINCTRLTwk.pf >> %APP_LOG%
FINDSTR /i /c:"%SSID%PanelSize=%PanelSize%" C:\System.sav\Flags\PINCTRLTwk.pf >nul
if exist C:\System.sav\Flags\EnableDebug.flg if errorlevel 1 ECHO     Panel size mismatch or not define in PINCTRLTwk.pf. >> %APP_LOG% & ECHO     RESULT=FAILED >> %APP_LOG% & set isFail=1
if not defined isFail ECHO     Panel size match between PINCTRLTwk.pf and RStone.ini. >> %APP_LOG% & ECHO     RESULT=PASSED >> %APP_LOG%
:PanelSizeChk_End
ECHO [%TIME%] === Panel Size Checking Completed === >> %APP_LOG%

:AfoRegChk_copyCmd
set isFail=
ECHO [%TIME%] === ITEM=Office AFO registry Checking, copy cmd to c:\system.sav\ExitProc\Subs\ ... === >> %APP_LOG%
call:FBSEARCH "d8" "%FByte%"
if not errorlevel 1 (
	echo According to FB, there is "AFO" >>%APP_LOG%
	xcopy /f /y "%~dp0AFOLBREG.cmd" c:\system.sav\ExitProc\Subs\ >>%APP_LOG%
	if errorlevel 1 ECHO RESULT=FAILED >> %APP_LOG% & set isFail=1
	ECHO RESULT=PASSED >> %APP_LOG%
)
ECHO [%TIME%] === Office AFO registry Checking, copy cmd to c:\system.sav\ExitProc\Subs\ Completed === >> %APP_LOG%

:MDAM3Chk
set isFail=
ECHO [%TIME%] === ITEM=MSCU of MDA M3 Checking ... === >> %APP_LOG%

if exist C:\System.sav\Flags\HAL64.FLG if exist C:\System.sav\Flags\W10RS1.FLG (
    ECHO     Image bundle Windows 10 Redstone 1 Update x64 OS. >> %APP_LOG%
    cscript.exe /nologo "%~dp0CsupDiag.vbs" /Name="Windows 10 RedStone 1 MS Critical Updates - Offline - CPS" /Type="TFS_MSCU16U_x64" >> %APP_LOG% 2>&1
    if errorlevel 1 ECHO     MSCU package did not meet MDA M3 required. >> %APP_LOG% & ECHO     RESULT=FAILED >> %APP_LOG% & set isFail=1
    goto MDAM3Chk_End
)
if exist C:\System.sav\Flags\HAL32.FLG if exist C:\System.sav\Flags\W10RS1.FLG (
    ECHO     Image bundle Windows 10 Redstone 1 Update x86 OS. >>%APP_LOG%
    cscript.exe /nologo "%~dp0CsupDiag.vbs" /Name="Windows 10 RedStone 1 MS Critical Updates - Offline - CPS" /Type="TFS_MSCU16U_x86" >> %APP_LOG% 2>&1
    if errorlevel 1 ECHO     MSCU package did not meet MDA M3 required. >> %APP_LOG% & ECHO     RESULT=FAILED >> %APP_LOG% & set isFail=1
    goto MDAM3Chk_End
)
if exist C:\System.sav\Flags\HAL64.FLG if exist C:\System.sav\Flags\W10NOV15.FLG (
    ECHO     Image bundle Windows 10 Nov 15 Update x64 OS. >> %APP_LOG%
    cscript.exe /nologo "%~dp0CsupDiag.vbs" /Name="TFS - Windows 10 Nov 15 Update MS Critical Updates - Offline - TDC" /Type="TFS_MSCU15U_x64" >> %APP_LOG%
    if errorlevel 1 ECHO     MSCU package did not meet MDA M3 required. >> %APP_LOG% & ECHO     RESULT=FAILED >> %APP_LOG% & set isFail=1
    goto MDAM3Chk_End
)
if exist C:\System.sav\Flags\HAL32.FLG if exist C:\System.sav\Flags\W10NOV15.FLG (
    ECHO     Image bundle Windows 10 Nov 15 Update x86 OS. >>%APP_LOG%
    cscript.exe /nologo %~dp0CsupDiag.vbs /Name="TFS - Windows 10 Nov 15 Update MS Critical Updates - Offline - TDC" /Type="TFS_MSCU15U_x86" >> %APP_LOG%
    if errorlevel 1 ECHO     MSCU package did not meet MDA M3 required. >> %APP_LOG% & ECHO     RESULT=FAILED >> %APP_LOG% & set isFail=1
    goto MDAM3Chk_End
)
if exist C:\System.sav\Flags\HAL64.FLG if exist C:\System.sav\Flags\W10.FLG (
    ECHO     Image bundle Windows 10 x64 OS. >> %APP_LOG%
    cscript.exe /nologo "%~dp0CsupDiag.vbs" /Name="TFS - Windows 10 MS Critical Updates - Offline - TDC" /Type="TFS_MSCU10_x64" >> %APP_LOG%
    if errorlevel 1 ECHO     MSCU package did not meet MDA M3 required. >> %APP_LOG% & ECHO     RESULT=FAILED >> %APP_LOG% & set isFail=1
    goto MDAM3Chk_End
)
if exist C:\System.sav\Flags\HAL32.FLG if exist C:\System.sav\Flags\W10.FLG (
    ECHO     Image bundle Windows 10 x86 OS. >>%APP_LOG%
    cscript.exe /nologo %~dp0CsupDiag.vbs /Name="TFS - Windows 10 MS Critical Updates - Offline - TDC" /Type="TFS_MSCU10_x86" >> %APP_LOG%
    if errorlevel 1 ECHO     MSCU package did not meet MDA M3 required. >> %APP_LOG% & ECHO     RESULT=FAILED >> %APP_LOG% & set isFail=1
    goto MDAM3Chk_End
)
if exist C:\System.sav\Flags\HAL64.FLG if exist C:\System.sav\Flags\WIN7SP1.FLG (
    ECHO     Image bundle Windows 7 SP1 x64 OS. >>%APP_LOG%
    cscript.exe /nologo %~dp0CsupDiag.vbs /Name="MS Critical Updates for Windows 7 SP1 - Offline - CPS" /Type="TFS_MSCU7_x64" >> %APP_LOG%
    if errorlevel 1 ECHO     MSCU package did not meet MDA M3 required. >> %APP_LOG% & ECHO     RESULT=FAILED >> %APP_LOG% & set isFail=1
    goto MDAM3Chk_End
)
set isFail=1
ECHO     Image bundle Unknown OS. >> %APP_LOG%
ECHO     RESULT=FAILED >> %APP_LOG
:MDAM3Chk_End
if not defined isFail ECHO     MSCU package has meet MDA M3 required. >> %APP_LOG% & ECHO     RESULT=PASSED >> %APP_LOG%
ECHO [%TIME%] === MSCU of MDA M3 Checking Completed === >> %APP_LOG%


:END
ENDLOCAL
@ECHO ON
goto :EOF



:FBSEARCH
set "varfb=%~1"
set "varfbstr=%~2"
:next
if not defined varfb echo No specify FB & exit /b 1
if not defined varfbstr echo No specify FB string & exit /b 1
if [%varfbstr:~0,2%] == [%varfb%] exit /b 0
set "varfbstr=%varfbstr:~2%"
if defined varfbstr goto next
exit /b 1
