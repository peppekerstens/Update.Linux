<#
.Synopsis
    Show an update summary report.
.Description
    Produces a summary of available updates grouped by source repository,
    and shows the most recently installed/upgraded packages.
.Notes
    Free to use under GNU v3 Public License (https://choosealicense.com/licenses/gpl-3.0/)
    Author: Peppe Kerstens (NLD)
    Requires: Update.Linux module
#>

if ($IsLinux) {
    $modulePath = Join-Path $PSScriptRoot '..' 'Update.Linux' 'Update.Linux.psd1'
    Import-Module $modulePath -Force -ErrorAction Stop
}

Write-Host "=== Available Updates ==="
$updates = Get-LinuxUpdate
if ($updates) {
    $updates | Group-Object Repository | Sort-Object Count -Descending |
        Select-Object @{N='Repository';E={$_.Name}}, @{N='Packages';E={$_.Count}} |
        Format-Table -AutoSize
    Write-Host "Total: $($updates.Count) package(s) to upgrade."
} else {
    Write-Host "System is up to date."
}

Write-Host ""
Write-Host "=== Recent Package Actions (last 10) ==="
$history = Get-LinuxUpdateHistory -Last 10
if ($history) {
    $history | Select-Object Date, Action, Title, Version | Format-Table -AutoSize
} else {
    Write-Host "No history available."
}
