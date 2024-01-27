REM ========================================================
REM   Template Version: 2.00
REM ========================================================

@ECHO OFF
SETLOCAL
SET APP_NAME=Image tweaks for tiledatamodelsvc enable
SET APP_LOG=C:\System.sav\LOGS\BB\%~n0.LOG
IF NOT EXIST C:\System.sav\LOGS MD C:\System.sav\LOGS

ECHO ############################################################# >> %APP_LOG%
ECHO  [%DATE%]                                                     >> %APP_LOG%
ECHO  [%TIME%] Beginning of the %~nx0                              >> %APP_LOG%
ECHO ############################################################# >> %APP_LOG%

SET ErrorLevel=
reg.exe load HKLM\TempHive c:\windows\system32\config\System
if not errorlevel 1 (
    Echo [%time%] Loaded hive Sucessfully >> %APP_LOG%
    reg query HKLM\TempHive\ControlSet001\Services\tiledatamodelsvc /v start >nul
    if not errorlevel 1 (
        echo [%time%] Found tiledatamodelsvc, Enable it. >> %APP_LOG%
        reg add HKLM\TempHive\ControlSet001\Services\tiledatamodelsvc /v Start /t REG_DWORD /d 2 /f >> %APP_LOG%
        if errorlevel 1 echo [%time%] service Enable failed. >> %APP_LOG% & CALL :UnloadHive & goto RESULTFAILED
        echo [%time%] Enable tiledatamodelsvc Service success. >>%APP_LOG%
    )
    Echo [%time%] Re-query tiledatamodelsve value. >> %APP_LOG%
    reg query HKLM\TempHive\ControlSet001\Services\tiledatamodelsvc /v start >> %APP_LOG%
) ELSE (
    Echo [%time%] Failed to load hive.>> %APP_LOG%
    goto RESULTFAILED
)
CALL :UnloadHive
GOTO  RESULTPASSED

:UnloadHive
echo Unload HKLM\TempHive >>%APP_LOG%
reg.exe unload HKLM\TempHive >>%APP_LOG%
if errorlevel 1 echo Unload HKLM\TempHive failed >>%APP_LOG% & goto RESULTFAILED
GOTO:EOF


:RESULTPASSED
ECHO [%TIME%] Result of the %APP_NAME% >> %APP_LOG%
ECHO RESULT=PASSED >> %APP_LOG%
GOTO END

:RESULTFAILED
ECHO [%TIME%] Result of the %APP_NAME% >> %APP_LOG%
ECHO RESULT=FAILED >> %APP_LOG%
GOTO END

:END
ENDLOCAL
@ECHO ON


