REM ========================================================
REM   Template Version: 2.00
REM ========================================================

@ECHO OFF
SETLOCAL
SET APP_LOG=C:\System.sav\LOGS\BB\BSWNoise.LOG
SET APP_NAME=Intel BSW Graphic Noise Workaround

ECHO ############################################################# >> %APP_LOG%
ECHO  [%DATE%]                                                     >> %APP_LOG%
ECHO  [%TIME%] Beginning of the %~nx0                              >> %APP_LOG%
ECHO ############################################################# >> %APP_LOG%

REM ------------------- Script Entry ------------------------
ECHO [%TIME%] Start %APP_NAME% >>%APP_LOG%

reg.exe load HKLM\TempHive "C:\Windows\System32\config\SYSTEM">>%APP_LOG%
if errorlevel 1 echo Failed to load the SYSTEM hive. >>%APP_LOG% & GOTO RESULTFAILED 
 
for /f "delims=" %%i in ('Reg.exe query "HKLM\TempHive\ControlSet001\Enum\PCI" /s /f "MessageSignaledInterruptProperties"') do (
    echo Found "%%i" >>%APP_LOG%
    echo "%%i"|find.exe /i "VEN_8086&DEV_2284" >nul
    if not errorlevel 1 (
        echo Query "%%i" >>%APP_LOG%
        reg.exe query "%%i" /v "MSISupported" >>%APP_LOG%
        echo Set "%%i" >>%APP_LOG%
        reg.exe add "%%i" /v "MSISupported" /t REG_DWORD /d "0x1" /f >>%APP_LOG% 
        if errorlevel 1 CALL :UnloadHive & goto RESULTFAILED
        reg.exe query "%%i" /v "MSISupported" >>%APP_LOG%
    )
)
CALL :UnloadHive
goto RESULTPASSED

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
ECHO [%TIME%] End of the %APP_NAME% >> %APP_LOG%