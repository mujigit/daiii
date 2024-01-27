REM ========================================================
REM   Template Version: 2.00
REM ========================================================

@ECHO OFF
SETLOCAL
SET APP_NAME=Windows 10 Image Customization Tweaks for 3C16 - CPS
SET APP_LOG=C:\System.sav\LOGS\BB\%~n0.LOG
IF NOT EXIST C:\System.sav\LOGS\BB MD C:\System.sav\LOGS\BB

ECHO ############################################################# >> %APP_LOG%
ECHO  [%DATE%]                                                     >> %APP_LOG%
ECHO  [%TIME%] Beginning of the %~nx0                              >> %APP_LOG%
ECHO ############################################################# >> %APP_LOG%



:XTU_LINK_START
ECHO Clean XTU Desktop Icon>>%APP_LOG%
echo cscript /nologo C:\SWSetup\CustTweak\DELINK.vbs /List="%~dp0XTU_Icon.lst">>%APP_LOG%
cscript /nologo C:\SWSetup\CustTweak\DELINK.vbs /List="%~dp0XTU_Icon.lst">>%APP_LOG% 2>&1
echo ErrorLevel=%errorlevel% >>%APP_LOG%
:XTU_LINK_END


REM ------------------- Script Entry ------------------------
Echo Start of platform search.>>%APP_LOG%
rem For SMB platform
findstr.exe /i /x "ImageIDFlag=1" C:\HP\BIN\RStone_BBV.INI >nul
if not errorlevel 1 call :SMB
findstr.exe /i /x "ChannelId=2" C:\HP\BIN\RStone_BBV.INI >nul
if not errorlevel 1 call :BBY
findstr.exe /i /x "ChannelID=14" C:\HP\BIN\RStone_BBV.INI >nul
if not errorlevel 1 call :Costco
findstr.exe /i /x "SpecialEdition=1" C:\HP\BIN\RStone_BBV.INI >nul
if not errorlevel 1 call :SpecialEdition
findstr.exe /i /x "LongBrandName=Envy" C:\HP\BIN\RStone_BBV.INI >nul
if not errorlevel 1 call :Envy
findstr.exe /i /x "LongBrandName=Premium" C:\HP\BIN\RStone_BBV.INI >nul
if not errorlevel 1 call :Premium
findstr.exe /i /x "SystemID=1899" C:\HP\BIN\RStone_BBV.INI >nul
if not errorlevel 1 call :Folio6U
findstr.exe /i /x "SystemID=2332 SystemID=2333 SystemID=8179" C:\HP\BIN\RStone_BBV.INI >nul
if not errorlevel 1 call :Gaming
findstr.exe /i /c:"USB\VID_8086&PID_0A66" C:\HP\BIN\RStone_BBV.INI >nul
if not errorlevel 1 call :3DCamera
goto RESULTPASSED

:BBY
echo Detected BBY Channel>>%APP_LOG%
echo DELINK.vbs /List="%~dp0BBY_Icon.lst">>%APP_LOG%
cscript /nologo C:\SWSetup\CustTweak\DELINK.vbs /List="%~dp0BBY_Icon.lst">>%APP_LOG% 2>&1
goto:eof

:Costco
echo Customize Costco of DT icon >>%APP_LOG%
echo DELINK.vbs /List="%~dp0Costco_Icon.lst">>%APP_LOG%
cscript /nologo C:\SWSetup\CustTweak\DELINK.vbs /List="%~dp0Costco_Icon.lst">>%APP_LOG% 2>&1
goto:eof

:SpecialEdition
echo Detected Special Edition Channel>>%APP_LOG%
ECHO Clean Desktop Icon>>%APP_LOG%
echo cscript /nologo C:\SWSetup\CustTweak\DELINK.vbs /ExcludeList="%~dp0Special_Icon_Ex.lst">>%APP_LOG%
cscript /nologo C:\SWSetup\CustTweak\DELINK.vbs /ExcludeList="%~dp0Special_Icon_Ex.lst">>%APP_LOG% 2>&1
echo ErrorLevel=%errorlevel% >>%APP_LOG%
ECHO Clean ASG Desktop Icon>>%APP_LOG%
for /f "delims=" %%i in ('dir /s /b /ad "C:\HP\HPQWare\dtshortcuts"') do ( 
    echo cscript /nologo C:\SWSetup\CustTweak\DELINK.vbs /ExcludeList="%~dp0Special_Icon_Ex.lst" /folder="%%~i" >>%APP_LOG%
    cscript /nologo C:\SWSetup\CustTweak\DELINK.vbs /ExcludeList="%~dp0Special_Icon_Ex.lst" /folder="%%~i" >>%APP_LOG% 2>&1
    echo ErrorLevel=%errorlevel% >>%APP_LOG%
)
if exist C:\SYSTEM.SAV\Flags\Disney.flg (
    echo Clean Taskbar Icon Setting. >>%APP_LOG%
    reg.exe delete HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\TBDEn /f >>%APP_LOG% 
    IF ERRORLEVEL 1 echo Clean Taskbar Icon failed. >>%APP_LOG% & GOTO RESULTFAILED
)
goto:eof

:Envy
echo Detect Envy Brand Name >>%APP_LOG%
echo DELINK.vbs /List="%~dp0Envy_Icon.lst">>%APP_LOG%
cscript /nologo C:\SWSetup\CustTweak\DELINK.vbs /List="%~dp0Envy_Icon.lst">>%APP_LOG% 2>&1
goto:eof

:Premium
echo Detect Premium Brand Name >>%APP_LOG%
echo DELINK.vbs /ExcludeList="%~dp0Premium_Icon_Ex.lst">>%APP_LOG%
cscript /nologo C:\SWSetup\CustTweak\DELINK.vbs /ExcludeList="%~dp0Premium_Icon_Ex.lst">>%APP_LOG% 2>&1
echo ErrorLevel=%errorlevel% >>%APP_LOG%
ECHO Clean Desktop Icon>>%APP_LOG%
ECHO Clean ASG Desktop Icon>>%APP_LOG%
for /f "delims=" %%i in ('dir /s /b /ad "C:\HP\HPQWare\dtshortcuts"') do ( 
    echo cscript /nologo C:\SWSetup\CustTweak\DELINK.vbs /ExcludeList="%~dp0Premium_Icon_Ex.lst" /folder="%%~i" >>%APP_LOG%
    cscript /nologo C:\SWSetup\CustTweak\DELINK.vbs /ExcludeList="%~dp0Premium_Icon_Ex.lst" /folder="%%~i" >>%APP_LOG% 2>&1
    echo ErrorLevel=%errorlevel% >>%APP_LOG%
)
goto:eof

:SMB
echo Detected SMB Edition>>%APP_LOG%
echo DELINK.vbs /List="%~dp0SMB_Icon.lst">>%APP_LOG%
cscript /nologo C:\SWSetup\CustTweak\DELINK.vbs /List="%~dp0SMB_Icon.lst">>%APP_LOG% 2>&1
goto:eof

:Folio6U
echo Detected Folio 6U Platform>>%APP_LOG%
echo Customize 6U of start menu link >>%APP_LOG%
goto:eof

:Gaming
echo Detected Gaming Platform>>%APP_LOG%
ECHO Clean Desktop Icon>>%APP_LOG%
echo cscript /nologo C:\SWSetup\CustTweak\DELINK.vbs /ExcludeList="%~dp0Game_Icon_Ex.lst">>%APP_LOG%
cscript /nologo C:\SWSetup\CustTweak\DELINK.vbs /ExcludeList="%~dp0Game_Icon_Ex.lst">>%APP_LOG% 2>&1
echo ErrorLevel=%errorlevel% >>%APP_LOG%
ECHO Clean ASG Desktop Icon>>%APP_LOG%
for /f "delims=" %%i in ('dir /s /b /ad "C:\HP\HPQWare\dtshortcuts"') do ( 
    echo cscript /nologo C:\SWSetup\CustTweak\DELINK.vbs /ExcludeList="%~dp0Game_Icon_Ex.lst" /folder="%%~i" >>%APP_LOG%
    cscript /nologo C:\SWSetup\CustTweak\DELINK.vbs /ExcludeList="%~dp0Game_Icon_Ex.lst" /folder="%%~i" >>%APP_LOG% 2>&1
    echo ErrorLevel=%errorlevel% >>%APP_LOG%
)
goto:eof

:3DCamera
echo Detected 3D Camera Device>>%APP_LOG%
ECHO Clean Desktop Icon>>%APP_LOG%
echo cscript /nologo C:\SWSetup\CustTweak\DELINK.vbs /ExcludeList="%~dp0Camera_Icon_Ex.lst">>%APP_LOG%
cscript /nologo C:\SWSetup\CustTweak\DELINK.vbs /ExcludeList="%~dp0Camera_Icon_Ex.lst">>%APP_LOG% 2>&1
echo ErrorLevel=%errorlevel% >>%APP_LOG%
ECHO Clean ASG Desktop Icon>>%APP_LOG%
for /f "delims=" %%i in ('dir /s /b /ad "C:\HP\HPQWare\dtshortcuts"') do ( 
    echo cscript /nologo C:\SWSetup\CustTweak\DELINK.vbs /ExcludeList="%~dp0Camera_Icon_Ex.lst" /folder="%%~i" >>%APP_LOG%
    cscript /nologo C:\SWSetup\CustTweak\DELINK.vbs /ExcludeList="%~dp0Camera_Icon_Ex.lst" /folder="%%~i" >>%APP_LOG% 2>&1
    echo ErrorLevel=%errorlevel% >>%APP_LOG%
)
goto:eof

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