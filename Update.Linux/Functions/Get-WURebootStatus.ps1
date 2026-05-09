function Get-WURebootStatus {
    <#
    .Synopsis
        Gets the reboot status — indicates whether a reboot is required after updates.
    .Description
        On Linux (Debian/Ubuntu), checks /var/run/reboot-required and
        /var/run/reboot-required.pkgs to determine if a reboot is needed and which
        packages require it. On Windows, delegates to PSWindowsUpdate\Get-WURebootStatus.
    .Notes
        Free to use under GNU v3 Public License (https://choosealicense.com/licenses/gpl-3.0/)
        Author: Peppe Kerstens (NLD)
    .Link
        https://learn.microsoft.com/powershell/module/pswindowsupdate/get-wurebootstatus
    #>
    [CmdletBinding()]
    [OutputType([PSCustomObject])]
    param()
    process {
        if (-not $IsLinux) {
            if (Get-Module PSWindowsUpdate -ListAvailable -ErrorAction SilentlyContinue) {
                PSWindowsUpdate\Get-WURebootStatus
            } else {
                Write-Warning 'Get-WURebootStatus: PSWindowsUpdate module is not installed. Install it from PSGallery: Install-Module PSWindowsUpdate'
            }
            return
        }

        $rebootFile = '/var/run/reboot-required'
        $pkgsFile   = '/var/run/reboot-required.pkgs'
        $required   = Test-Path $rebootFile

        $packages = if ($required -and (Test-Path $pkgsFile)) {
            Get-Content $pkgsFile -ErrorAction SilentlyContinue
        } else {
            @()
        }

        [PSCustomObject]@{
            RebootRequired  = $required
            RebootPackages  = $packages
            Source          = if ($required) { $rebootFile } else { 'none' }
        }
    }
}
