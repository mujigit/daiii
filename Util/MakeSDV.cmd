REM ======================================================================
REM  Function:    MakeSDV
REM  Description: Create SDV of 2nd GS for WDT
REM ======================================================================

@echo off
 set flagCTO=c:\CTOError.flg
 set flagFusion=c:\system.sav\fusion.flg
 set makeSdvL=c:\system.sav\logs\sdv_make.log
 set pathMount=c:\mount
 set pathTarget=c:\system.sav\wsdvtdc

 echo [%time%][%~n0] --- Start --- >>%makeSdvL%

 echo [%time%][%~n0] Info, Run WPEinit.exe to fix can't mount wim file at WinPE >>%makeSdvL%
 wpeinit.exe >>%makeSdvL%

 if not exist "c:\system.sav\logs"  (md c:\system.sav\logs >>%makeSdvL%)
 if not exist "c:\system.sav\flags" (md c:\system.sav\flags >>%makeSdvL%)

 if exist "c:\system.sav\flags\nosdv.flg" (
    echo [%time%][%~n0] Info, Detected the NOSDV.FLG. Skip to make WDT SDV. >>%makeSdvL%
    rd  /s/q c:\system.sav\wsdvtdc\  >>%makeSdvL%
    del /f/q c:\system.sav\util\makesdv.cmd  >>%makeSdvL%
    goto end )

REM --- Remove cln.flg on non-fusion image ---
 if exist "%flgFusion%" (goto fusion)
 if exist "c:\cln.flg"  (
    echo [%time%][%~n0] Info, Remvoe up:\cln.flg on non-Fusion Image >>%makeSdvL%
    del /f/q c:\cln.flg )


:fusion
 if not exist "%pathTarget%" (md %pathTarget% >>%makeSdvL%)

 REM --- clone biosconfig tools to c:\system.sav\wsdvtdc\secureboot ---
 if not exist "c:\system.sav\exclude\biosconfig" (
    echo [%time%][%~n0] Error, Can't find c:\system.sav\Exclude\BiosConfig tools >>%makeSdvL%
    echo [%time%][%~n0] Error, Can't find c:\system.sav\Exclude\BiosConfig tools >>%flagCTO%
    goto end )

 md %pathTarget%\secureboot
 echo [%time%][%~n0] Info, Clone c:\system.sav\exclude\biosconfig to %pathTarget%\secureboot >>%makeSdvL%
 xcopy /fseyihr c:\system.sav\exclude\biosconfig\*.* %pathTarget%\secureboot >>%makeSdvL%
 if not errorlevel 0 (
    echo [%time%][%~n0] Error, Can't clone BiosConfig tool from  C:\system.sav\Exclude\BiosConfig to %pathTarget%\secureboot >>%flagCTO%
    type %flagCTO% >>%makeSdvL%
    goto end )

 REM --- clone boot.sdi from bp ---
 if not exist "d:\boot\boot.sdi" (
    echo [%time%][%~n0] Error, Can't find BP sdi at d:\boot\boot.sdi >>%flagCTO%
    type %flagCTO% >>%makeSdvL%
    goto end )

 xcopy /fseyihr d:\boot\boot.sdi %pathTarget% >>%makeSdvL%
 if not errorlevel 0 (
    echo [%time%][%~n0] Error, Can't clone boot sdi from  d:\boot\boot.sdi to %pathTarget%\boot.sdi >>%flagCTO%
    type %flagCTO% >>%makeSdvL%
    goto end )

 REM --- clone boot.wim from bp ---
 if not exist "d:\sources\boot.wim" (
    echo [%time%][%~n0] Error, Can't find BP wim at d:\sources\boot.wim >>%flagCTO%
    type %flagCTO% >>%makeSdvL%
    goto end )

 xcopy /fseyihr d:\sources\boot.wim %pathTarget% >>%makeSdvL%
 if not errorlevel 0 (
    echo [%time%][%~n0] Error, Can't clone boot wim from d:\sources\boot.wim to %pathTarget%\boot.wim  >>%flagCTO%
    type %flagCTO% >>%makeSdvL%
    goto end )

 REM --- debug mode ---
 if exist "c:\rmdebug.flg" (
    echo [%time%][%~n0] Debug, Clone boot.sdi and wim to c:\system.sav\logs >>%makeSdvL%
    xcopy /fseyihr d:\boot\boot.sdi c:\system.sav\logs >>%makeSdvL%
    xcopy /fseyihr d:\sources\boot.wim c:\system.sav\logs >>%makeSdvL%
    echo [%time%][%~n0] Debug, Rename SSRDSIM.flg at c:\system.sav\flags >>%makeSdvL%
    ren c:\system.sav\flags\SSRDSIM.flg c:\system.sav\flags\SSRDSIM.don >>%makeSdvL% )
 if exist "c:\nowSDV.flg" (
    echo [%time%][%~n0] Debug, Trigger by now SDV flag. >c:\ctoerror.flg
    type c:\ctoerror.flg >>%makeSdvL%
    type c:\ctoerror.flg >>c:\rmdebug.flg )

 REM --- inject sdv tools ---
 if exist %pathMount% (rd /s/q %pathMount% >>%makeSdvL%)
 md %pathMount% >>%makeSdvL%
 dism /mount-wim /wimfile:%pathTarget%\boot.wim /index:1 /mountdir:%pathMount% /logpath:c:\system.sav\logs\SDV_dism.log >>%makeSdvL%
 if not errorlevel 0 (
    echo [%time%][%~n0] Error, Can't mount %pathTarget%\boot.wim >>%flagCTO%
    type %flagCTO% >>%makeSdvL%
    goto end )

 xcopy /fseyihr %pathTarget%\import\*.* %pathMount% >>%makeSdvL%
 if not errorlevel 0 (
    echo [%time%][%~n0] Error, Can't clone SDV toolset from %pathTarget%\import\*.* to %pathMount%\*.* >>%flagCTO%
    type %flagCTO% >>%makeSdvL%
    goto end )

 REM --- [3c15-w10-cnb][37] refer syswow64 to reconfigure tool path for merging x86 and x64 toolset (2015-6-25) ---
 echo [%time%][%~n0] +------------------------------ >>%makeSdvL%
 echo [%time%][%~n0] + reconfige toolset             >>%makeSdvL%
 echo [%time%][%~n0] +------------------------------ >>%makeSdvL%
 if exist "%pathMount%\windows\syswow64\" (
    echo [%time%][%~n0] Info, Detected x64 winpe. >>%makeSdvL%
    echo [%time%][%~n0] Info, Using x64 toolset. >>%makeSdvL%
    xcopy /fichersky %pathMount%\tool-amd64\*.* %pathMount%\Rita-tool >>%makeSdvL%
 ) else (
    echo [%time%][%~n0] Info, Detected x86 winpe. >>%makeSdvL%
    echo [%time%][%~n0] Info, Using x86 toolset. >>%makeSdvL%
    xcopy /fichersky %pathMount%\tool-x86\*.* %pathMount%\Rita-tool >>%makeSdvL% )

 rd /s/q %pathMount%\tool-amd64
 rd /s/q %pathMount%\tool-x86


 REM --- query drivers and packages ---
 echo [%time%][%~n0] Info, Query drivers under SDV >>%makeSdvL%
 dism /image:%pathMount% /get-drivers  >>%makeSdvL%

 echo [%time%][%~n0] Info, Query packages under SDV >>%makeSdvL%
 dism /image:%pathMount% /get-packages >>%makeSdvL%

 echo [%time%][%~n0] Info, Dism unmount >>%makeSdvL%
 dism /unmount-wim /mountdir:%pathMount% /commit >>%makeSdvL%

 if exist "%pathMount%"         (rd /s/q %pathMount% >>%makeSdvL%)
 if exist "%pathTarget%\import" (rd /s/q %pathTarget%\import >>%makeSdvL%)

:end
 echo [%time%][%~n0] --- End --- >>%makeSdvL%
 set flagCTO=
 set pathTarget=
 set pathMount=

