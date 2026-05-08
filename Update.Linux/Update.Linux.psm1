#Requires -Version 7.2

# Update.Linux.psm1
# Root module for Update.Linux.
# Dot-sources all function files.

# Linux-only guard — this module wraps Linux CLI tools (apt, dpkg) and must
# not be loaded on Windows. On Windows, use the PSWindowsUpdate module:
#   Install-Module PSWindowsUpdate
if (-not $IsLinux) {
    throw (
        "Update.Linux cannot be loaded on Windows. " +
        "On Windows, use the PSWindowsUpdate module: Install-Module PSWindowsUpdate`n" +
        "Update.Linux is a Linux-only peer module that wraps apt and dpkg."
    )
}

$functionPath = Join-Path $PSScriptRoot 'Functions'
$functionFiles = Get-ChildItem -Path $functionPath -Filter '*.ps1' -ErrorAction SilentlyContinue |
    Where-Object { $_.Name -notlike '*.Tests.ps1' }
foreach ($file in $functionFiles) {
    . $file.FullName
}

# PSWindowsUpdate / WU compatibility aliases
# These allow scripts written for PSWindowsUpdate to run unmodified on Linux.
Set-Alias -Name 'Get-WindowsUpdate'     -Value 'Get-LinuxUpdate'
Set-Alias -Name 'Install-WindowsUpdate' -Value 'Install-LinuxUpdate'
Set-Alias -Name 'Get-WUHistory'         -Value 'Get-LinuxUpdateHistory'
Set-Alias -Name 'Hide-WindowsUpdate'    -Value 'Hide-LinuxUpdate'
Set-Alias -Name 'Remove-WindowsUpdate'  -Value 'Remove-LinuxUpdate'
Set-Alias -Name 'Show-WindowsUpdate'    -Value 'Show-LinuxUpdate'
