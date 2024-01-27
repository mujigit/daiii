SET CRM.WPDRVLETTER=%1
SET CRM.RUN=%2
SET CRM.ROOTPATH=%CRM.WPDRVLETTER%\Recovery
SET CRM.PATH1=%CRM.ROOTPATH%\Customizations
SET CRM.PATH2=%CRM.ROOTPATH%\OEM


CALL :SETFULLACCESS "%CRM.PATH1%"
CALL :SETFULLACCESS "%CRM.PATH2%"
ATTRIB +H %CRM.ROOTPATH%

:END
EXIT /B

:SETFULLACCESS
SET CRM.LOCKPATH=%~1

REM /inheritance:r - remove all inherited ACEs
REM /T - Traverse all subfolders to match files/directories.
REM (F) - full access
ECHO [%time%][%~nx0] icacls "%CRM.LOCKPATH%" /inheritance:r /T
icacls "%CRM.LOCKPATH%" /inheritance:r /T

ECHO [%time%][%~nx0] icacls "%CRM.LOCKPATH%"  /grant:r SYSTEM:(F) /T
icacls "%CRM.LOCKPATH%"  /grant:r SYSTEM:(F) /T

ECHO [%time%][%~nx0] icacls "%CRM.LOCKPATH%"  /grant:r *S-1-5-32-544:(F) /T
icacls "%CRM.LOCKPATH%"  /grant:r *S-1-5-32-544:(F) /T
EXIT /B