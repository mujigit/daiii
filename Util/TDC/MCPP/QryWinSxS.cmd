IF EXIST C:\system.sav\Flags\Win7.flg GOTO END
SET LOG_PATH=C:\System.sav\Logs\ClnWinSxS.log

Echo. >> %LOG_PATH%
Echo [%time%] ================================================== >> %LOG_PATH%
Echo [%time%] After cleanup component store (WinSxS folder) >> %LOG_PATH%
Echo [%time%] Query WinSxS at [%2] [%1] phase... >> %LOG_PATH%
DIR C:\ >> %LOG_PATH%
Echo [%time%] ================================================== >> %LOG_PATH%
Echo. >> %LOG_PATH%

:END
