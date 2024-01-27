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
ECHO  [%TIME%] Beginning of the %~nx0  [%1]                        >> %APP_LOG%
ECHO ############################################################# >> %APP_LOG%

REM ------------------- Script Entry ------------------------
set imgfailed=true


Echo Get CNB CDT >>%APP_LOG%
Echo Start of platform search.>>%APP_LOG%
REM Masaki solution for CNB/CDT detection
SET dpsPath=
FOR /F %%a IN ('dir C:\system.sav\*_DPS /b') DO SET dpsPath=C:\system.sav\%%a
if not defined dpsPath echo dpsPath not found >>%APP_LOG% & goto RESULTFAILED
ECHO [%time%] DPS File=[%dpsPath%] >>%APP_LOG%
SET mlPrefix=
FOR /F "tokens=2 delims==" %%a IN ('find /n /i "ML_Prefix" %dpsPath%') DO SET mlPrefix=%%a
if not defined mlPrefix echo mlPrefix not found >>%APP_LOG% & set mlPrefix=UNKNOWN
ECHO [%time%] ML prefix=[%mlPrefix%] >>%APP_LOG%

Echo Get cycle info >>%APP_LOG%
set yearcycle_flg=
pushd c:\system.sav\flags
for /F "delims=" %%C IN ('dir /b ?C??.flg') do set "yearcycle_flg=%%~nC"
popd
set yearcycle_year=
set yearcycle_cycle=
set /A yearcycle_cycle=%yearcycle_flg:~0,1%
set /A yearcycle_year=%yearcycle_flg:~-2%
ECHO yearcycle_cycle=[%yearcycle_cycle%] >>%APP_LOG%
ECHO yearcycle_year=[%yearcycle_year%] >>%APP_LOG%


if %yearcycle_year% LSS 17 ECHO Channel check only start from 1c17 >>%APP_LOG% & goto ChannelChk_End
:ChannelChk_Start
ECHO [%TIME%] === ITEM=Channel Checking === >> %APP_LOG%

:ChannelChk_NotZero
set isFail=
REM ChannelType=0 (illegal setting)
REM ChannelType=1=BTO (common channel)
REM ChannelType=2=CTO (Customization, buy from HP website)
ECHO [%TIME%] === ITEM=Channel must be eithor RETAIL or BTO Checking === >> %APP_LOG%
FINDSTR /I /C:"ChannelType=0" C:\HP\BIN\RStone.INI >> %APP_LOG% 2>&1
if not errorlevel 1 echo Channel infomation shouldn't be 0. Channel must be either BTO or CTO. >> %APP_LOG% & ECHO RESULT=FAILED >> %APP_LOG% & set isFail=1
if not defined isFail echo Channel infomation is correct. >> %APP_LOG% & Echo RESULT=PASSED >> %APP_LOG%
:ChannelChk_NotZero_End
ECHO [%TIME%] === Channel must be eithor RETAIL or BTO Checking Completed === >> %APP_LOG%

:ChannelChk_SingleFB
set isFail=
REM Best Buy	BBUY (5F)
REM Walmart		R_WM (3a)
REM Amazon		R_AMZ (bx)
REM T-Mobile	R_TMO (by)
REM Costco		R_CostCo (9C)
REM Sam's Club	R_SAM (aN)
REM Fnac		R_FNAC (cf)
REM Microsoft Signature			R_MIC (bg)
REM Best Buy and Premiun load	BBUY,SL.PRE (5F7N) will only check 5F above
ECHO [%TIME%] === ITEM=Channel must be single Checking === >> %APP_LOG%
set FByte=
for /f "tokens=1,2 delims==." %%i in ('wmic /namespace:"\\root\HP\InstrumentedBIOS" path HP_BIOSSetting where ^(name^="Enter Feature Byte" OR name^="Feature Byte"^) get value /value') do (if /i %%i == Value set "FByte=%%~j")
if not defined FByte echo Feature Byte not found >> %APP_LOG% & ECHO RESULT=FAILED >> %APP_LOG% & set isFail=1 & goto ChannelChk_SingleFB_End
echo Feature Byte is "%FByte%" >>%APP_LOG%
set /A FindCnt=0
call :FBSEARCHCOUNT "5F" "%FByte%" "BBUY" >>%APP_LOG%
call :FBSEARCHCOUNT "3a" "%FByte%" "R_WM" >>%APP_LOG%
call :FBSEARCHCOUNT "bx" "%FByte%" "R_AMZ" >>%APP_LOG%
call :FBSEARCHCOUNT "by" "%FByte%" "R_TMO" >>%APP_LOG%
call :FBSEARCHCOUNT "9C" "%FByte%" "R_CostCo" >>%APP_LOG%
call :FBSEARCHCOUNT "aN" "%FByte%" "R_SAM" >>%APP_LOG%
call :FBSEARCHCOUNT "cf" "%FByte%" "R_FNAC" >>%APP_LOG%
call :FBSEARCHCOUNT "bg" "%FByte%" "R_MIC" >>%APP_LOG%
echo Channel count=%FindCnt% >> %APP_LOG%
if %FindCnt% GTR 1 echo Cannot set more than 1 channel FB. >> %APP_LOG% & ECHO RESULT=FAILED >> %APP_LOG% & set isFail=1
if not defined isFail echo Channel count is correct. >> %APP_LOG% & Echo RESULT=PASSED >> %APP_LOG%
:ChannelChk_SingleFB_End
ECHO [%TIME%] === Channel must be single Checking Completed === >> %APP_LOG%

:ChannelChk_End
ECHO [%TIME%] === Channel Checking Completed === >> %APP_LOG%



REM Notebook (0Ah)
REM Convertible (1Fh)
REM Tablet (1Eh)
REM Detachable (20h)
REM Desktop (03h)
REM All-in-One (0Dh)
if %yearcycle_year% LSS 17 ECHO Enclosure Type check only start from 1c17 >>%APP_LOG% & goto EnclosureTypeChk_End
if /I "%mlPrefix%"=="Unknown" ECHO Unknown CNB/CDT type >>%APP_LOG% & ECHO RESULT=FAILED >> %APP_LOG% & goto EnclosureTypeChk_End
:EnclosureTypeChk
set isFail=
ECHO [%TIME%] === ITEM= Enclosure type Checking for MDA2017 === >> %APP_LOG%
if /I "%mlPrefix%"=="CNB" FINDSTR /I /C:"EnclosureType=0Ah" /C:"EnclosureType=1Fh" /C:"EnclosureType=1Eh" /C:"EnclosureType=20h" C:\HP\BIN\RStone.INI >> %APP_LOG% 2>&1
if /I "%mlPrefix%"=="CDT" FINDSTR /I /C:"EnclosureType=03h" /C:"EnclosureType=0Dh" C:\HP\BIN\RStone.INI >> %APP_LOG% 2>&1
if errorlevel 1 echo Illegal enclosure type in SMBIOS type 3 offset 5, BIOS should fix it. >> %APP_LOG% & FINDSTR /I /C:"EnclosureType=" C:\HP\BIN\RStone.INI >> %APP_LOG% 2>&1 & ECHO RESULT=FAILED >> %APP_LOG% & set isFail=1
if not defined isFail echo EnclosureType is correct. >> %APP_LOG% & Echo RESULT=PASSED >> %APP_LOG%
:EnclosureTypeChk_End
ECHO [%TIME%] === Enclosure type Checking for MDA2017 Completed === >> %APP_LOG%



:CertBackup
ECHO [%TIME%] === ITEM=Trusted Root Certificates Inital backup ... === >> %APP_LOG%
"%~dp0CertMgr.Exe" /s root /v > c:\System.sav\Logs\CertListDetail_BK_%1.lst
if errorlevel 1 (
	echo Backup certificates failed. >> %APP_LOG%
	ECHO RESULT=FAILED >> %APP_LOG%
) else (
	Echo RESULT=PASSED >> %APP_LOG%
)
ECHO [%TIME%] === Trusted Root Certificates Inital backup Completed === >> %APP_LOG%



:END
ENDLOCAL
@ECHO ON
goto :EOF


:FBSEARCHCOUNT
set "varfb=%~1"
set "varfbstr=%~2"
:next
if not defined varfb echo No specify FB & exit /b 1
if not defined varfbstr echo No specify FB string & exit /b 1
if [%varfbstr:~0,2%] == [%varfb%] set /A FindCnt=%FindCnt%+1 & echo %varfb%[%~3] is match & exit /b 0
set "varfbstr=%varfbstr:~2%"
if defined varfbstr goto next
exit /b 1
