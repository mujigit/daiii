Const ForReading = 1, ForWriting = 2, ForAppending = 8

'check args
set oArgs = wscript.arguments
if oArgs.count <> 1 then
	wscript.echo "Error args !!"
	wscript.quit 99
end if

BCDLogFullPath = oArgs(0)
 
DeleteFile(BCDLogFullPath)

OSGUID=NONE

Set oShell = WScript.CreateObject("WScript.shell")
Set oFs = CreateObject("Scripting.FileSystemObject")

oShell.Run "cmd /c bcdedit -enum -v > " & BCDLogFullPath , 0, true
bFindWinBootLoader=0 
Set inFile = oFs.OpenTextFile(BCDLogFullPath, ForReading , True)
Do While Not inFile.AtEndOfStream
  sText = inFile.ReadLine	
  If InStr(sText,"Windows Boot Loader") Then                             
  	bFindWinBootLoader=1
  End If
  
  If bFindWinBootLoader=1 Then
    If InStr(sText,"identifier") Then                             
    	OSGUID= Trim(Replace( sText, "identifier", ""))
    End If
  End If
Loop
inFile.Close 

WScript.Echo  "OSGUID=" & OSGUID
WScript.Quit 0


Sub DeleteFile(filespec)
	Const ForReading = 1, ForWriting = 2, ForAppending = 8
	Dim fso
	Set fso = CreateObject("Scripting.FileSystemObject")
	if fso.FileExists(filespec) Then
		fso.DeleteFile(filespec)
	End If
End Sub

