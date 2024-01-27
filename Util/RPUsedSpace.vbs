' --------------------------------------------------
'  Get RP used space in Gbyte.
' --------------------------------------------------
Dim oStorage, colVols, objVol
Dim RPUsedSpace
Dim oFSO
Dim LogFile, oFile
Const ForAppending = 8

RPUsedSpace = 0
LogFile="C:\System.sav\Logs\RPUsedSpace.log"

Set oFSO = CreateObject("Scripting.FileSystemObject")

Set oStorage = GetObject("winmgmts:\\.\root\cimv2")
Set colVols = oStorage.ExecQuery("SELECT * FROM Win32_Volume")

For Each objVol In colVols
	If LCase(objVol.Label) = "recovery" Then
		RPUsedSpace = (objVol.Capacity - objVol.FreeSpace) / 1024 / 1024 / 1024
		Exit For
	End If
Next

If RPUsedSpace > 27.8 Then
	Set oFile = oFSO.OpenTextFile(LogFile, ForAppending , True)
	oFile.WriteLine "[RP Used Space]"
	oFile.WriteLine "RP used space = " & RPUsedSpace & " (GB)"
	oFile.WriteLine "Warning => RP used space is over 27.8 GB"
	oFile.Close
End If
