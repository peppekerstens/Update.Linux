<#
.Synopsis
    List all available package updates.
.Description
    Shows packages that can be upgraded on this system using Get-WindowsUpdate.
    Displays a formatted table with package name, current version, new version,
    and the source repository.
.Notes
    Free to use under GNU v3 Public License (https://choosealicense.com/licenses/gpl-3.0/)
    Author: Peppe Kerstens (NLD)
    Requires: Update.Linux module
#>

# Import the module (Linux only)
if ($IsLinux) {
    $modulePath = Join-Path $PSScriptRoot '..' 'Update.Linux' 'Update.Linux.psd1'
    Import-Module $modulePath -Force -ErrorAction Stop
}

$updates = Get-WindowsUpdate
if (-not $updates) {
    Write-Host "No upgradable packages found. System is up to date."
} else {
    $updates |
        Select-Object Title, CurrentVersion, Version, Repository, Architecture |
        Format-Table -AutoSize
    Write-Host "$($updates.Count) package(s) available for upgrade."
}
