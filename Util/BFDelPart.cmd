@echo off
 REM +-----------------------------------------------------
 REM + Run Big File remove the splited part files Command
 REM +-----------------------------------------------------

 for %%i in (C, D, E, F, G, H, I, J, K, L, M, N, O, P, Q, R, S, T, U, V, W, X, Y, Z) do if exist %%i:\system.sav\flags\up.flg set DrvUP=%%i:& goto next_step
 goto cant_found_up

:next_step
 if not exist %DrvUP%\system.sav\logs mkdir %DrvUP%\System.sav\logs

 set logfile=%DrvUP%\system.sav\logs\bfevents.log
 set BF_UTILITY=BFHandler.exe
 if not exist "%DrvUP%\windows\syswow64\" (
    set BF_UTILITY=.\BF32\BFHandler.exe
    echo [%time%][%~n0] Info, Detect Windows x86 OS >>%logfile% )
    
 echo [%time%][%~n0] Info, Use %BF_UTILITY% >>%logfile%
 echo [%time%][%~n0] Info, Start part files remove >>%logfile%
 
 pushd %DrvUP%\system.sav\util
  %BF_UTILITY% /RemovePart %DrvUP%\system.sav\util\bfmerge.ini c:\ >>%logfile%
 popd
 
 goto exit

:cant_found_up
 echo [%time%][%~n0] Error, Can't find UP >>%logfile%
 goto exit

:exit
 echo [%time%][%~n0] End part files remove >>%logfile%
 echo.>>%logfile%

