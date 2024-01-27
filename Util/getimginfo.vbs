'On Error Resume Next
CONST CONST_WIN7SP1_VERSION = "6.1.7601"
CONST CONST_WIN8_VERSION = "6.2.9200"
CONST CONST_WIN81_VERSION = "6.3.9200"
CONST CONST_WIN81U_VERSION = "6.3.9600"
CONST CONST_WIN10_VERSION = "6.4"

Dim fso
Dim CurrentFolder,IdPath,WimInfoPath,FlagPath,RStonePath,DmiPath
Dim FeatureByte,SysId,SysIdList,OSSku,OSEdition,ImgIDFlag,OA21Flag,OA30Flag,ImgSku,ImgSkuNum,SysLock,ChassisFB

Set fso = CreateObject("Scripting.FileSystemObject")
CurrentFolder = fso.GetParentFolderName(WScript.ScriptFullName)

if fso.FileExists(CurrentFolder & "\RStone.ini") then RStonePath = CurrentFolder & "\RStone.ini" else RStonePath = "C:\HP\BIN\RStone.ini"
if fso.FileExists(CurrentFolder & "\sysid.txt") then IdPath = CurrentFolder & "\sysid.txt" else IdPath = "C:\System.sav\util\sysid.txt"
if fso.FolderExists(CurrentFolder & "\Flags") then FlagPath = CurrentFolder & "\Flags" else FlagPath = "C:\System.sav\Flags"
if fso.FileExists(CurrentFolder & "\wiminfo.txt") then WimInfoPath = CurrentFolder & "\wiminfo.txt"
if fso.FileExists(CurrentFolder & "\DMI.ini") then DmiPath = CurrentFolder & "\DMI.ini" else DmiPath = FindDmiIniPath("C:\SYSTEM.SAV\TWEAKS\DMI")

if fso.FileExists(RStonePath) <> True then
    WScript.Echo "Could not found RStone.ini file."
	WScript.Echo "Fail=1"
    WScript.Quit (1)
end if
if fso.FileExists(IdPath) <> True then
    WScript.Echo "Could not found sysid.txt file."
	WScript.Echo "Fail=1"
    WScript.Quit (1)
end if
if fso.FolderExists(FlagPath) <> True AND fso.FileExists(WimInfoPath) <> True then
    WScript.Echo "Could not found the flags folder or WinInfo.txt file."
	WScript.Echo "Fail=1"
    WScript.Quit (1)
end if
FeatureByte = ReadIniValue(RStonePath,"BIOS Strings","FeatureByte","0")
SysId = ReadIniValue(RStonePath,"BIOS Strings","SystemID","0")
OSSku = ReadIniValue(RStonePath,"BIOS Strings","OSSkuFlag","0")
OSEdition = ReadIniValue(RStonePath,"BIOS Strings","WinConfigurationFlag","0")
ImgIDFlag = ReadIniValue(RStonePath,"BIOS Strings","ImageIDFlag","0")
OA21Flag = ReadIniValue(RStonePath,"BIOS Strings","OEMActivation21","0")
OA30Flag = ReadIniValue(RStonePath,"BIOS Strings","OEMActivation30","0")
SysIdList = Trimend(ReadAllTextFile(IdPath),vbCrLf)

ChassisFB = "NA"
If InStr(1,SysIdList,"#",vbTextCompare) <> 0 then
	REM CDT
	ChassisFB = ParseFeatureByte(FeatureByte,DmiPath,"C_")
End If

REM WScript.Echo "FeatureByte=""" & FeatureByte & """"
REM WScript.Echo "OSSku=""" & OSSku & """"
REM WScript.Echo "OSEdition=""" & OSEdition & """"
REM WScript.Echo "ImgIDFlag=""" & ImgIDFlag & """"
REM WScript.Echo "OA21Flag=""" & OA21Flag & """"
REM WScript.Echo "OA30Flag=""" & OA30Flag & """"
REM WScript.Echo "DmiPath=""" & DmiPath & """"
REM WScript.Echo "ChassisFB=""" & ChassisFB & """"


ImgSku = "Unknow"
if FeatureByte = "0" AND OSSku = 2 AND ImgIDFlag = 0 AND OA21Flag = 0 AND OA30Flag = 0 then
    ImgSku = "Win7_STD"
	ImgSkuNum = 2
elseif FeatureByte <> "0" AND OSSku = 2 AND ImgIDFlag = 0 AND OA21Flag = 1 AND OA30Flag = 0 then
	ImgSku = "Win7_STD"
	ImgSkuNum = 2
elseif FeatureByte = "0" AND OSSku = 4 AND ImgIDFlag = 4 AND OA21Flag = 0 AND OA30Flag = 0 AND OSEdition = 3 then
	ImgSku = "Win7_DG"
	ImgSkuNum = 4
elseif FeatureByte <> "0" AND OSSku = 2 AND ImgIDFlag = 0 AND OA21Flag = 1 AND OA30Flag = 1 AND OSEdition = 3 then
	ImgSku = "Win7_DG"
	ImgSkuNum = 2
elseif FeatureByte <> "0" AND OSSku = 2 AND ImgIDFlag = 4 AND OA21Flag = 1 AND OA30Flag = 1 AND OSEdition = 3 then
	ImgSku = "Win7_DG"
	ImgSkuNum = 2
elseif FeatureByte = "0" AND OSSku = 4 AND ImgIDFlag = 0 AND OA21Flag = 0 AND OA30Flag = 0 then
	ImgSku = "Win8x"
	ImgSkuNum = 4
elseif FeatureByte <> "0" AND OSSku = 4 AND ImgIDFlag = 0 AND OA21Flag = 0 AND OA30Flag = 1 then
	ImgSku = "Win8x"
	ImgSkuNum = 4
elseif FeatureByte = "0" AND OSSku = 5 AND ImgIDFlag = 0 AND OA21Flag = 0 AND OA30Flag = 0 then
	ImgSku = "Win10"
	ImgSkuNum = 5
elseif FeatureByte <> "0" AND OSSku = 5 AND ImgIDFlag = 0 AND OA21Flag = 0 AND OA30Flag = 1 then
	ImgSku = "Win10"
	ImgSkuNum = 5
elseif FeatureByte <> "0" AND OSSku = 5 AND ImgIDFlag = 0 AND OA21Flag = 1 AND OA30Flag = 1 AND OSEdition = 3 then
	ImgSku = "Win10_DG"
	ImgSkuNum = 5
end if

SysLock = "FALSE"
Dim OSSupport : OSSupport = 0
Select Case ImgSku
Case "Win7_STD"
    if fso.FileExists(FlagPath & "\Win7sp1.flg") = True Then OSSupport = 1
    if fso.FileExists(WimInfoPath) = True Then
        if FindString("Version : " & CONST_WIN7SP1_VERSION, WimInfoPath) = True Then OSSupport = 1
    end if
Case "Win7_DG"
    if fso.FileExists(FlagPath & "\Win7sp1.flg") = True Then OSSupport = 1
    if fso.FileExists(FlagPath & "\Win8sp0.flg") = True Then OSSupport = 1
    if fso.FileExists(FlagPath & "\w81u.flg") = True Then OSSupport = 1
	if fso.FileExists(FlagPath & "\w10.flg") = True Then OSSupport = 1
    if fso.FileExists(WimInfoPath) = True Then
        if FindString("Version : " & CONST_WIN7SP1_VERSION, WimInfoPath) = True Then OSSupport = 1
        if FindString("Version : " & CONST_WIN8_VERSION, WimInfoPath) = True Then OSSupport = 1
        if FindString("Version : " & CONST_WIN81_VERSION, WimInfoPath) = True Then OSSupport = 1
		if FindString("Version : " & CONST_WIN81U_VERSION, WimInfoPath) = True Then OSSupport = 1
		if FindString("Version : " & CONST_WIN10_VERSION, WimInfoPath) = True Then OSSupport = 1
    end if
Case "Win8x"
    if fso.FileExists(FlagPath & "\Win8sp0.flg") = True Then OSSupport = 1
    if fso.FileExists(FlagPath & "\w81u.flg") = True Then OSSupport = 1
    if fso.FileExists(WimInfoPath) = True Then
        if FindString("Version : " & CONST_WIN8_VERSION, WimInfoPath) = True Then OSSupport = 1
        if FindString("Version : " & CONST_WIN81_VERSION, WimInfoPath) = True Then OSSupport = 1
		if FindString("Version : " & CONST_WIN81U_VERSION, WimInfoPath) = True Then OSSupport = 1
    end if
Case "Win10"
    if fso.FileExists(FlagPath & "\W10.flg") = True Then OSSupport = 1
    if fso.FileExists(WimInfoPath) = True Then
        if FindString("Version : " & CONST_WIN10_VERSION, WimInfoPath) = True Then OSSupport = 1
    end if
Case "Win10_DG"
    if fso.FileExists(FlagPath & "\W10.flg") = True Then OSSupport = 1
    if fso.FileExists(WimInfoPath) = True Then
        if FindString("Version : " & CONST_WIN10_VERSION, WimInfoPath) = True Then OSSupport = 1
    end if
End Select

If InStr(1,SysIdList,"#",vbTextCompare) <> 0 then
	REM (CDT) 81B7#C_Fan27,81B9#C_Fan23,81B8#C_Fan23,81B7#C_Fan23,81B7#C_FanX23,81BA#C_PRO195,81BB#C_PRO195,81BC#C_PRO195,81BA#C_PRO215,81BB#C_PRO215,81BC#C_PRO215,81BA#C_PRO238,81BB#C_PRO238,81BC#C_PRO238
	REM WScript.Echo "CDT Rule"
	if InStr(1,SysIdList,SysId&"#"&ChassisFB,vbTextCompare) <> 0 AND OSSupport = 1 then SysLock = "TRUE"
Else
	REM (CNB) 810A,810B,810C,810D,79B1,79B2,79B3
	REM WScript.Echo "CNB Rule"
	if InStr(1,SysIdList,SysId,vbTextCompare) <> 0 AND OSSupport = 1 then SysLock = "TRUE"
End If


WScript.Echo "SystemLock=" & SysLock
WScript.Echo "ImageSku=" & ImgSkuNum
WScript.Echo "UnitSku=" & OSSku
WScript.Echo "SystemId=" & SysId
WScript.Echo "SystemIdList=" & SysIdList
WScript.Echo "ChassisFB=" & ChassisFB
WScript.Echo "OSSupport=" & OSSupport
WScript.Quit (0)

Function Trimend(word, trimchar)
    Dim newword : newword = word
    if Right(newword,1) = trimchar then
        newword = Left(newword, Len(word) - Len(trimchar))
        newword = Trimend(newword, trimchar)
    end if 
    Trimend = newword
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

Function ParseFeatureByte(FB, dmiIniPath, prefix)
	If StrComp(Left(FB,1),".") = 0 Then
		ParseFeatureByte = "NA"
		Exit Function
	End If
	'Get name in DMI.INI
	Dim othersFB : othersFB = Right(FB, Len(FB)-2)
	Dim optionValue : OptionValue = ReadIniValue_CaseSensitive(dmiIniPath, "Options", Left(FB, 2), "0")
	REM WScript.Echo Left(FB, 2) & "=" & OptionValue
	If StrComp(Left(OptionValue, 2), prefix, vbTextCompare) = 0 Then
		REM WScript.Echo "Chassis FB found (" & Left(FB, 2) & ")=" & OptionValue
		ParseFeatureByte = OptionValue
	Else
		ParseFeatureByte = ParseFeatureByte(othersFB, dmiIniPath, prefix)
	End If
	
End Function

Function FindDmiIniPath(dmiRootFldrPath)
	Dim objDmiSubFldr
	Dim latestDate : latestDate = 0
	For Each objDmiSubFldr in fso.GetFolder(dmiRootFldrPath).SubFolders
		REM WScript.Echo "Find [" & objDmiSubFldr.Name & "] in " & dmiRootFldrPath
		Dim possibleDmiIniPath : possibleDmiIniPath = objDmiSubFldr.Path & "\DMI.INI"
		Dim currentFldrNameDate : currentFldrNameDate = CLng(objDmiSubFldr.Name)
		If fso.FileExists(possibleDmiIniPath) AND currentFldrNameDate > latestDate Then
			FindDmiIniPath = possibleDmiIniPath
			latestDate = currentFldrNameDate
		End If
	Next
	REM WScript.Echo "FindDmiIniPath=" & FindDmiIniPath
End Function

Function Help()
    WScript.Echo vbCrLf & "HP CNB Image Information Collection, Version 1.00,A2" & vbCrLf & "Copyright (c) 2010 Hewlett-Packard - All Rights Reserved" & vbCrLf
    WScript.Echo "Syntax: CScript.exe /nologo getimginfo.vbs" & vbCrLf
    WScript.Echo "Ex: CScript.exe /nologo getimginfo.vbs"
    WSCript.Quit(1)
End Function

Function ReadIniValue_CaseSensitive(inifile,section,key,default)
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
         REM If StrComp(Left(Line, Len(key)), key, vbTextCompare) = 0 Then
         If StrComp(Left(Line, Len(key)), key, vbBinaryCompare) = 0 Then
            strValue = Mid(Line, Len(key)+1)
         End If
      Next
   End If
   ReadIniValue_CaseSensitive = strValue
End Function
