@echo off
 set logfile=C:\system.sav\logs\bfevents.log
 
 if not exist c:\system.sav\logs ( mkdir c:\system.sav\logs )
 
 echo [%time%][%~n0] +----------------------------------- >>%logfile%
 echo [%time%][%~n0] + Run Big File Merge Command         >>%logfile%
 echo [%time%][%~n0] +----------------------------------- >>%logfile%
 
 set BF_UTILITY=BFHandler.exe
 if not exist "c:\windows\syswow64\" (
    set BF_UTILITY=.\BF32\BFHandler.exe
    echo [%time%][%~n0] Info, Detect Windows x86 OS >>%logfile% )
    
 echo [%time%][%~n0] Info, Use %BF_UTILITY% >>%logfile%
 echo [%time%][%~n0] Info, Start big file merge >>%logfile%
 
 pushd C:\system.sav\util
 
  if exist c:\system.sav\flags\RMMinRecovery.flg (
     %BF_UTILITY% /merge c:\system.sav\util\bfmerge.ini c:\ /MIR c:\system.sav\util\BFMIR.ini >>%logfile%  
  ) else (
     %BF_UTILITY% /merge c:\system.sav\util\bfmerge.ini c:\ >>%logfile% )
 
 popd
 
 echo.>>%logfile%
