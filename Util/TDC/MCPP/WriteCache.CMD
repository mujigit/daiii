REM ========================================================
REM   Template Version: 2.00
REM ========================================================

@ECHO OFF
SETLOCAL
SET APP_NAME=TFS - Windows 10 HP Image Enhancements - TDC - Default HDD Write Cache Policy
SET APP_LOG=C:\System.sav\LOGS\BB\%~n0.LOG
IF NOT EXIST C:\System.sav\LOGS\BB MD C:\System.sav\LOGS\BB

ECHO ############################################################# >> %APP_LOG%
ECHO  [%DATE%]                                                     >> %APP_LOG%
ECHO  [%TIME%] Beginning of the %~nx0                              >> %APP_LOG%
ECHO ############################################################# >> %APP_LOG%

REM ------------------- Script Entry ------------------------
:DETECTION
if exist C:\System.sav\Flags\1sthddcache.flg echo [%TIME%] Found 1sthddcache.flg >>%APP_LOG% & call :1stCacheProc
if exist C:\System.sav\Flags\2ndhddcache.flg echo [%TIME%] Found 2ndhddcache.flg >>%APP_LOG% & call :2ndCacheProc
if not exist C:\System.sav\Flags\1sthddcache.flg if not exist C:\System.sav\Flags\2ndhddcache.flg echo Could not found 1sthddcache.flg and 2ndhddcache.flg. >> %APP_LOG% & goto RESULTPASSED
echo HDD Write Cache of CacheIsPowerProtected Setting Disable Complete. >> %APP_LOG%
goto RESULTPASSED

:1stCacheProc
set DiskId=
for /f "tokens=1,2 delims=={} " %%i in ('wmic /namespace:\\root\microsoft\windows\storage path msft_partition where ^(driveletter^="C"^) get DiskId /value') do (if /i %%~i == DiskId set DiskId="%%~j")
if not defined DiskId echo Could not found DiskId >> %APP_LOG% & goto:eof
set DiskId=%DiskId:&amp;=&%
set DiskId=%DiskId:\\?\=%
set DiskId=%DiskId:#=\%
if /i %DiskId:~-2,1% == \ set DiskId=%DiskId:~0,-2%"
echo Disk Id = %DiskId% >> %APP_LOG%
echo Query "hklm\system\currentcontrolset\enum\%DiskId:"=%\Device Parameters" >>%APP_LOG%
Reg.exe query "hklm\system\currentcontrolset\enum\%DiskId:"=%\Device Parameters">nul
if errorlevel 1 echo Could not found the registry key >>%APP_LOG% & goto:eof
echo Set "hklm\system\currentcontrolset\enum\%DiskId:"=%\Device Parameters\Disk" of CacheIsPowerProtected value to 1 >>%APP_LOG%
Reg.exe add "hklm\system\currentcontrolset\enum\%DiskId:"=%\Device Parameters\Disk" /v "CacheIsPowerProtected" /t REG_DWORD /d "0x00000001" /f >>%APP_LOG%
if errorlevel 1 echo CacheIsPowerProtected registry setting failed. >>%APP_LOG% & GOTO RESULTFAILED
goto:eof

:2ndCacheProc
set DiskId=
set DiskNum=
rem for /f "tokens=1,2 delims== " %%i in ('Wmic.exe /namespace:\\root\cimv2 path win32_diskdrive where ^(MediaType like "Fixed hard disk media%%"^) get Index /value ^| sort') do (if /i %%~i == Index set /a DiskNum="%%~j")
rem For Lollipop, the dock HDD is External hard disk media
for /f "tokens=1,2 delims== " %%i in ('Wmic.exe /namespace:\\root\cimv2 path win32_diskdrive where ^(MediaType like "Fixed hard disk media%%" OR MediaType like "External hard disk media%%"^) get Index /value ^| sort') do (if /i %%~i == Index set /a DiskNum="%%~j")
if not defined DiskNum echo Could not count disk number >> %APP_LOG% & goto RESULTPASSED
if %DiskNum% LSS 1 echo Fixed Disk Number %DiskNum% ^< 1, not support >> %APP_LOG% & goto:eof
echo Fixed Disk Number = %DiskNum% >> %APP_LOG%
for /L %%a in (0,1,%DiskNum%) do ( for /f "tokens=1,10 delims==\{} " %%i in ('wmic /namespace:\\root\microsoft\windows\storage path msft_disk where ^(Number^=%%~a AND IsSystem^=False^) get ObjectId /value') do (if /i %%~i == ObjectId set DiskId="%%~j") )
if not defined DiskId echo Could not found ObjectId >> %APP_LOG% & goto:eof
echo Disk Id = %DiskId% >> %APP_LOG%
set DiskId=%DiskId:&amp;=&%
set DiskId=%DiskId:\\?\=%
set DiskId=%DiskId:#=\%
if /i %DiskId:~-2,1% == \ set DiskId=%DiskId:~0,-2%"
echo Disk Id = %DiskId% >> %APP_LOG%
echo Query "hklm\system\currentcontrolset\enum\%DiskId:"=%\Device Parameters" >>%APP_LOG%
Reg.exe query "hklm\system\currentcontrolset\enum\%DiskId:"=%\Device Parameters">nul
if errorlevel 1 echo Could not found the registry key >>%APP_LOG% & goto:eof
echo Set "hklm\system\currentcontrolset\enum\%DiskId:"=%\Device Parameters\Disk" of CacheIsPowerProtected value to 1 >>%APP_LOG%
Reg.exe add "hklm\system\currentcontrolset\enum\%DiskId:"=%\Device Parameters\Disk" /v "CacheIsPowerProtected" /t REG_DWORD /d "0x00000001" /f >>%APP_LOG%
if errorlevel 1 echo CacheIsPowerProtected registry setting failed. >>%APP_LOG% & GOTO RESULTFAILED
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