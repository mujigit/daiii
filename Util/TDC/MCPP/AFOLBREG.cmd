REM Variable Settings
@ECHO OFF
SET APP_NAME=AFOLBREG.cmd
SET APP_LOG=C:\System.sav\LOGS\BB\AFOLBREG.LOG

ECHO ############################################################# >> %APP_LOG%
ECHO  [%DATE%]                                                     >> %APP_LOG%
ECHO  [%TIME%] Beginning of the %~nx0                              >> %APP_LOG%
ECHO ############################################################# >> %APP_LOG%


:DETECTION
findstr /i /x /c:"SKUOptionConfig=ABJ" /c:"SKUOptionConfig=ACF" "C:\hp\bin\rstone.ini" >>%APP_LOG% 2>&1
if not errorlevel 1 echo [%TIME%] This is ABJ or ACF SKU, ignore patch... >>%APP_LOG% & goto RESULTPASSED

:INSTALL
echo [%TIME%] Load C:\Windows\System32\config\SOFTWARE hive file >>%APP_LOG%
reg.exe load HKLM\TempHive "C:\Windows\System32\config\SOFTWARE" >>%APP_LOG% 2>>&1
if errorlevel 1 echo [%TIME%] Load C:\Windows\System32\config\SOFTWARE hive failed >>%APP_LOG% & goto RESULTFAILED
echo [%TIME%] Load C:\Windows\System32\config\SOFTWARE hive success. >>%APP_LOG%

call :CHECKREG "HKLM\TempHive\Microsoft\Office\16.0\Common\OEM"
if errorlevel 1 CALL :UnloadHive & goto RESULTFAILED
call :CHECKREG "HKLM\TempHive\Wow6432Node\Microsoft\Office\16.0\Common\OEM"
if errorlevel 1 CALL :UnloadHive & goto RESULTFAILED
CALL :UnloadHive
GOTO RESULTPASSED


:CHECKREG
echo [%TIME%] Checking reg key %1 >>%APP_LOG%
Reg.exe QUERY %1 /v "OOBEMode" >>%APP_LOG% 2>&1
IF not errorlevel 1 (
	FOR /l %%j in (1,1,5) do (
		ECHO [%TIME%] Start to update registry key [%%j]. >> %APP_LOG%
		Reg.exe add %1 /v "OOBEMode" /t REG_SZ /d OEMTA /f >> %APP_LOG% 2>&1
		if not errorlevel 1 (
			ECHO [%TIME%] Add key successfully. >>%APP_LOG%
			Reg.exe QUERY %1 /v "OOBEMode" >> %APP_LOG% 2>&1
			exit /b 0
		)
		ECHO [%TIME%] Fail to add OOBEMode key..... add again... >> %APP_LOG%
	)
	Echo [%TIME%] Has tried 5 times and still fails to add reg-wow. >>%APP_LOG%
	CALL :UnloadHive
	exit /b 1
) else (
	echo [%TIME%] Cannot query %1 ...., skip  >>%APP_LOG%
	exit /b 0
)


:UnloadHive
echo [%TIME%] Unload HKLM\TempHive >>%APP_LOG%
reg.exe unload HKLM\TempHive >>%APP_LOG%
if errorlevel 1 echo [%TIME%] Unload HKLM\TempHive failed >>%APP_LOG% & goto RESULTFAILED
GOTO:EOF

:RESULTPASSED
ECHO [%TIME%] Result of the %APP_NAME% >> %APP_LOG%
ECHO RESULT=PASSED >> %APP_LOG%
GOTO END

:RESULTFAILED
ECHO [%TIME%] Result of the %APP_NAME% >> %APP_LOG%
ECHO RESULT=FAILED >> %APP_LOG%
if exist c:\system.sav\flags\EnableDebugMode.flg goto END
ECHO [%TIME%] AFOLBREG.cmd fails... >> C:\CTOERROR.flg
ECHO [%TIME%] Please check C:\system.sav\logs\AFOLBREG.cmd.log... >> C:\CTOERROR.flg
GOTO END

:END
ECHO [%TIME%] ============= End of %APP_NAME% ================ >> %APP_LOG%
ENDLOCAL
@ECHO ON