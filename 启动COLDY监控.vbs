' Launch the bundled COLDY monitor without a console window.
' The script finds the first .exe in the same folder, so it does not
' depend on the Chinese file name or on the file encoding.
Set fso = CreateObject("Scripting.FileSystemObject")
Set sh = CreateObject("WScript.Shell")

base = fso.GetParentFolderName(WScript.ScriptFullName)
exePath = ""

For Each f In fso.GetFolder(base).Files
    If LCase(fso.GetExtensionName(f.Name)) = "exe" Then
        exePath = f.Path
        Exit For
    End If
Next

If exePath = "" Then
    MsgBox "Cannot find the COLDY monitor executable in this folder.", 16, "Launch failed"
    WScript.Quit 1
End If

sh.CurrentDirectory = base
sh.Run """" & exePath & """", 0, False
