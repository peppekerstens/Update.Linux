function Remove-LinuxUpdate {
    <#
    .Synopsis
        Removes (uninstalls) an installed package.
    .Description
        On Linux (Debian/Ubuntu), runs 'sudo apt-get remove <Name>' to uninstall the
        specified package(s). Use -Purge to also remove configuration files (apt-get purge).
        On Windows, delegates to PSWindowsUpdate\Remove-WindowsUpdate.
        Alias: Remove-WindowsUpdate
    .Parameter Name
        The package name(s) to remove. Required.
    .Parameter Purge
        Also remove configuration files (equivalent to 'apt-get purge').
    .Notes
        Free to use under GNU v3 Public License (https://choosealicense.com/licenses/gpl-3.0/)
        Author: Peppe Kerstens (NLD)
    .Link
        https://learn.microsoft.com/powershell/module/pswindowsupdate/remove-windowsupdate
    #>
    [CmdletBinding(SupportsShouldProcess = $true, ConfirmImpact = 'High')]
    [OutputType([void])]
    param(
        [Parameter(Mandatory = $true, Position = 0, ValueFromPipeline = $true)]
        [string[]]$Name,

        [switch]$Purge
    )
    process {
        if (-not $IsLinux) {
            if (Get-Module PSWindowsUpdate -ListAvailable -ErrorAction SilentlyContinue) {
                PSWindowsUpdate\Remove-WindowsUpdate @PSBoundParameters
            } else {
                Write-Warning 'Remove-LinuxUpdate: PSWindowsUpdate module is not installed. Install it from PSGallery: Install-Module PSWindowsUpdate'
            }
            return
        }

        if (-not (Get-Command apt-get -ErrorAction SilentlyContinue)) {
            Write-Error "Remove-LinuxUpdate: 'apt-get' not found. This cmdlet requires a Debian/Ubuntu system."
            return
        }

        $aptVerb = if ($Purge) { 'purge' } else { 'remove' }

        foreach ($pkg in $Name) {
            if ($PSCmdlet.ShouldProcess($pkg, "Remove package (apt-get $aptVerb)")) {
                $result = & sudo apt-get $aptVerb -y $pkg 2>&1
                if ($LASTEXITCODE -ne 0) {
                    Write-Error "Remove-LinuxUpdate: apt-get $aptVerb failed for '$pkg': $result"
                }
            }
        }
    }
}
