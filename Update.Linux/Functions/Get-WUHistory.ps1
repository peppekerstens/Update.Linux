function Get-WUHistory {
    <#
    .Synopsis
        Gets the history of installed/removed packages.
    .Description
        Cross-platform implementation of Get-WUHistory (PSWindowsUpdate).
        On Windows, delegates to PSWindowsUpdate\Get-WUHistory.
        On Linux, parses /var/log/dpkg.log to return recent package installation history.
    .Parameter Last
        Maximum number of history entries to return. Default: 25.
    .Notes
        Free to use under GNU v3 Public License (https://choosealicense.com/licenses/gpl-3.0/)
        Author: Peppe Kerstens (NLD)
        Version: 1.0.0
        Date: 2026-05-08
    .Link
        https://learn.microsoft.com/powershell/module/pswindowsupdate/get-wuhistory
    #>
    [CmdletBinding()]
    [OutputType([PSCustomObject])]
    param(
        [Parameter(Position = 0)]
        [int]$Last = 25
    )

    if (-not $IsLinux) {
        if (Get-Module PSWindowsUpdate -ListAvailable -ErrorAction SilentlyContinue) {
            PSWindowsUpdate\Get-WUHistory @PSBoundParameters
        } else {
            Write-Warning "Get-WUHistory: PSWindowsUpdate module is not installed. Install it from PSGallery: Install-Module PSWindowsUpdate"
        }
        return
    }

    $logFile = '/var/log/dpkg.log'
    if (-not (Test-Path $logFile)) {
        Write-Warning "Get-WUHistory: $logFile not found."
        return
    }

    # dpkg.log format: YYYY-MM-DD HH:MM:SS status/action packagename:arch version
    # e.g.: 2026-05-08 12:34:56 status installed bash:amd64 5.1-6ubuntu1.1
    $results = Get-Content $logFile |
        Where-Object { $_ -match '^\d{4}-\d{2}-\d{2} \d{2}:\d{2}:\d{2} (install|upgrade|remove|purge|configure) ' } |
        ForEach-Object {
            if ($_ -match '^(\d{4}-\d{2}-\d{2} \d{2}:\d{2}:\d{2})\s+(\S+)\s+([^:]+)(?::(\S+))?\s+(\S+)(?:\s+(\S+))?') {
                [PSCustomObject]@{
                    Date        = [datetime]::ParseExact($Matches[1], 'yyyy-MM-dd HH:mm:ss', $null)
                    Action      = $Matches[2]
                    Title       = $Matches[3]
                    Architecture = $Matches[4]
                    Version     = $Matches[5]
                    OldVersion  = $Matches[6]
                    Result      = 'Succeeded'
                    KB          = $null
                }
            }
        } |
        Where-Object { $null -ne $_ } |
        Sort-Object Date -Descending |
        Select-Object -First $Last

    $results
}
