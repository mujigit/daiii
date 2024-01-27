@Echo [%TIME%] Start PostOOBEM.cmd>>C:\System.sav\Logs\PostOOBEPIN.log

@Echo off
:START_CMD
call "C:\hp\bin\ImgEnhFixReg.CMD"


:INSERT_CMD



IF EXIST C:\system.sav\Flags\RMINImg.flg (
	@Echo [%DATE% - %TIME%] MIR flag is detected... may skip some command..>>C:\System.sav\Logs\PostOOBEPIN.log
	GOTO END
)
@REM Add your command that doesn't need to run MIR case
@REM  if your .cmd doesn't have MIR detection
:SKIP_MIR
@Echo [%TIME%] calling [c:\hp\bin\cmdline.cmd].>>C:\System.sav\Logs\PostOOBEPIN.log
@Echo [%TIME%] calling [c:\hp\bin\cmdline.cmd].>>C:\System.sav\Flags\BTBcmd.flg
IF EXIST c:\hp\bin\cmdline.cmd (
	Start /w c:\hp\bin\hputilck.exe c:\hp\bin\commands /c c:\hp\bin\cmdline.cmd
)
@Echo [%TIME%] called [c:\hp\bin\cmdline.cmd].>>C:\System.sav\Logs\PostOOBEPIN.log
@Echo [%TIME%] called [c:\hp\bin\cmdline.cmd].>>C:\System.sav\Flags\BTBcmd.flg

:END
@Echo [%TIME%] End PostOOBEM.cmd>>C:\System.sav\Logs\PostOOBEPIN.log
EXIT

