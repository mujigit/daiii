@echo off
 
 for %%i in (C, D, E, F, G, H, I, J, K, L, M, N, O, P, Q, R, S, T, U, V, W, X, Y, Z) do if exist %%i:\system.sav\flags\up.flg set DrvUP=%%i:& goto next_step
 goto cant_found_up
 
:next_step
 set logfile=%DrvUP%\system.sav\logs\bfevents.log
 
 if not exist %DrvUP%\system.sav\logs ( mkdir %DrvUP%\System.sav\logs )
 
 echo [%time%][%~n0] +----------------------------------- >>%logfile%
 echo [%time%][%~n0] + Run Big File Merge For SR Command  >>%logfile%
 echo [%time%][%~n0] +----------------------------------- >>%logfile%
 
 if not exist "%DrvUP%\windows\syswow64\" (
    pushd %DrvUP%\system.sav\util\BF32
    BFHandler.exe /merge %DrvUP%\system.sav\util\bfmerge.ini %DrvUP%\ >>%logfile%
    BFHandler.exe /RemovePart %DrvUP%\system.sav\util\bfmerge.ini %DrvUP%\ >>%logfile%
 ) else (
    pushd %DrvUP%\system.sav\util
    BFHandler.exe /merge %DrvUP%\system.sav\util\bfmerge.ini %DrvUP%\ >>%logfile%
    BFHandler.exe /RemovePart %DrvUP%\system.sav\util\bfmerge.ini %DrvUP%\ >>%logfile%
 )

 popd
 goto end
 
:cant_found_up
 
:end
 echo.>>%logfile%
 