@Echo [%TIME%] Start PostLast.cmd>>C:\System.sav\Logs\PostOOBEPIN.log

@Echo off
:START_CMD

:INSERT_CMD


IF EXIST C:\system.sav\Flags\RMINImg.flg (
	@Echo [%TIME%] MIR flag is detected... may skip some command..>>C:\System.sav\Logs\PostOOBEPIN.log
	GOTO END
)
@REM Add your command that doesn't need to run MIR case
@REM  if your .cmd doesn't have MIR detection
:SKIP_MIR


:END
:KILL_ANIMATEDLOGO
IF EXIST c:\system.sav\Flags\Win7.flg (
	@REM ==== always Kill animatedLogo.exe ====
	C:\Windows\System32\TIMEOUT.exe /T 3
	taskkill.exe /im animatedLogo.exe>>C:\System.sav\Logs\PostLast.log
)
IF EXIST C:\System.sav\Util\postpin\CleanUp.cmd (START C:\System.sav\Util\postpin\CleanUp.cmd)
IF EXIST C:\System.sav\Util\TDCTWKs (RD /S /Q C:\System.sav\Util\TDCTWKs)
@Echo [%TIME%] End PostLast.cmd>>C:\System.sav\Logs\PostOOBEPIN.log
@Echo [%TIME%] End PostLast.cmd>>C:\System.sav\Flags\PostPINcmd.flg
EXIT
