<#
.Synopsis
    Show recent package installation history.
.Description
    Displays the last 20 package actions (install, upgrade, remove) from
    the dpkg log using Get-WUHistory. Sorted from newest to oldest.
.Notes
    Free to use under GNU v3 Public License (https://choosealicense.com/licenses/gpl-3.0/)
    Author: Peppe Kerstens (NLD)
    Requires: Update.Linux module
#>

if ($IsLinux) {
    $modulePath = Join-Path $PSScriptRoot '..' 'Update.Linux' 'Update.Linux.psd1'
    Import-Module $modulePath -Force -ErrorAction Stop
}

$history = Get-WUHistory -Last 20
if (-not $history) {
    Write-Host "No package history found in /var/log/dpkg.log."
} else {
    $history |
        Select-Object Date, Action, Title, Version, Result |
        Format-Table -AutoSize
}
