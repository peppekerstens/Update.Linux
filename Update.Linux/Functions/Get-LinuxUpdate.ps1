function Get-LinuxUpdate {
    <#
    .Synopsis
        Lists available package updates.
    .Description
        Lists packages available for upgrade on this Linux system.
        On Windows, delegates to PSWindowsUpdate\Get-WindowsUpdate if installed.
        On Linux, wraps 'apt list --upgradable' to return available package updates.
        Alias: Get-WindowsUpdate (for PSWindowsUpdate cmdlet parity)
    .Parameter Title
        Filter by package name (wildcard supported).
    .Parameter NotTitle
        Exclude packages matching this pattern (wildcard supported).
    .Parameter Category
        Filter by category (ignored on Linux — apt has no category metadata).
    .Notes
        Free to use under GNU v3 Public License (https://choosealicense.com/licenses/gpl-3.0/)
        Author: Peppe Kerstens (NLD)
        Version: 0.2.0
        Date: 2026-05-08
    .Link
        https://learn.microsoft.com/powershell/module/pswindowsupdate/get-windowsupdate
    #>
    [CmdletBinding()]
    [OutputType([PSCustomObject])]
    param(
        [Parameter(Position = 0)]
        [string]$Title,

        [Parameter()]
        [string]$NotTitle,

        [Parameter()]
        [string]$Category
    )

    if (-not $IsLinux) {
        if (Get-Module PSWindowsUpdate -ListAvailable -ErrorAction SilentlyContinue) {
            PSWindowsUpdate\Get-WindowsUpdate @PSBoundParameters
        } else {
            Write-Warning "Get-LinuxUpdate: PSWindowsUpdate module is not installed. Install it from PSGallery: Install-Module PSWindowsUpdate"
        }
        return
    }

    if (-not (Get-Command apt -ErrorAction SilentlyContinue)) {
        Write-Warning "Get-LinuxUpdate: 'apt' not found. This cmdlet requires a Debian/Ubuntu system."
        return
    }

    # apt list --upgradable emits a "Listing..." header line — skip it
    $raw = apt list --upgradable 2>/dev/null | Where-Object { $_ -match '/' }

    $results = foreach ($line in $raw) {
        # Format: packagename/repo version arch [upgradable from: oldversion]
        # e.g.: bash/jammy-updates 5.1-6ubuntu1.1 amd64 [upgradable from: 5.1-6ubuntu1]
        if ($line -match '^([^/]+)/(\S+)\s+(\S+)\s+(\S+)(?:\s+\[upgradable from:\s*([^\]]+)\])?') {
            [PSCustomObject]@{
                Title          = $Matches[1]
                Repository     = $Matches[2]
                Version        = $Matches[3]
                Architecture   = $Matches[4]
                CurrentVersion = $Matches[5]
                KB             = $null
                Size           = 0
                Status         = 'Available'
                Category       = 'Security'
                MsrcSeverity   = $null
                RebootRequired = $false
                IsDownloaded   = $false
                IsInstalled    = $false
                IsHidden       = $false
            }
        }
    }

    # Apply filters
    if ($Title) {
        $results = $results | Where-Object { $_.Title -like $Title }
    }
    if ($NotTitle) {
        $results = $results | Where-Object { $_.Title -notlike $NotTitle }
    }

    $results
}
