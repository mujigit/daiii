@echo off
set BF_DETECT_MB=none
set BF_SPLIT_MB=none

for /f "eol=[ tokens=1,2 delims==, " %%i in (BFInSize.ini) do (
  if %%i==DetectMB (set BF_DETECT_MB=%%j)
  if %%i==SplitMB  (set BF_SPLIT_MB=%%j))
  
echo [%time%][%~n0] Info, BF_DETECT_MB=%BF_DETECT_MB%
echo [%time%][%~n0] Info, BF_SPLIT_MB=%BF_SPLIT_MB%