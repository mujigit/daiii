@echo off
 
 set BF_DETECT_MB=none
 set BF_SPLIT_MB=none
 set BF_UTILITY=BFHandler.exe
 set logfile=c:\system.sav\logs\bfevents.log

 if not exist "c:\system.sav\logs\" (mkdir c:\system.sav\logs)

 echo [%time%][%~n0] +----------------------------------- >>%logfile%
 echo [%time%][%~n0] + Run Big File Split Command         >>%logfile%
 echo [%time%][%~n0] +----------------------------------- >>%logfile%
 
 if not exist "c:\windows\syswow64\" (
    set BF_UTILITY=.\bf32\bfhandler.exe
    echo [%time%][%~n0] Info, Detect Windows x86 OS >>%logfile% )

 echo [%time%][%~n0] Info, Use %BF_UTILITY% >>%logfile%
 echo [%time%][%~n0] Info, Start big file split >>%logfile%

 pushd c:\system.sav\util
  echo [%time%][%~n0] Info, Get big file setting >>%logfile%
  call GetBFSetting.cmd >>%logfile%
  echo.>>%logfile%

  if /i "%BF_DETECT_MB%"=="none" (
      echo [%time%][%~n0] Warning, Can't get BF_DETECT_MB, set to default 750 Mb >>%logfile%
      set BF_DETECT_MB=750)

  if /i "%BF_SPLIT_MB%"=="none" (
      echo [%time%][%~n0] Warning, Can't get BF_SPLIT_MB, set to default 750 Mb >>%logfile%
      set BF_SPLIT_MB=750)

  %BF_UTILITY% /split c:\ c:\system.sav\util\bfexcu.ini c:\system.sav\util\bfmerge.ini %BF_DETECT_MB% %BF_SPLIT_MB% /Exclusion c:\system.sav\util\bfnosplit.ini >>%logfile%
  if not errorevel 0 ( echo [%time%][%~n0] Error, Big File split fail, please check bfevent.log >c:\ctoerror.flg )
 popd

 echo [%time%][%~n0] Info, End big file split >>%logfile%
 echo.>>%logfile%

 if exist c:\system.sav\BigTest.flg (copy c:\System.sav\PureOS\PureOS2.INI+c:\system.sav\util\bfexcu.ini  c:\System.sav\PureOS\PureOS2.INI)
