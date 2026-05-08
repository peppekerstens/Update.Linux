function Install-LinuxUpdate {
    <#
    .Synopsis
        Installs available package updates.
    .Description
        Installs available package updates on this Linux system.
        On Windows, delegates to PSWindowsUpdate\Install-WindowsUpdate if installed.
        On Linux, wraps 'apt-get upgrade' (or 'apt-get dist-upgrade' with -RecursiveInclude)
        to apply all available updates. Requires root or sudo privileges.
        Alias: Install-WindowsUpdate (for PSWindowsUpdate cmdlet parity)
    .Parameter Title
        Install only packages matching this pattern (wildcard). Default: all upgradable packages.
    .Parameter AcceptAll
        Accept all prompts automatically (passes -y to apt-get).
    .Parameter AutoReboot
        Reboot automatically after install if required (runs 'shutdown -r 0').
    .Parameter IgnoreReboot
        Do not prompt or reboot even if reboot is required.
    .Parameter RecursiveInclude
        Use 'apt-get dist-upgrade' instead of 'apt-get upgrade' to also install new dependencies.
    .Notes
        Free to use under GNU v3 Public License (https://choosealicense.com/licenses/gpl-3.0/)
        Author: Peppe Kerstens (NLD)
        Version: 0.2.0
        Date: 2026-05-08
    .Link
        https://learn.microsoft.com/powershell/module/pswindowsupdate/install-windowsupdate
    #>
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter(Position = 0)]
        [string]$Title,

        [switch]$AcceptAll,

        [switch]$AutoReboot,

        [switch]$IgnoreReboot,

        [switch]$RecursiveInclude
    )

    if (-not $IsLinux) {
        if (Get-Module PSWindowsUpdate -ListAvailable -ErrorAction SilentlyContinue) {
            PSWindowsUpdate\Install-WindowsUpdate @PSBoundParameters
        } else {
            Write-Warning "Install-LinuxUpdate: PSWindowsUpdate module is not installed. Install it from PSGallery: Install-Module PSWindowsUpdate"
        }
        return
    }

    if (-not (Get-Command apt-get -ErrorAction SilentlyContinue)) {
        Write-Warning "Install-LinuxUpdate: 'apt-get' not found. This cmdlet requires a Debian/Ubuntu system."
        return
    }

    # Determine which packages to install
    if ($Title) {
        # Get matching upgradable packages
        $packages = Get-LinuxUpdate -Title $Title | Select-Object -ExpandProperty Title
        if (-not $packages) {
            Write-Verbose "Install-LinuxUpdate: No packages match '$Title'."
            return
        }
        $targetDesc = "packages matching '$Title': $($packages -join ', ')"
    } else {
        $packages = @()
        $targetDesc = "all upgradable packages"
    }

    if ($PSCmdlet.ShouldProcess($targetDesc, 'Install-LinuxUpdate')) {
        $aptCmd  = if ($RecursiveInclude) { 'dist-upgrade' } else { 'upgrade' }
        $aptArgs = @($aptCmd)
        if ($AcceptAll) { $aptArgs += '-y' }

        if ($packages) {
            # Install specific packages
            $aptArgs = @('install') + ($packages) + $(if ($AcceptAll) { @('-y') })
        }

        Write-Verbose "Running: apt-get $($aptArgs -join ' ')"
        & apt-get @aptArgs

        if ($LASTEXITCODE -ne 0) {
            Write-Error "Install-LinuxUpdate: apt-get exited with code $LASTEXITCODE"
            return
        }

        # Check if reboot is required
        $rebootRequired = Test-Path '/var/run/reboot-required'
        if ($rebootRequired -and -not $IgnoreReboot) {
            if ($AutoReboot) {
                Write-Warning "Install-LinuxUpdate: Reboot required. Rebooting now..."
                & shutdown -r 0
            } else {
                Write-Warning "Install-LinuxUpdate: Reboot required to complete updates. Run 'Restart-Computer' or reboot manually."
            }
        }
    }
}
