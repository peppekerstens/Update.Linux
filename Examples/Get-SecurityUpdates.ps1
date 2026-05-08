<#
.Synopsis
    Show security-related package updates.
.Description
    Filters Get-WindowsUpdate results to show only packages from security
    repositories (repositories containing 'security' in the name).
.Notes
    Free to use under GNU v3 Public License (https://choosealicense.com/licenses/gpl-3.0/)
    Author: Peppe Kerstens (NLD)
    Requires: Update.Linux module
#>

if ($IsLinux) {
    $modulePath = Join-Path $PSScriptRoot '..' 'Update.Linux' 'Update.Linux.psd1'
    Import-Module $modulePath -Force -ErrorAction Stop
}

$security = Get-WindowsUpdate | Where-Object { $_.Repository -like '*security*' }

if (-not $security) {
    Write-Host "No security updates available."
} else {
    Write-Host "Security updates available: $($security.Count)"
    $security | Select-Object Title, Version, CurrentVersion, Repository | Format-Table -AutoSize
}
