@echo off
IF EXIST C:\system.sav\ExitProc (rd /s /q C:\system.sav\ExitProc)
IF EXIST C:\system.sav\bbv (rd /s /q C:\system.sav\bbv)
IF EXIST C:\system.sav\2ndCap (rd /s /q C:\system.sav\2ndCap)
IF EXIST C:\system.sav\util\WriteIni.exe (del /f /q C:\system.sav\util\WriteIni.exe)

SET FOLDER.PATH=C:\Config.Msi
IF EXIST %FOLDER.PATH% (
  ATTRIB -S -H -R %FOLDER.PATH%
  RD /S /Q  %FOLDER.PATH%   
)

