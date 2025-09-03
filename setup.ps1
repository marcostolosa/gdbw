# Copies required debugger dll's from Windows SDK install directory.
$ScriptPath = split-path -parent $MyInvocation.MyCommand.Definition

$DebugToolsDir = "${env:ProgramFiles(x86)}\Windows Kits\10\Debuggers\x64"
if (!(Test-Path -Path $DebugToolsDir)) {
    Write-Output "Failed to locate Windows debugging tools installation ($DebugToolsDir)"
    Write-Output "See here for more information: https://github.com/iilegacyyii/gdbw/wiki/Guide:-Installing-gdbw#guide-installing-gdbw"
    return
}

Write-Output "[-] Copying required dlls.."

# dbgcore.dll
if (Test-Path -Path "$DebugToolsDir\dbgcore.dll") {
    Copy-Item "$DebugToolsDir\dbgcore.dll" "$ScriptPath\dbgcore.dll"
} else {
    Write-Output "Failed to locate dbgcore.dll ($DebugToolsDir\dbgcore.dll)"
    return
}

# dbgeng.dll
if (Test-Path -Path "$DebugToolsDir\dbgeng.dll") {
    Copy-Item "$DebugToolsDir\dbgeng.dll" "$ScriptPath\dbgeng.dll"
} else {
    Write-Output "Failed to locate dbgeng.dll ($DebugToolsDir\dbgeng.dll)"
    return
}

# dbghelp.dll
if (Test-Path -Path "$DebugToolsDir\dbghelp.dll") {
    Copy-Item "$DebugToolsDir\dbghelp.dll" "$ScriptPath\dbghelp.dll"
} else {
    Write-Output "Failed to locate dbghelp.dll ($DebugToolsDir\dbghelp.dll)"
    return
}

# symsrv.dll
if (Test-Path -Path "$DebugToolsDir\symsrv.dll") {
    Copy-Item "$DebugToolsDir\symsrv.dll" "$ScriptPath\symsrv.dll"
} else {
    Write-Output "Failed to locate symsrv.dll ($DebugToolsDir\symsrv.dll)"
    return
}

Write-Output "[+] Done!"