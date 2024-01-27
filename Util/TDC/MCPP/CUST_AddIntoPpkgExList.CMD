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
ECHO  [%TIME%] Beginning of the %~nx0 during %1 phase              >> %APP_LOG%
ECHO ############################################################# >> %APP_LOG%

REM ------------------- Script Entry ------------------------

:AddIntoPpkgExList
if not exist C:\RM\RERM\DeployRP\PPKGXML\Exclude\Files mkdir C:\RM\RERM\DeployRP\PPKGXML\Exclude\Files
echo %%SystemDrive%%\SWSetup\CustTweak\* [*]>>C:\RM\RERM\DeployRP\PPKGXML\Exclude\Files\ImgCust.list
echo %%SystemDrive%%\SWSetup\hpImgEnh\* [*]>>C:\RM\RERM\DeployRP\PPKGXML\Exclude\Files\ImgCust.list
type C:\RM\RERM\DeployRP\PPKGXML\Exclude\Files\ImgCust.list >> %APP_LOG%

findstr /I /c:"x:" C:\RM\RERM\DeployRP\PPKGXML\Exclude\Files\ImgCust.list
if not errorlevel 1 echo Systemdrive shouldn't be extend to X:! >>%APP_LOG% & goto :RESULTFAILED
findstr /I /c:"c:" C:\RM\RERM\DeployRP\PPKGXML\Exclude\Files\ImgCust.list
if not errorlevel 1 echo Systemdrive shouldn't be extend to C:! >>%APP_LOG% & goto :RESULTFAILED
goto :RESULTPASSED

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