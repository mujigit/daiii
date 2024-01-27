@REM copy if there is log file[s] in [c:\system.sav\Exclude\Logs] folder.
IF EXIST c:\system.sav\Exclude\Logs (xcopy c:\system.sav\Exclude\Logs\*.* c:\system.sav\Logs\*.* /cherky)

@REM Remove HP DevCon [HPDMxx.exe].
IF EXIST c:\system.sav\util\HPDM32.exe (DEL /F /q c:\system.sav\util\HPDM32.exe)
IF EXIST c:\system.sav\util\HPDM64.exe (DEL /F /q c:\system.sav\util\HPDM64.exe)
IF EXIST c:\system.sav\util\StartNet.cmd (DEL /F /q c:\system.sav\util\StartNet.cmd)
IF EXIST c:\system.sav\P2PP (RD /S /Q c:\system.sav\P2PP)
IF EXIST c:\system.sav\bbv (RD /S /Q c:\system.sav\bbv)
IF EXIST c:\system.sav\2ndCap (RD /S /Q c:\system.sav\2ndCap)
IF EXIST c:\system.sav\ExitProc (RD /S /Q c:\system.sav\ExitProc)
IF EXIST c:\system.sav\Exclude (RD /S /Q c:\system.sav\Exclude)
IF EXIST c:\system.sav\TDCUtil (RD /S /Q c:\system.sav\TDCUtil)
IF EXIST C:\System.sav\Util\TDC\MCPP\FBIRES (RD /S /Q C:\System.sav\Util\TDC\MCPP\FBIRES)
IF EXIST C:\system.sav\util\PINLOG (RD /S /Q C:\system.sav\util\PINLOG)

SET FOLDER.PATH=C:\Config.Msi
IF EXIST %FOLDER.PATH% (
  ATTRIB -S -H -R %FOLDER.PATH%
  RD /S /Q  %FOLDER.PATH%   
)

exit
