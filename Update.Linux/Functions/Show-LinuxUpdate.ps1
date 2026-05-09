function Show-LinuxUpdate {
    <#
    .Synopsis
        Unholds (unpins) a package so apt can upgrade it again.
    .Description
        On Linux (Debian/Ubuntu), runs 'sudo apt-mark unhold <Name>' to remove a hold
        placed by Hide-LinuxUpdate (apt-mark hold). The package will then be eligible
        for 'apt upgrade' again.
        On Windows, delegates to PSWindowsUpdate\Show-WindowsUpdate.
        Alias: Show-WindowsUpdate
    .Parameter Name
        The package name(s) to unhold. Required.
    .Notes
        Free to use under GNU v3 Public License (https://choosealicense.com/licenses/gpl-3.0/)
        Author: Peppe Kerstens (NLD)
    .Link
        https://learn.microsoft.com/powershell/module/pswindowsupdate/show-windowsupdate
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
                PSWindowsUpdate\Show-WindowsUpdate @PSBoundParameters
            } else {
                Write-Warning 'Show-LinuxUpdate: PSWindowsUpdate module is not installed. Install it from PSGallery: Install-Module PSWindowsUpdate'
            }
            return
        }

        if (-not (Get-Command apt-mark -ErrorAction SilentlyContinue)) {
            Write-Error "Show-LinuxUpdate: 'apt-mark' not found. This cmdlet requires a Debian/Ubuntu system."
            return
        }

        foreach ($pkg in $Name) {
            if ($PSCmdlet.ShouldProcess($pkg, 'Unhold package (apt-mark unhold)')) {
                $result = & sudo apt-mark unhold $pkg 2>&1
                if ($LASTEXITCODE -ne 0) {
                    Write-Error "Show-LinuxUpdate: apt-mark unhold failed for '$pkg': $result"
                } else {
                    Write-Verbose "Show-LinuxUpdate: '$pkg' is now unheld."
                }
            }
        }
    }
}
