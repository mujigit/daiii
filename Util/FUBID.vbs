Option Explicit
'
' Update Burn-In-Date in Factory Update.
'
'
Const ForReading = 1, ForWriting = 2
Const OutPutFile = "C:\Windows\CSUP.txt"

Dim strOrgBurnInDate		' BurnInDate in C:\Windows\csup.txt	(mm-dd-yyyy)
Dim strFUBurnInDate		' Last Modified date of Update.cmd in Factory Update
Dim strUpdateCMD		' Full path for Update.cmd

Dim objArgs			' Object for Arguments
Dim objFSO			' Object for FileSystemObject

Dim strTmpOriginal
Dim strTmpFUpdate

' ----------------------------------------
' Check Parameter
' ----------------------------------------
Set objArgs = WScript.Arguments

If objArgs.Count <> 1 Then
  WScript.Echo "Number of parameters is not 1..."
  Wscript.Quit(1)		' unexpected number of Parameter.
End If


strUpdateCMD = objArgs(0)	' Set the fullpath of the Update.cmd
WScript.Echo "Fullpath of Update.cmd is [" & strUpdateCMD & "]"


Set objFSO= CreateObject("Scripting.FileSystemObject")
If Not objFSO.FileExists( strUpdateCMD ) Then
  WScript.Echo "Could not access [" & strUpdateCMD & "]"
  WScript.Quit(2)		' could not access Update.cmd
End If

' ----------------------------------------
' Get Original BurnInDate
' ----------------------------------------
Call GetBurnInDate()

' ----------------------------------------
' Get Last Modified
' ----------------------------------------
strFUBurnInDate = GetModifiedDate(strUpdateCMD )

' ----------------------------------------
' Compare original and Update.cmd
' ----------------------------------------
strTmpOriginal = Mid(strOrgBurnInDate, 7) & strOrgBurnInDate
strTmpFUpdate = Mid(strFUBurnInDate , 7) & strFUBurnInDate 

WScript.Echo "Original : " & strOrgBurnInDate
WScript.Echo "FUpdate  : " & strFUBurnInDate 

If StrComp(strTmpOriginal, strTmpFUpdate ) < 0 Then
  ' Update.cmd is newer
  ' Update
  WScript.Echo "Update CSUP.txt..."
  WriteBurnInDate(strFUBurnInDate )
End If

' ----------------------------------------
' Exit
' ----------------------------------------
WSCript.Quit(0)




' ========================================
' GetModifiedDate()
'  Get LastModifiedDate from Update.cmd
' ========================================
Function GetModifiedDate(filespec)
  Dim fso, f, strTmpDate
  Set fso = CreateObject("Scripting.FileSystemObject")

  Set f = fso.GetFile(filespec)

  ' 1/2/2008... 0 will not be added
  strTmpDate = FormatDateTime(f.DateLastModified, 2)
' Wscript.Echo "[" & strTmpDate &"]"

  If InStr(1, strTmpDate, "/") <> 3 Then
    ' "Month" is 1 digit. Need to add "0" at the top of the string
    strTmpDate = "0" & strTmpDate
  End If

  If InStr(4, strTmpDate, "/") <> 6 Then
    ' "Day" is 1 digit. Need to add "0" before the "Day"
    strTmpDate = Mid( strTmpDate, 1, 3) & "0" & Mid( strTmpDate, 4)
  End If

  If Len( strTmpDate ) <> 10 Then
    WScript.Echo "Wrong date is detected... [" & strTmpDate & "]"
    strTmpDate = ""
  End If

  strTmpDate = Replace( strTmpDate, "/", "-")

  GetModifiedDate = strTmpDate 
End Function


' ========================================
' GetBurnInDate()
'  Get BurnInDate from \Windows\CSUP.txt
' ========================================
Function GetBurnInDate()
  Dim fso, theFile, retstring, strBurnInDate, f
  Set fso = CreateObject("Scripting.FileSystemObject")

  Set theFile = fso.OpenTextFile(OutPutFile, ForReading, False)

  strOrgBurnInDate = ""

  ' Get Burn-In-Date
  Do While theFile.AtEndOfStream <> True
    retstring = theFile.ReadLine
    If InStr( 1, retstring, "-") > 1 Then
      ' Found out burn-in-date
      strOrgBurnInDate = retstring
      Exit Do
    End If
  Loop
  theFile.Close
End Function


' ========================================
' WriteBurnInDate()
'  Write BurnInDate to \Windows\CSUP.txt
' ========================================
Sub WriteBurnInDate(strBurnInDate)
  Dim fso, f
  Set fso = CreateObject("Scripting.FileSystemObject")
  ' output Burn-In-Date
  If strBurnInDate <> "" Then
    Set f = fso.OpenTextFile( OutPutFile, ForWriting, True)
    f.WriteLine strBurnInDate
  End If
End Sub
