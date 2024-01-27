set customLogSpec=c:\system.sav\logs\BTBHost\customData2pp.log

echo==========%date% %time% BtBCustomData start==========>>%customLogSpec%
pushd %~dp0
echo Working dir is %CD%>>%customLogSpec%

if exist c:\system.sav\util\TDCsetVariables.cmd call c:\system.sav\util\TDCsetVariables.cmd
if exist c:\system.sav\util\setVariables.cmd call c:\system.sav\util\setVariables.cmd
c:\system.sav\util\WizInstaller.exe c:\system.sav\util\2postprocess\customdata\customData.ini>>c:\system.sav\logs\BTBHost\WizInstaller.log

rd /s/q customdata
echo==========%date% %time% BtBCustomData end==========>>%customLogSpec%