REM Another copy at c:\system.sav\ExitProc\Subs\

REM ========================================================
REM   Template Version: 2.00
REM ========================================================

@ECHO OFF
SET APP_NAME=Windows 10 HP Image Enhancements - CPS - DHCP Information Clean and add into exclusion list.
SET APP_LOG=C:\System.sav\LOGS\BB\%~n0.LOG
IF NOT EXIST C:\System.sav\LOGS\BB MD C:\System.sav\LOGS\BB

ECHO ############################################################# >> %APP_LOG%
ECHO  [%DATE%]                                                     >> %APP_LOG%
ECHO  [%TIME%] Beginning of the %~nx0                              >> %APP_LOG%
ECHO ############################################################# >> %APP_LOG%


REM ------------------- Script Entry ------------------------
set PPKG_EXLIST_REG=C:\RM\RERM\DeployRP\PPKGXML\Exclude\RegistryKeys\%~n0.list

ECHO Argument=[%1] >> %APP_LOG%

for /f "delims=" %%i in ('Reg.exe query "HKLM\System\CurrentControlSet\Services" /s /f "DhcpDomain" /v') do (
	echo "%%~i"|find.exe /i "CurrentControlSet\Services" >nul
	if not errorlevel 1 (
		ECHO Query %%i before delete... >> %APP_LOG%
		reg.exe query "%%i" /v "DhcpDomain" >>%APP_LOG%

		ECHO Delete %%i... >> %APP_LOG%
		reg.exe delete "%%i" /v "DhcpDomain" /f >>%APP_LOG%
		if errorlevel 1 (
			goto RESULTFAILED
		)
		if /i "%1"=="GenPpkgExList" (
			ECHO. >> %APP_LOG%
			ECHO. >> %APP_LOG%
			ECHO Generate PPKG exclusion list... >> %APP_LOG%
			if not exist "C:\RM\RERM\DeployRP\PPKGXML\Exclude\RegistryKeys" echo Creating "C:\RM\RERM\DeployRP\PPKGXML\Exclude\RegistryKeys">>%APP_LOG% & mkdir "C:\RM\RERM\DeployRP\PPKGXML\Exclude\RegistryKeys"
			ECHO %%i\* [DhcpDomain]>> %APP_LOG%
			echo %%i\* [DhcpDomain]>>%PPKG_EXLIST_REG%
		) else (
			ECHO Do not generate PPKG exclusion list arg1[%1]... >> %APP_LOG%
		)

		ECHO. >> %APP_LOG%
		ECHO. >> %APP_LOG%
		ECHO. >> %APP_LOG%
		ECHO Query %%i again after delete... >> %APP_LOG%
		reg.exe query "%%i" /v "DhcpDomain" >>%APP_LOG%
		if not errorlevel 1 echo "%%i" is still there & goto :RESULTFAILED
		ECHO. >> %APP_LOG%
		ECHO. >> %APP_LOG%
	)
)

type %PPKG_EXLIST_REG% >>%APP_LOG%
xcopy /y %PPKG_EXLIST_REG% c:\System.sav\LOGS\BB\
goto RESULTPASSED

REM ------------------- Script exit ------------------------

:RESULTPASSED
ECHO [%TIME%] Result of the %APP_NAME% >> %APP_LOG%
ECHO RESULT=PASSED >> %APP_LOG%
GOTO END

:RESULTFAILED
ECHO [%TIME%] Result of the %APP_NAME% >> %APP_LOG%
ECHO RESULT=FAILED >> %APP_LOG%
GOTO END

:END
@ECHO ON
