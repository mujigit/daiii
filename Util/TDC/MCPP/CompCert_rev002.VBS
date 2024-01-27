REM REV002

Option Explicit
Dim objArgs : Set objArgs = Wscript.Arguments
If objArgs.Count <> 3 Then
   Help()
   WSCript.Quit 1
End If

Const ForReading = 1, ForWriting = 2, ForAppending = 8
Const TristateUseDefault = -2, TristateTrue = -1, TristateFalse = 0
Dim fso : Set fso = CreateObject("Scripting.FileSystemObject")

Dim TrgtOS_FPath : TrgtOS_FPath = objArgs(0)
Dim PureOS_FPath : PureOS_FPath = objArgs(1)
Dim Report_FPath : Report_FPath = objArgs(2)

Dim Report_CnvrtDerPs1_FPath : Report_CnvrtDerPs1_FPath = Report_FPath & ".PS1"

WScript.Echo "Target machine certificate file path="&TrgtOS_FPath
WScript.Echo "Pure OS certification file path=     "&PureOS_FPath
WScript.Echo "Report file path=                    "&Report_FPath

' ReadAll pure OS
Dim strPureOS
Dim objPureOS : Set objPureOS = fso.OpenTextFile(PureOS_FPath, ForReading)
If objPureOS.AtEndOfStream Then
	strPureOS=""
Else
	strPureOS = objPureOS.ReadAll
End If
objPureOS.Close
set objPureOS = Nothing
REM LOGIT strPureOS

' ReadAll target machine
Dim strTrgtOS
Dim objTrgtFile : Set objTrgtFile = fso.OpenTextFile(TrgtOS_FPath, ForReading)
If objTrgtFile.AtEndOfStream Then
	strTrgtOS=""
Else
	strTrgtOS = objTrgtFile.ReadAll
End If
objTrgtFile.Close
set objTrgtFile = Nothing
REM LOGIT strTrgtOS

' Report stream
Dim objReport : Set objReport = fso.OpenTextFile(Report_FPath, ForWriting, True, TristateUseDefault)
objReport.Write "--- Root Certificate not in HP whitelist is as following: ---" & vbCrLf

Dim objDerPS1 : Set objDerPS1 = fso.OpenTextFile(Report_CnvrtDerPs1_FPath, ForWriting, True, TristateUseDefault)


Dim i : i = 1 
Dim certItem, sha1code, certName, issuer, friendlyName, CN, OU, O, T, intendedPurposes
For i=1 To 200
	certItem = ReadCert(strTrgtOS, i)
	REM LOGIT "["&certItem&"]"
	If Len(certItem) = 0 Then
		Wscript.Echo "No more certificate item"
		Exit For
	Else
		sha1code = ReadKeyInCertItem(certItem, "SHA1 Thumbprint")
		Wscript.Echo "sha1={" & sha1code & "}"
		If InStr(1, strPureOS, sha1code) <> 0 Then
			Wscript.Echo "Inbox certificate"
		Else
			Wscript.Echo "Not inbox certificate"

			friendlyName = convWideChar(fetchName(ReadKeyInCertItem(certItem, "Aux PropId 11 (0xb) ")))
			rem intendedPurposes = ReadKeyInCertItem(certItem, "EnhancedKeyUsage")
			intendedPurposes = "TBI"

			'CN: CommonName
			'OU: OrganizationalUnit
			'O: Organization
			'L: Locality
			'S: StateOrProvinceName
			'C: CountryName
			'T: Title
			issuer = ReadKeyInCertItem(certItem, "Issuer")
			Wscript.Echo "issuer={" & issuer & "}"
			CN = getLatestVersion(issuer, "(CN)")
			O = getLatestVersion(issuer, "(O)")
			OU = getLatestVersion(issuer, "(OU)")
			T = getLatestVersion(issuer, "(T)")
			objReport.Write "FriendlyName/CommonName/Org/OrgUnit/Title/IntendedPurposes/SHA1 = " & friendlyName & " / " & CN & " / " & O & " / " & OU & " / " & T & " / " & intendedPurposes & " / " & sha1code & vbCrLf
			objDerPS1.Write "Export-Certificate -Cert cert:""LocalMachine\Root\" & sha1code & """ -FilePath """ & sha1code &".CER"""&vbCrLf
		End If
	End If
	REM Exit For
Next

objReport.Close
set objReport = Nothing


objDerPS1.Close
set objDerPS1 = Nothing


WSCript.Quit 0



Function ReadCert(certFileContent,cerNum)
	Dim PosSection, PosSectionNextLine, PosEndSection
	ReadCert=""
	'Find cerNum
	PosSection = InStr(1, certFileContent, "==============Certificate # " & cerNum, vbBinaryCompare)
	If PosSection>0 Then
		PosSectionNextLine = InStr(PosSection, certFileContent, vbCrLf) + 2
		REM LOGIT "PosSectionNextLine="&PosSectionNextLine
		'Section exists. Find end of cerNum
		PosEndSection = InStr(PosSectionNextLine, certFileContent, vbCrLf & "==============")
		'Separate cerNum contents
		ReadCert = Mid(certFileContent, PosSectionNextLine, PosEndSection - PosSectionNextLine)
	End If
End Function

'SHA1 Thumbprint::
'      742C3192 E607E424 EB454954 2BE1BBC5 3E6174E2
Function ReadKeyInCertItem(certItemContent, key)
	Dim PosSection, PosSectionNextLine, PosEndSection
	ReadKeyInCertItem=""
	PosSection = InStr(1, certItemContent, key&"::", vbBinaryCompare)
	If PosSection>0 Then
		PosSectionNextLine = InStr(PosSection, certItemContent, vbCrLf) + 2
		LOGIT "PosSectionNextLine={" & PosSectionNextLine & "}"
		PosEndSection = InStr(PosSectionNextLine, certItemContent, "::")
		PosEndSection = InStrRev(certItemContent, vbCrLf, PosEndSection)
		ReadKeyInCertItem = Trim(Mid(certItemContent, PosSectionNextLine, PosEndSection - PosSectionNextLine))
	End If
End Function




'Issuer::
'  [0,0] 2.5.4.6 (C) ValueType: 4
'     55 53                                              'US'
'  [1,0] 2.5.4.10 (O) ValueType: 4
'     56 65 72 69 53 69 67 6E 2C 20 49 6E 63 2E          'VeriSign, Inc.'
'  [2,0] 2.5.4.11 (OU) ValueType: 4
'     43 6C 61 73 73 20 33 20 50 75 62 6C 69 63 20 50    'Class 3 Public P'
'     72 69 6D 61 72 79 20 43 65 72 74 69 66 69 63 61    'rimary Certifica'
'     74 69 6F 6E 20 41 75 74 68 6F 72 69 74 79          'tion Authority'
'Issuer::
'  [0,0] 2.5.4.6 (C) ValueType: 4
'     55 53                                              'US'
'  [1,0] 2.5.4.10 (O) ValueType: 4
'     53 79 6D 61 6E 74 65 63 20 43 6F 72 70 6F 72 61    'Symantec Corpora'
'     74 69 6F 6E                                        'tion'
'  [2,0] 2.5.4.3 (CN) ValueType: 4
'     53 79 6D 61 6E 74 65 63 20 45 6E 74 65 72 70 72    'Symantec Enterpr'
'     69 73 65 20 4D 6F 62 69 6C 65 20 52 6F 6F 74 20    'ise Mobile Root '
'     66 6F 72 20 4D 69 63 72 6F 73 6F 66 74             'for Microsoft'
'Issuer::
'  [0,0] 2.5.4.6 (C) ValueType: 4
'     54 57                                              'TW'
'  [1,0] 2.5.4.10 (O) ValueType: 13
'     54 00 41 00 49 00 57 00 41 00 4E 00 2D 00 43 00    'T.A.I.W.A.N.-.C.'
'     41 00                                              'A.'
'  [2,0] 2.5.4.11 (OU) ValueType: 13
'     52 00 6F 00 6F 00 74 00 20 00 43 00 41 00          'R.o.o.t. .C.A.'
'  [3,0] 2.5.4.3 (CN) ValueType: 13
'     54 00 57 00 43 00 41 00 20 00 52 00 6F 00 6F 00    'T.W.C.A. .R.o.o.'
'     74 00 20 00 43 00 65 00 72 00 74 00 69 00 66 00    't. .C.e.r.t.i.f.'
'     69 00 63 00 61 00 74 00 69 00 6F 00 6E 00 20 00    'i.c.a.t.i.o.n. .'
'     41 00 75 00 74 00 68 00 6F 00 72 00 69 00 74 00    'A.u.t.h.o.r.i.t.'
'     79 00                                              'y.'
Function getLatestVersion(certValueContent, key)
	LOGIT "Checking "&key
	getLatestVersion=""
	Dim PosSection, PosSectionNextLine, PosEndSection
	PosSection = InStrRev(certValueContent, key, -1, vbBinaryCompare)
	If PosSection>0 Then
		PosSectionNextLine = InStr(PosSection, certValueContent, vbCrLf) + 2
		PosEndSection = InStr(PosSectionNextLine, certValueContent, "[")
		If PosEndSection>0 Then
			getLatestVersion = Trim(Mid(certValueContent, PosSectionNextLine, PosEndSection - PosSectionNextLine))
		Else
			getLatestVersion = Trim(Right(certValueContent, Len(certValueContent) - PosSectionNextLine))
		End If
		LOGIT "getLatestVersion={"&getLatestVersion&"}"
		getLatestVersion = fetchName(Replace(getLatestVersion, vbCrLf, ""))
	End If
	Dim WideCh : WideCh = 0
	If InStr(1, certValueContent, "ValueType: 13", vbTextCompare) <>0 Then
		LOGIT "Convert from wide char string to T string" 
		getLatestVersion = convWideChar(getLatestVersion)
		LOGIT "getLatestVersion={"&getLatestVersion&"}"
	End If
End Function

'     54 00 57 00 43 00 41 00 20 00 52 00 6F 00 6F 00    'T.W.C.A. .R.o.o.'
'     74 00 20 00 43 00 65 00 72 00 74 00 69 00 66 00    't. .C.e.r.t.i.f.'
'     69 00 63 00 61 00 74 00 69 00 6F 00 6E 00 20 00    'i.c.a.t.i.o.n. .'
'     41 00 75 00 74 00 68 00 6F 00 72 00 69 00 74 00    'A.u.t.h.o.r.i.t.'
'     79 00                                              'y.'
Function fetchName(str)
	LOGIT "str={"&str&"}"
	If Len(str) < 1 Then 
		fetchName = ""
		Exit Function
	End If
	Dim PosSection, PosEndSection
	Dim buf : buf = ""
	PosSection = InStr(1, str, "'", vbBinaryCompare) + 1
	LOGIT "PosSection={"&PosSection&"}"
	If PosSection > 0 Then
		PosEndSection = InStr(PosSection+1, str, "'")
		LOGIT "PosEndSection={"&PosEndSection&"}"
		
		REM Cannot trim here!! Double word substring may start with space
		REM fetchName = Trim(Mid(str, PosSection, PosEndSection - PosSection))
		fetchName = Mid(str, PosSection, PosEndSection - PosSection)
		
		LOGIT "fetchName={"&fetchName&"}"
		buf = Trim(Right(str, Len(str)-PosEndSection))
		LOGIT "buf={"&buf&"}"
		If Len(buf) > 0 Then
			fetchName = fetchName & fetchName(buf)
		End If
	End If
End Function

'Aux PropId 11 (0xb) ::
'     54 00 68 00 65 00 20 00 55 00 53 00 45 00 52 00    'T.h.e. .U.S.E.R.'
'     54 00 72 00 75 00 73 00 74 00 20 00 4E 00 65 00    'T.r.u.s.t. .N.e.'
'     74 00 77 00 6F 00 72 00 6B 00 22 21 00 00          't.w.o.r.k."!..'   There is second word not 00, the 22,21 is TM mark
Function convWideChar(str)
	REM Double Word, length is 2X
	If Len(str) >= 2 Then
		Dim buf
		convWideChar = Left(str, 1)
		if StrComp(Mid(str, 2, 1),".")<>0 Then convWideChar = ""
		buf = Right(str, Len(str)-2)
		LOGIT "convWideChar/buf=["&convWideChar&"/"&buf&"]"
		convWideChar = convWideChar & convWideChar(buf)
	Else
		convWideChar = ""
	End If
End Function

Sub LOGIT(msg)
	WScript.Echo msg
End Sub

Sub Help()
  WScript.Echo "Syntax:" & chr(13) & chr(13) & "CompCert.VBS [target OS cert detail file] [pure OS Cert detail file] [report path]"
  WSCript.Quit(1)
End Sub
