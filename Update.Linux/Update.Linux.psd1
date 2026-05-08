#
# Module manifest for module 'Update.Linux'
#

@{
    RootModule        = 'Update.Linux.psm1'
    ModuleVersion     = '0.2.0'
    GUID              = 'b2c3d4e5-f6a7-8901-bcde-f12345678901'
    Author            = 'Peppe Kerstens'
    CompanyName       = ''
    Copyright         = '(c) Peppe Kerstens. GPL-3.0 license.'
    Description       = 'PowerShell module for Linux providing cmdlet parity with PSWindowsUpdate. Implements Get-LinuxUpdate, Install-LinuxUpdate, Get-LinuxUpdateHistory using apt and dpkg. PSWindowsUpdate aliases included for parity.'
    PowerShellVersion = '7.2'
    RequiredModules   = @()

    FunctionsToExport = @(
        # Fully implemented — Linux-native names
        'Get-LinuxUpdate',
        'Install-LinuxUpdate',
        'Get-LinuxUpdateHistory',
        # Stubs — Linux-native names
        'Add-WUServiceManager',
        'Disable-WURemoting',
        'Enable-WURemoting',
        'Get-WUApiVersion',
        'Get-WUInstallerStatus',
        'Get-WUJob',
        'Get-WULastResults',
        'Get-WURebootStatus',
        'Get-WUServiceManager',
        'Get-WUSettings',
        'Hide-LinuxUpdate',
        'Invoke-WUJob',
        'Remove-LinuxUpdate',
        'Remove-WUServiceManager',
        'Reset-WUComponents',
        'Set-PSWUSettings',
        'Set-WUSettings',
        'Show-LinuxUpdate',
        'Update-WUModule'
    )

    CmdletsToExport   = @()
    VariablesToExport = @()

    # PSWindowsUpdate / WU compatibility aliases for cmdlet parity
    AliasesToExport   = @(
        'Get-WindowsUpdate',
        'Install-WindowsUpdate',
        'Get-WUHistory',
        'Hide-WindowsUpdate',
        'Remove-WindowsUpdate',
        'Show-WindowsUpdate'
    )

    PrivateData = @{
        PSData = @{
            Tags         = @('Linux', 'Update', 'apt', 'dpkg', 'PSWindowsUpdate', 'CrossPlatform')
            LicenseUri   = 'https://github.com/peppekerstens/Update.Linux/blob/main/LICENSE'
            ProjectUri   = 'https://github.com/peppekerstens/Update.Linux'
            ReleaseNotes = @'
0.2.0 - Renamed core functions to Linux-native names (Get-LinuxUpdate, Install-LinuxUpdate, Get-LinuxUpdateHistory). Added PSWindowsUpdate aliases for cmdlet parity.
0.1.0 - Initial release. Get-WindowsUpdate, Install-WindowsUpdate, Get-WUHistory implemented. Stubs for remaining 19 PSWindowsUpdate cmdlets.
'@
        }
    }
}
