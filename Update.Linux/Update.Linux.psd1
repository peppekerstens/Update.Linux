#
# Module manifest for module 'Update.Linux'
#

@{
    RootModule        = 'Update.Linux.psm1'
    ModuleVersion     = '0.1.0'
    GUID              = 'b2c3d4e5-f6a7-8901-bcde-f12345678901'
    Author            = 'Peppe Kerstens'
    CompanyName       = ''
    Copyright         = '(c) Peppe Kerstens. GPL-3.0 license.'
    Description       = 'PowerShell module for Linux providing cmdlet parity with PSWindowsUpdate. Implements Get-WindowsUpdate, Install-WindowsUpdate, Get-WUHistory using apt and dpkg.'
    PowerShellVersion = '7.2'
    RequiredModules   = @()

    FunctionsToExport = @(
        # Fully implemented
        'Get-WindowsUpdate',
        'Install-WindowsUpdate',
        'Get-WUHistory',
        # Stubs
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
        'Hide-WindowsUpdate',
        'Invoke-WUJob',
        'Remove-WindowsUpdate',
        'Remove-WUServiceManager',
        'Reset-WUComponents',
        'Set-PSWUSettings',
        'Set-WUSettings',
        'Show-WindowsUpdate',
        'Update-WUModule'
    )

    CmdletsToExport   = @()
    VariablesToExport = @()
    AliasesToExport   = @()

    PrivateData = @{
        PSData = @{
            Tags         = @('Linux', 'Update', 'apt', 'dpkg', 'PSWindowsUpdate', 'CrossPlatform')
            LicenseUri   = 'https://github.com/peppekerstens/Update.Linux/blob/main/LICENSE'
            ProjectUri   = 'https://github.com/peppekerstens/Update.Linux'
            ReleaseNotes = @'
0.1.0 - Initial release. Get-WindowsUpdate, Install-WindowsUpdate, Get-WUHistory implemented. Stubs for remaining 19 PSWindowsUpdate cmdlets.
'@
        }
    }
}
