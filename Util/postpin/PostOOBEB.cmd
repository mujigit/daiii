@Echo [%TIME%] Start PostOOBE.cmd>>C:\System.sav\Flags\PostPINcmd.flg
@Echo [%TIME%] Start PostOOBE.cmd>>C:\System.sav\Logs\PostOOBEPIN.log
IF EXIST C:\System.sav\Flags\EnableDebugMode.flg (
	@reg.exe Query HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\RunOnce >> C:\System.sav\Logs\PINPROC\Reg4OOBE.log
	@reg.exe Query HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Run >> C:\System.sav\Logs\PINPROC\Reg4OOBE.log
)

@Echo off
:START_CMD
"%COMMONPROGRAMFILES%\Microsoft Shared\ClickToRun\OfficeClickToRun.exe" scenario=CULTUREREFRESH RemoveNonClientCultures=True displaylevel=False

:INSERT_CMD

IF EXIST C:\system.sav\Flags\RMINImg.flg (
	@Echo [%TIME%] MIR flag is detected... may skip some command..>>C:\System.sav\Logs\PostOOBEPIN.log
	GOTO END
)
@REM Add your command that doesn't need to run MIR case
@REM  if your .cmd doesn't have MIR detection
:SKIP_MIR

:END
@Echo [%TIME%] End PostOOBE.cmd>>C:\System.sav\Logs\PostOOBEPIN.log
EXIT
