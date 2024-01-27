@REM Don't need to estimate WP free space for each memory size and only check WP free space at end of BBV2
@REM IF EXIST C:\system.sav\Util\ChkFreeSize.vbs (CScript.exe /nologo C:\system.sav\Util\ChkFreeSize.vbs)
@REM
IF EXIST C:\system.sav\Util\RPUsedSpace.vbs (CScript.exe /nologo C:\system.sav\Util\RPUsedSpace.vbs)
IF EXIST C:\system.sav\Util\PINChkT.exe C:\system.sav\Util\PINChkT.exe
TYPE C:\System.sav\Logs\ChkFreeSize.log >> C:\System.sav\Logs\PINChkT.txt
TYPE C:\System.sav\Logs\RPUsedSpace.log >> C:\System.sav\Logs\PINChkT.txt