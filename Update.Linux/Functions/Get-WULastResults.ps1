function Get-WULastResults {
    <#
    .Synopsis
        Gets the date and result of the last apt update/upgrade run.
    .Description
        On Linux (Debian/Ubuntu), parses /var/log/apt/history.log to find the most
        recent Commandline, Start-Date, and End-Date entries. Returns a summary of the
        last apt operation performed.
        On Windows, delegates to PSWindowsUpdate\Get-WULastResults.
    .Notes
        Free to use under GNU v3 Public License (https://choosealicense.com/licenses/gpl-3.0/)
        Author: Peppe Kerstens (NLD)
    .Link
        https://learn.microsoft.com/powershell/module/pswindowsupdate/get-wulastresults
    #>
    [CmdletBinding()]
    [OutputType([PSCustomObject])]
    param()
    process {
        if (-not $IsLinux) {
            if (Get-Module PSWindowsUpdate -ListAvailable -ErrorAction SilentlyContinue) {
                PSWindowsUpdate\Get-WULastResults
            } else {
                Write-Warning 'Get-WULastResults: PSWindowsUpdate module is not installed. Install it from PSGallery: Install-Module PSWindowsUpdate'
            }
            return
        }

        $logFile = '/var/log/apt/history.log'
        if (-not (Test-Path $logFile)) {
            Write-Error "Get-WULastResults: $logFile not found."
            return
        }

        $content = Get-Content $logFile -ErrorAction SilentlyContinue -Raw
        if (-not $content) {
            Write-Verbose 'Get-WULastResults: apt history log is empty.'
            return
        }

        # Split into records — each record is separated by a blank line
        $records = ($content -split '\n\n' | Where-Object { $_.Trim() })

        # Take the last non-empty record
        $lastRecord = $records | Select-Object -Last 1

        $startDate  = if ($lastRecord -match 'Start-Date:\s+(.+)') { $Matches[1].Trim() } else { $null }
        $endDate    = if ($lastRecord -match 'End-Date:\s+(.+)')   { $Matches[1].Trim() } else { $null }
        $commandLine = if ($lastRecord -match 'Commandline:\s+(.+)') { $Matches[1].Trim() } else { 'unknown' }
        $installed  = if ($lastRecord -match 'Install:\s+(.+)')   { $Matches[1].Trim() } else { $null }
        $upgraded   = if ($lastRecord -match 'Upgrade:\s+(.+)')   { $Matches[1].Trim() } else { $null }
        $removed    = if ($lastRecord -match 'Remove:\s+(.+)')    { $Matches[1].Trim() } else { $null }

        [PSCustomObject]@{
            LastSearchDate   = if ($startDate)  { [datetime]::ParseExact($startDate,  'yyyy-MM-dd  HH:mm:ss', $null) } else { $null }
            LastInstallDate  = if ($endDate)    { [datetime]::ParseExact($endDate,    'yyyy-MM-dd  HH:mm:ss', $null) } else { $null }
            LastCommandLine  = $commandLine
            Installed        = $installed
            Upgraded         = $upgraded
            Removed          = $removed
            Source           = $logFile
        }
    }
}
