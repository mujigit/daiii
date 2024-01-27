@ECHO OFF

set APP_NAME=Windows 10 HP Image Enhancements - CPS - Delete folder if deleting CVA failed.
set APP_LOG=C:\system.sav\logs\%~n0_%1.log

:SearchInstallCmd
if exist "%APP_LOG%" del /f /q "%APP_LOG%"
ECHO ############################################################# >> %APP_LOG%
ECHO  [%DATE%]                                                     >> %APP_LOG%
ECHO  [%TIME%] Beginning of the %~nx0                              >> %APP_LOG%
ECHO ############################################################# >> %APP_LOG%

pushd c:\SWSetup\App
set RESULT=PASS
for /F "delims=" %%I IN ('dir /s /b install.cmd') do (
	echo %%I | find.exe /I "\src\" > NUL
	if not errorlevel 1 (
		Echo [Skip] %%I is in the src folder, skipped. >> "%APP_LOG%"
	) else (
		Echo Checking "%%I" >> "%APP_LOG%"
		findstr.exe /I /C:"Erase /F /Q *.CVA" "%%I" > "%temp%\%~n0.txt"
		if not errorlevel 1 (
			echo ============= >> "%APP_LOG%"
			type "%temp%\%~n0.txt" >> "%APP_LOG%"
			echo ============= >> "%APP_LOG%"
			findstr.exe /I /C:"rem Erase /F /Q *.CVA" "%temp%\%~n0.txt" > NUL
			if errorlevel 1 (
				Echo [Match] rd /s /q "%%~dpI" >> "%APP_LOG%"
				rd /s /q "%%~dpI" >> "%APP_LOG%" 2>&1
				timeout /t 1
				if exist "%%~dpI" (
					Echo [ERROR] Failed to remove folder: "%%~dpI", set result to failed. >> "%APP_LOG%"
					set RESULT=FAIL
				)
			) else (
				Echo [Mismatch] Keep the folder "%%~dpI" >> "%APP_LOG%"
			)
		) else (
			echo %%I don't include any statement about erasing CVA >> "%APP_LOG%"
		)
	)
	Echo. >> "%APP_LOG%"
	Echo. >> "%APP_LOG%"
)
popd
if /I "%RESULT%"=="FAIL" goto RESULTFAILED
goto RESULTPASSED

:RESULTPASSED
ECHO [%TIME%] Result of the %APP_NAME% >> %APP_LOG%
ECHO RESULT=PASSED >> %APP_LOG%
GOTO END

:RESULTFAILED
ECHO [%TIME%] Result of the %APP_NAME% >> %APP_LOG%
ECHO RESULT=FAILED >> %APP_LOG%
GOTO END

:END
ECHO ############################################################# >> %APP_LOG%
ECHO  [%DATE%]                                                     >> %APP_LOG%
ECHO  [%TIME%] End of the %~nx0                                    >> %APP_LOG%
ECHO ############################################################# >> %APP_LOG%
@ECHO ON


