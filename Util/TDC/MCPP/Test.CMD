@Echo off
cls

SET APP_NAME=HP Windows Image Diagnostic Tools - CPS
SET APP_LOG="%~dpn0.LOG"
if exist %APP_LOG% del /f /q %APP_LOG%

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
if exist C:\System.sav\Flags\HAL64.FLG if exist C:\System.sav\Flags\WIN81W14U.FLG (
    ECHO     Image bundle Windows 8.1 Winter 14 Update x64 OS. >> %APP_LOG%
    cscript.exe /nologo "%~dp0CsupDiag.vbs" /Name="TFS - Windows 8.1 Winter 14 Update MS Critical Updates - Offline - TDC" /Type="TFS_MSCUW14U_x64" >> %APP_LOG%
    if errorlevel 1 ECHO     MSCU package did not meet MDA M3 required. >> %APP_LOG% & ECHO     RESULT=FAILED >> %APP_LOG% & set isFail=1
    goto MDAM3Chk_End
)
if exist C:\System.sav\Flags\HAL32.FLG if exist C:\System.sav\Flags\WIN81W14U.FLG (
    ECHO     Image bundle Windows 8.1 Winter 14 Update x86 OS. >>%APP_LOG%
    cscript.exe /nologo %~dp0CsupDiag.vbs /Name="TFS - Windows 8.1 Winter 14 Update MS Critical Updates - Offline - TDC" /Type="TFS_MSCUW14U_x86" >> %APP_LOG%
    if errorlevel 1 ECHO     MSCU package did not meet MDA M3 required. >> %APP_LOG% & ECHO     RESULT=FAILED >> %APP_LOG% & set isFail=1
    goto MDAM3Chk_End
)
if exist C:\System.sav\Flags\HAL64.FLG if exist C:\System.sav\Flags\W81U.FLG (
    ECHO     Image bundle Windows 8.1 Update x64 OS. >> %APP_LOG%
    cscript.exe /nologo "%~dp0CsupDiag.vbs" /Name="TFS - Windows 8.1 Update MS Critical Updates - Offline - TDC" /Type="TFS_MSCU81U_x64" >> %APP_LOG%
    if errorlevel 1 ECHO     MSCU package did not meet MDA M3 required. >> %APP_LOG% & ECHO     RESULT=FAILED >> %APP_LOG% & set isFail=1
    goto MDAM3Chk_End
)
if exist C:\System.sav\Flags\HAL32.FLG if exist C:\System.sav\Flags\W81U.FLG (
    ECHO     Image bundle Windows 8.1 Update x86 OS. >>%APP_LOG%
    cscript.exe /nologo %~dp0CsupDiag.vbs /Name="TFS - Windows 8.1 Update MS Critical Updates - Offline - TDC" /Type="TFS_MSCU81U_x86" >> %APP_LOG%
    if errorlevel 1 ECHO     MSCU package did not meet MDA M3 required. >> %APP_LOG% & ECHO     RESULT=FAILED >> %APP_LOG% & set isFail=1
    goto MDAM3Chk_End
)
if exist C:\System.sav\Flags\HAL64.FLG if exist C:\System.sav\Flags\WIN81SP0.FLG (
    ECHO     Image bundle Windows 8.1 x64 OS. >>%APP_LOG%
    cscript.exe /nologo %~dp0CsupDiag.vbs /Name="TFS - Windows 8.1 Update MS Critical Updates - Offline - TDC" /Type="TFS_MSCU81_x64" >> %APP_LOG%
    if errorlevel 1 ECHO     MSCU package did not meet MDA M3 required. >> %APP_LOG% & ECHO     RESULT=FAILED >> %APP_LOG% & set isFail=1
    goto MDAM3Chk_End
) 
if exist C:\System.sav\Flags\HAL64.FLG if exist C:\System.sav\Flags\WIN8SP0.FLG (
    ECHO     Image bundle Windows 8 x64 OS. >>%APP_LOG%
    cscript.exe /nologo %~dp0CsupDiag.vbs /Name="TFS - Windows 8 MS Critical Updates - Offline - TDC" /Type="TFS_MSCU8_x64" >> %APP_LOG%
    if errorlevel 1 ECHO     MSCU package did not meet MDA M3 required. >> %APP_LOG% & ECHO     RESULT=FAILED >> %APP_LOG% & set isFail=1
    goto MDAM3Chk_End
) 
if exist C:\System.sav\Flags\HAL64.FLG if exist C:\System.sav\Flags\WIN7SP1.FLG (
    ECHO     Image bundle Windows 7 SP1 x64 OS. >>%APP_LOG%
    cscript.exe /nologo %~dp0CsupDiag.vbs /Name="TFS - MS Critical Updates for Windows 7 SP1 - Offline - TDC" /Type="TFS_MSCU7_x64" >> %APP_LOG%
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
