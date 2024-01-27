'--- Arguments checking ---
if CheckArgumentCount(3)=false then
  wscript.echo "script error aragument!"
  wscript.quit(1)
end if

'--- const definition ---
const Kbytes = 1024
const ForReading = 1, ForWriting = 2, ForAppending = 8

'--- Variable definition ---
set oArgs = wscript.Arguments
strImagePath = oArgs(0)
strIndex = oArgs(1)
argFailFlag = oArgs(2)

echo "+----------------------------------------"
echo ": Check Free Space for PBR               "
echo "+----------------------------------------"

UPFreeSpaceMB = 0
ImageSizeMB = 0
LimitRate=1.2

Msg1="Rule : The amount of free disk space required to Refresh your PC feature is equal to the size of expanded recovery image and an additional 20% buffer"
echo Msg1


UPFreeSpaceMB = QueryFreeSpace("C")
echo "UP Free Space = " & UPFreeSpaceMB & " MB"    

ImageSizeMB = QueryImageSize(strImagePath, strIndex)
echo "Index#" & strIndex & " Size = " & ImageSizeMB & " MB"

If UPFreeSpaceMB = 0 then
	WSCript.Quit 0
End If

If ImageSizeMB = 0 then
	WSCript.Quit 0
End If

IF (UPFreeSpaceMB < ImageSizeMB*LimitRate) Then
	ECHO "Result = FAIL"
	WriteFile argFailFlag, "Error, The UP Free Space is not enough to do PBR Refresh"
ELSE
	ECHO "Result = PASS"
End If



WSCript.Quit 0

REM ---------------------------------
REM  Query Free Space by Drive Letter  
REM ---------------------------------
function QueryFreeSpace(strDrvLetter)
	DRIVE_FIXED = 2
	QueryFreeSpace = 0
	set oFs = createObject("Scripting.FileSystemObject")
	set colDrivers = oFs.Drives
	for each item in colDrivers
	  if item.DriveLetter = strDrvLetter and item.DriveType = DRIVE_FIXED then
	      QueryFreeSpace = Round(item.freespace / 1024 / 1024)
	  end if 
	next 
end function




' ===================================================
' Query Image Size
' ===================================================
Function QueryImageSize(strFile, strIndex)
	QueryImageSize = 0
	strCmd = "DISM.exe /get-wiminfo /wimfile:" & strFile & " /english"
	'WScript.echo strCmd
	Set WShell = CreateObject("WScript.Shell")
	Set objExec = WShell.Exec(strCmd)
	Do While objExec.Status = 0                   
	  	WScript.Sleep 1000                      
	Loop                                        
    	strOutput = objExec.StdOut.ReadAll()
    
    	strCurrentPath = WShell.CurrentDirectory & "\"
    	strTmp = strCurrentPath & "Log.txt"
    
    	Set objFSO   = CreateObject( "Scripting.FileSystemObject" )
    	WShell.Run "cmd.exe /c del /F /Q " & strTmp, 0, true
    	Set objW = objFSO.CreateTextFile( strTmp, False, False )
    	objW.Write(strOutput)
    	objW.Close()
    
    	Set objR = objFSO.OpenTextFile(strTmp, ForReading, True )
	bFindIndex=0
	bFindSize=0
    	While objR.AtEndOfStream = False
    		strLine = Trim( objR.ReadLine )
    		strLine = LCase(strLine)
		If InStr(strLine, "index : " & strIndex) Then
			bFindIndex=1
		End If

    		If InStr(strLine, "size :") and bFindIndex = 1 and bFindSize=0 Then
    			strLine = Replace(strLine,"size :","")
    			strLine = Replace(strLine," ","")
    			strLine = Replace(strLine,",","")
    			strLine = Replace(strLine,"bytes","")
    			QueryImageSize = strLine
			QueryImageSize = Round(QueryImageSize / 1024 / 1024)
			bFindSize=1
    		End If
    	Wend
End Function



Rem ---------------------------------
Rem  echo log  
Rem ---------------------------------
function Echo(message)
 name = Replace(lCase(wscript.ScriptName), ".vbs", "")
 text = "[" & time  & "]" & "[" & name & "] " & message
 wscript.echo text
end function



Rem ---------------------------------
Rem check argument count 
Rem ---------------------------------
function CheckArgumentCount(count)
 set ofArgs = wscript.Arguments
 CheckArgumentCount=true
 if ofArgs.count <> count then
    CheckArgumentCount=false
 end if
 set ofArgs = nothing
end function


Rem --------------------------
Rem  Write data to file 
Rem --------------------------
function WriteFile( fileName, text )
    const ForAppending = 8
    const ForWriting = 2
    set ofFso = CreateObject("Scripting.FileSystemObject")
    'open file
    if ofFso.FileExists(fileName) then
        set ofFile = ofFso.OpenTextFile(fileName, ForAppending, True)
    else 
        set ofFile = ofFso.OpenTextFile(fileName, ForWriting, True)
    end if
    
    'write data
    ofFile.WriteLine("[" & time  & "]" & "[" & wscript.ScriptName & "] " & text)
    
    'close file
    ofFile.Close    
    set ofFile = nothing
end function