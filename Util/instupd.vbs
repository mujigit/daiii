On Error Resume Next
Dim objArgs, fso, objShell
Dim InstallBom,InstallFile,InstallFolder, LogFile, CVAFile, DelivName, VersionStr, RevisionStr, PassStr, DelivPN, DelivSize, DriveFreeSize, InstallSize, RtnCode, InstStage, FccResult, sLocale
Set objArgs = WScript.Arguments
Set fso = CreateObject("Scripting.FileSystemObject")
InstallFile = Wscript.Arguments(0)
InstallBom = "C:\System.sav\Util\Install.bom"
if fso.FileExists(InstallFile) <> True then InstallFile = Replace(InstallFile, "C:", "I:", 1, -1, vbTextCompare)
if fso.FileExists(InstallFile) <> True then WScript.Quit(1)
InstallFolder = fso.GetParentFolderName(InstallFile)
LogFile = "C:\System.sav\Logs\BB\" & Replace(GetFileExtend(InstallFolder,"BTO"),".BTO",".LOG",1,-1,vbTextCompare)
sLocale = "en-us"
sLocale = getLocale()
WriteFile "Current Locale: " & sLocale
SetLocale("en-us")
WriteFile "[" & FormatDateTime(Time, 3) & "] " & "Install Folder: " & InstallFolder, LogFile
CVAFile = GetFileExtend(InstallFolder,"CVA")
WriteFile "[" & FormatDateTime(Time, 3) & "] " &"CVA File: " & InstallFolder & "\" & CVAFile, LogFile
DelivName = ReadIniValue(InstallFolder & "\" & CVAFile,"Software Title","US","")
VersionStr = Replace(ReadIniValue(InstallFolder & "\" & CVAFile,"General","Version",""),chr(9),"")
RevisionStr = Replace(ReadIniValue(InstallFolder & "\" & CVAFile,"General","Revision",""),chr(9),"")
PassStr = Replace(ReadIniValue(InstallFolder & "\" & CVAFile,"General","Pass",""),chr(9),"")
WriteFile "[" & FormatDateTime(Time, 3) & "] " & "Deliverable Name: " & DelivName & " [" & VersionStr & "," & RevisionStr & "," & PassStr & "]", LogFile
DelivPN = Replace(ReadIniValue(InstallFolder & "\" & CVAFile,"General","PN",""),chr(9),"")
WriteFile "[" & FormatDateTime(Time, 3) & "] " & "Deliverable PN: " & DelivPN, LogFile
DelivSize = GetFolderSize(InstallFolder)
WriteFile "[" & FormatDateTime(Time, 3) & "] " & "Deliverable Size: " & FormatNumber(DelivSize/1024,0) & " Kbytes", LogFile
DriveFreeSize = GetDriveFreeSize("C:\")
WriteFile "[" & FormatDateTime(Time, 3) & "] " & "Free Size: " & FormatNumber(DriveFreeSize/1024,0) & " Kbytes", LogFile
InstallSize = GetDriveUsedSize("C:\")
WriteFile "[" & FormatDateTime(Time, 3) & "] " & "System Used Size: " & FormatNumber(InstallSize/1024,0) & " Kbytes", LogFile

if fso.FileExists(InstallFolder & "\src\sysid.txt") AND fso.FileExists("C:\HP\BIN\RStone.INI") then
    Dim SysIdSupp : SysIdSupp = Trimend(ReadAllTextFile(InstallFolder & "\src\sysid.txt"),vbCrLf)
    Dim SysId : SysId = ReadIniValue("C:\HP\BIN\RStone.INI","BIOS Strings","SystemID","")
    if InStr(1,SysIdSupp,SysId,vbTextCompare) = 0 then
        fso.DeleteFile(InstallFolder & "\" & CVAFile)
        fso.DeleteFile(InstallFolder & "\FAILURE.FLG")
        WriteFile "[" & FormatDateTime(Time, 3) & "] " & "System Id Support: No (" & SysIdSupp & ")", LogFile
        if fso.FileExists(InstallFolder & "\" & CVAFile) <> True AND fso.FileExists(InstallFolder & "\FAILURE.FLG") <> True then
            WriteFile "[" & FormatDateTime(Time, 3) & "] " & "RESULT=PASSED", LogFile
        end if
        SetLocale(sLocale)
        WScript.Quit(0)
    end if
    WriteFile "[" & FormatDateTime(Time, 3) & "] " & "System Id Support: Yes (" & SysIdSupp & ")", LogFile
end if

FccResult = "FAILED"
Set objShell = WScript.CreateObject("WScript.shell")
objShell.CurrentDirectory = InstallFolder
WriteFile "[" & FormatDateTime(Time, 3) & "] " & "Run install command: " & InstallFile, LogFile
RtnCode = objShell.Run(InstallFile,CONST_HIDE_WINDOW,TRUE)
WriteFile "[" & FormatDateTime(Time, 3) & "] " & "Return code: " & RtnCode, LogFile
objShell.CurrentDirectory = "C:\SWSetup" '[2012/2/17] Watson: need to set folder back else folder delete will fail
Set objShell = Nothing
InstallSize = GetDriveUsedSize("C:\") - InstallSize
WriteFile "[" & FormatDateTime(Time, 3) & "] " & "Size Extend: " & FormatNumber(InstallSize/1024,0) & " Kbytes", LogFile
if fso.FileExists(InstallFolder & "\FAILURE.FLG") <> True then FccResult = "PASSED"

'[2012/7/9] Watson: Implement metro.xml move to c:\swsetup\metro\deliverable folder
if fso.FileExists(InstallFolder & "\src\Metro.xml") AND FccResult = "PASSED" then
    WriteFile "[" & FormatDateTime(Time, 3) & "] " & "Metro Deliverable: Yes", LogFile
    Dim MetroFolder : MetroFolder = "C:\SWSetup\Metro\" & DelivPN
    if CreateFolder(MetroFolder) <> True then
        WriteFile "[" & FormatDateTime(Time, 3) & "] " & "Metro folder create failed: " & MetroFolder, LogFile
    else
        fso.CopyFile InstallFolder & "\src\Metro.xml", MetroFolder & "\Metro.xml", True
    end if
else
    WriteFile "[" & FormatDateTime(Time, 3) & "] " & "Metro Deliverable: No", LogFile
end if

if fso.FileExists("C:\System.sav\Util\Slim.LST") AND FccResult = "PASSED" then
    Dim bSlim : bSlim = false
    for each item in Split(ReadIniSection("C:\System.sav\Util\Slim.LST", "Slim for Installed", ""), vbCrLf)
        if StrComp(DelivName,Trim(item),vbTextCompare) = 0 OR StrComp("*** All Deliverables ***",Trim(item),vbTextCompare) = 0 then
            bSlim = true
            fso.DeleteFolder InstallFolder, True
            if fso.FolderExists(InstallFolder) then 
                WriteFile "[" & FormatDateTime(Time, 3) & "] " & "Slim Deliverable: Failed", LogFile
                WriteFile InstallFolder, "C:\System.sav\Util\TDC\MCPP\DELETE.LST" '[2012/2/17] Watson: If folder delete failed, add folder path to DELETE.LST
            else
                WriteFile "[" & FormatDateTime(Time, 3) & "] " & "Slim Deliverable: for Installed", LogFile
            end if
            exit for
        end if
    next
    for each item in Split(ReadIniSection("C:\System.sav\Util\Slim.LST", "Slim for PostLast", ""), vbCrLf)
        if StrComp(DelivName,Trim(item),vbTextCompare) = 0 then
            bSlim = true
            WriteFile InstallFolder, "C:\System.sav\Util\TDC\MCPP\DELETE.LST" '[2012/2/29] Watson: implement to delete folder at PostLast stage to avoid deliverable folder had be removed at 1st install.
            WriteFile "[" & FormatDateTime(Time, 3) & "] " & "Slim Deliverable: for PostLast", LogFile
            exit for
        end if
    next
    if bSlim = false then WriteFile "[" & FormatDateTime(Time, 3) & "] " & "Slim Deliverable: No", LogFile
end if
WriteFile "[" & FormatDateTime(Time, 3) & "] " & "RESULT=" & FccResult, LogFile
if fso.FileExists(InstallFolder & "\FAILURE.FLG") then
    WriteFile VbCrLf & "[" & InstallFolder & "\FAILURE.FLG]", LogFile
    WriteFile ReadAllTextFile(InstallFolder & "\FAILURE.FLG"), LogFile
end if

if fso.FileExists("C:\HP\BIN\RStoneFupdate.INI") then 
    InstStage="PASS2"
elseif fso.FileExists("C:\HP\BIN\RStonePre.INI") then
    InstStage="PASS1"
else
    InstStage="UnKnow"
end if

bWrite = WriteIniSection("C:\System.sav\Util\install.bom", "Deliverable List", DelivName & " [" & VersionStr & "," & RevisionStr & "," & PassStr & "]" & ", " & DelivSize & ", " & InstallSize & ", " & DriveFreeSize & ", " & InstStage, "true")
SetLocale(sLocale)
WScript.Quit(0)

Function ReadAllTextFile(filename)
    Const ForReading = 1, ForWriting = 2
    Dim fso, objfile
    Set fso = CreateObject("Scripting.FileSystemObject")
    Set objfile = fso.OpenTextFile(filename, ForReading)

    If objfile.AtEndOfStream Then
        ReadAllTextFile = ""
    Else
        ReadAllTextFile = objfile.ReadAll
    End If
    objfile.Close
    set objfile = Nothing
End Function

Function FindString(findstr, filename)
    Const ForReading = 1, ForWriting = 2, ForAppending = 8
    Dim bFound : bFound = False
    Dim fso : Set fso = CreateObject("Scripting.FileSystemObject")
    Dim objfile : Set objfile = fso.OpenTextFile(filename, ForReading)
    Do Until objFile.AtEndOfStream
        strSearchString = objFile.ReadLine
        if StrComp(strSearchString, findstr, vbTextCompare) = 0 then
            bFound = True
            Exit Do
        end if
    Loop
    objfile.Close
    set objfile = Nothing
    FindString = bFound
End Function

Function GetFileExtend(srcfolder, extendstr)
   Dim fso, folder, file, fc
   Set fso = CreateObject("Scripting.FileSystemObject")
   Set folder = fso.GetFolder(srcfolder)
   Set fc = folder.Files
   For Each file in fc
      'if InStr(Len(file.name)-3,file.name, extendstr, vbTextCompare) <> 0 then
      if StrComp(fso.GetExtensionName(file.name), extendstr, vbTextCompare) = 0 then
         GetFileExtend = file.name
      end if
   Next
   Set folder = Nothing
End Function

Function CreateFolder(path)
    Dim fso : Set fso = CreateObject("Scripting.FileSystemObject")
    Dim ParentFolder : ParentFolder = fso.GetParentFolderName(path)
    if fso.FolderExists(ParentFolder) <> True AND Len(ParentFolder) <> 0 then CreateFolder(ParentFolder)
    if fso.FolderExists(path) <> True then fso.CreateFolder(path)
    CreateFolder = fso.FolderExists(path)
End Function

Function ReadIniValue(inifile,section,key,default)
   Const ForReading = 1, ForWriting = 2, ForAppending = 8
   Const TristateUseDefault = -2, TristateTrue = -1, TristateFalse = 0
   Dim fso, objFile, strText, strSection, strValue, PosSection, PosEndSection, PosValue, PosEndValue
   Set fso = CreateObject("Scripting.FileSystemObject")
   Set objFile = fso.OpenTextFile(inifile, ForReading, False, TristateUseDefault)
   strText = objFile.ReadAll
   objFile.Close
   set objFile = Nothing
   
   strValue = default
   'Find section
   PosSection = InStr(1, strText, "[" & section & "]", vbBinaryCompare)
   If PosSection>0 Then
      'Section exists. Find end of section
      PosEndSection = InStr(PosSection, strText, vbCrLf & "[")
      '?Is this last section?
      If PosEndSection = 0 Then PosEndSection = Len(strText)+1
      'Separate section contents
      strSection = Mid(strText, PosSection, PosEndSection - PosSection)
      strSection = split(strSection, vbCrLf)
      key = key & "="
      For Each Line In strSection
         If StrComp(Left(Line, Len(key)), key, vbTextCompare) = 0 Then
            strValue = Mid(Line, Len(key)+1)
         End If
      Next
   End If
   ReadIniValue = strValue
End Function


Function ReadIniSection(inifile,section,default)
   Const ForReading = 1, ForWriting = 2, ForAppending = 8
   Const TristateUseDefault = -2, TristateTrue = -1, TristateFalse = 0
   Dim fso, objFile, strText, strSection, PosSection, PosEndSection
   Set fso = CreateObject("Scripting.FileSystemObject")
   Set objFile = fso.OpenTextFile(inifile, ForReading, False, TristateUseDefault)
   strText = objFile.ReadAll
   objFile.Close
   set objFile = Nothing
   
   strSection = default
   'Find section
   PosSection = InStr(1, strText, "[" & section & "]", vbBinaryCompare)
   If PosSection>0 Then
      'Section exists. Find end of section
      PosEndSection = InStr(PosSection, strText, vbCrLf & "[")
      '?Is this last section?
      If PosEndSection = 0 Then PosEndSection = Len(strText)+1
      'Separate section contents
      strSection = Mid(strText, PosSection, PosEndSection - PosSection)
   End If
   ReadIniSection = strSection
End Function


Function WriteIniSection(inifile,section,content,append)
   Const ForReading = 1, ForWriting = 2, ForAppending = 8
   Dim fso, objFile, strText, strSection, strAfter, PosSection, PosEndSection
   Set fso = CreateObject("Scripting.FileSystemObject")
   Set objFile = fso.OpenTextFile(inifile, ForReading, True)
   If objFile.AtEndOfStream Then
        strText = ""
   Else
        strText = objFile.ReadAll
   End If
   objFile.Close
   set objFile = Nothing
   
   PosSection = InStr(1, strText, "[" & section & "]", vbTextCompare)
   If PosSection>0 Then
      'Section exists. Find end of section
      PosEndSection = InStr(PosSection, strText, vbCrLf & "[")
      '?Is this last section?
      If PosEndSection = 0 Then PosEndSection = Len(strText)+1
      do while Mid(strText,PosEndSection-2,2) = vbCrLf
         PosEndSection=PosEndSection-2
      Loop
      strSection = Mid(strText, PosSection, PosEndSection - PosSection)
      If StrComp(append, "true", vbTextCompare) = 0 Then
         If Right(strSection,2) <> vbCrLf Then strSection = strSection & vbCrLf
         strSection = strSection & content
      Else
         strSection = Left(strSection, Len(section)+4) & content & Right(strSection,Len(strSection)-Len(section)-2)
      End If
      strAfter = Left(strText, PosSection-1) & strSection & Right(strText,Len(strText)-(PosEndSection-1))
      Set objFile = fso.OpenTextFile(inifile, ForWriting)
      objFile.Write strAfter
      objFile.Close
      set objFile = Nothing
   Else
      strSection = "[" & section & "]" & vbCrLf & content
      If Right(strText,2)=vbCrLf or strText="" Then 
         strAfter = strText & strSection
      Else
         strAfter = strText & vbCrLf & strSection
      End If
      Set objFile = fso.OpenTextFile(inifile, ForWriting, True)
      objFile.Write strAfter
      objFile.Close
      set objFile = Nothing
   End If

   WriteIniSection = 0
End Function


Function WriteFile(strOut,file)
    Const ForReading = 1, ForWriting = 2, ForAppending = 8
    Dim objFs : Set objFs = CreateObject("Scripting.FileSystemObject")
    Dim objFile : Set objFile = objFs.OpenTextFile(file, ForAppending, True)
    If IsObject(objFile) <> True Then Exit Function
    objFile.Write strOut & VbCrLf
    objFile.Close
    Set objFile = Nothing
End Function


Function Trimend(word, trimchar)
    Dim newword : newword = word
    if Right(newword,1) = trimchar then
        newword = Left(newword, Len(word) - Len(trimchar))
        newword = Trimend(newword, trimchar)
    end if 
    Trimend = newword
End Function


Function GetFolderSize(path)
   Dim fso, folder
   On Error Resume Next
   Set fso = CreateObject("Scripting.FileSystemObject")
   Set folder = fso.GetFolder(path)
   GetFolderSize = folder.size
   Set folder = Nothing
End Function


Function GetDriveUsedSize(drvpath)
   Dim fso, d
   On Error Resume Next
   Set fso = CreateObject("Scripting.FileSystemObject")
   Set d = fso.GetDrive(fso.GetDriveName(fso.GetAbsolutePathName(drvpath)))
   GetDriveUsedSize = d.TotalSize - d.AvailableSpace
End Function


Function GetDriveFreeSize(drvpath)
   Dim fso, d
   On Error Resume Next
   Set fso = CreateObject("Scripting.FileSystemObject")
   Set d = fso.GetDrive(fso.GetDriveName(fso.GetAbsolutePathName(drvpath)))
   GetDriveFreeSize = d.FreeSpace
End Function