function Hide-LinuxUpdate {
    <#
    .Synopsis
        Holds (pins) a package so apt does not upgrade it automatically.
    .Description
        On Linux (Debian/Ubuntu), runs 'sudo apt-mark hold <Name>' to pin the package
        at its current version. Held packages are excluded from 'apt upgrade'.
        On Windows, delegates to PSWindowsUpdate\Hide-WindowsUpdate.
        Alias: Hide-WindowsUpdate
    .Parameter Name
        The package name(s) to hold. Required.
    .Notes
        Free to use under GNU v3 Public License (https://choosealicense.com/licenses/gpl-3.0/)
        Author: Peppe Kerstens (NLD)
    .Link
        https://learn.microsoft.com/powershell/module/pswindowsupdate/hide-windowsupdate
    #>
    [CmdletBinding(SupportsShouldProcess = $true)]
    [OutputType([void])]
    param(
        [Parameter(Mandatory = $true, Position = 0, ValueFromPipeline = $true)]
        [string[]]$Name
    )
    process {
        if (-not $IsLinux) {
            if (Get-Module PSWindowsUpdate -ListAvailable -ErrorAction SilentlyContinue) {
                PSWindowsUpdate\Hide-WindowsUpdate @PSBoundParameters
            } else {
                Write-Warning 'Hide-LinuxUpdate: PSWindowsUpdate module is not installed. Install it from PSGallery: Install-Module PSWindowsUpdate'
            }
            return
        }

        if (-not (Get-Command apt-mark -ErrorAction SilentlyContinue)) {
            Write-Error "Hide-LinuxUpdate: 'apt-mark' not found. This cmdlet requires a Debian/Ubuntu system."
            return
        }

        foreach ($pkg in $Name) {
            if ($PSCmdlet.ShouldProcess($pkg, 'Hold package (apt-mark hold)')) {
                $result = & sudo apt-mark hold $pkg 2>&1
                if ($LASTEXITCODE -ne 0) {
                    Write-Error "Hide-LinuxUpdate: apt-mark hold failed for '$pkg': $result"
                } else {
                    Write-Verbose "Hide-LinuxUpdate: '$pkg' is now held."
                }
            }
        }
    }
}
