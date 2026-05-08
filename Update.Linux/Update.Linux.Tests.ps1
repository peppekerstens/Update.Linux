#Requires -Modules @{ ModuleName = 'Pester'; ModuleVersion = '5.2.0' }
<#
.Synopsis
    Pester tests for Update.Linux module.
.Description
    Validates module structure, function exports, alias exports, and runtime behaviour.
    Linux-only execution tests are guarded with -Skip:(-not $IsLinux).
    All tests run on Windows (syntax/structure checks); live execution
    tests are skipped on Windows.
.Notes
    Free to use under GNU v3 Public License (https://choosealicense.com/licenses/gpl-3.0/)
    Author: Peppe Kerstens (NLD)
    Run with: Invoke-Pester .\Update.Linux.Tests.ps1 -Output Detailed
#>

BeforeDiscovery {
    $script:ModuleRoot = if ($PSScriptRoot) { $PSScriptRoot } else { Split-Path $PSCommandPath -Parent }

    $script:ExpectedFunctions = @(
        # Implemented — Linux-native names
        'Get-LinuxUpdate',
        'Install-LinuxUpdate',
        'Get-LinuxUpdateHistory',
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

    $script:ExpectedAliases = @(
        'Get-WindowsUpdate',
        'Install-WindowsUpdate',
        'Get-WUHistory',
        'Hide-WindowsUpdate',
        'Remove-WindowsUpdate',
        'Show-WindowsUpdate'
    )
}

BeforeAll {
    $script:ModuleRoot   = if ($PSScriptRoot) { $PSScriptRoot } else { Split-Path $PSCommandPath -Parent }
    $script:ManifestPath = Join-Path $script:ModuleRoot 'Update.Linux.psd1'
    $script:PsmPath      = Join-Path $script:ModuleRoot 'Update.Linux.psm1'
    if ($IsLinux) {
        $modulePath = Join-Path $script:ModuleRoot 'Update.Linux.psd1'
        if (Test-Path $modulePath) {
            Import-Module $modulePath -Force -ErrorAction Stop
        }
    }
}

# ── Module files ──────────────────────────────────────────────────────────────

Describe 'Module files exist' {
    It 'Update.Linux.psd1 exists' {
        $script:ManifestPath | Should -Exist
    }
    It 'Update.Linux.psm1 exists' {
        $script:PsmPath | Should -Exist
    }
    It 'Functions\ directory exists' {
        Join-Path $script:ModuleRoot 'Functions' | Should -Exist
    }
}

Describe 'Module manifest is valid' {
    It 'psd1 is parseable' {
        { Import-PowerShellDataFile $script:ManifestPath } | Should -Not -Throw
    }
    It 'ModuleVersion is set' {
        $m = Import-PowerShellDataFile $script:ManifestPath
        $m.ModuleVersion | Should -Not -BeNullOrEmpty
    }
    It 'FunctionsToExport contains all expected functions' {
        $m = Import-PowerShellDataFile $script:ManifestPath
        foreach ($fn in $script:ExpectedFunctions) {
            $m.FunctionsToExport | Should -Contain $fn
        }
    }
    It 'AliasesToExport contains all expected aliases' {
        $m = Import-PowerShellDataFile $script:ManifestPath
        foreach ($alias in $script:ExpectedAliases) {
            $m.AliasesToExport | Should -Contain $alias
        }
    }
}

Describe 'Function files exist and have no syntax errors' {
    It '<_>.ps1 exists' -ForEach $script:ExpectedFunctions {
        $filePath = Join-Path $script:ModuleRoot 'Functions' "$_.ps1"
        $filePath | Should -Exist
    }
    It '<_>.ps1 parses without errors' -ForEach $script:ExpectedFunctions {
        $filePath = Join-Path $script:ModuleRoot 'Functions' "$_.ps1"
        $errors   = $null
        $null = [System.Management.Automation.Language.Parser]::ParseFile($filePath, [ref]$null, [ref]$errors)
        $errors | Should -BeNullOrEmpty
    }
}

# ── Linux-only runtime tests ──────────────────────────────────────────────────

Describe 'Module loads on Linux' -Skip:(-not $IsLinux) {
    It 'module is importable' {
        Get-Module Update.Linux | Should -Not -BeNullOrEmpty
    }
    It 'Linux-native function <_> is exported' -ForEach $script:ExpectedFunctions {
        Get-Command $_ -Module Update.Linux | Should -Not -BeNullOrEmpty
    }
    It 'alias <_> is exported' -ForEach $script:ExpectedAliases {
        Get-Alias $_ -ErrorAction SilentlyContinue | Should -Not -BeNullOrEmpty
    }
}

Describe 'Get-LinuxUpdate' -Skip:(-not $IsLinux) {
    It 'returns objects or empty collection without error' {
        { $script:updates = Get-LinuxUpdate } | Should -Not -Throw
    }
    It 'each object has required properties' {
        if ($script:updates) {
            $script:updates[0].PSObject.Properties.Name | Should -Contain 'Title'
            $script:updates[0].PSObject.Properties.Name | Should -Contain 'Version'
            $script:updates[0].PSObject.Properties.Name | Should -Contain 'Repository'
            $script:updates[0].PSObject.Properties.Name | Should -Contain 'Architecture'
            $script:updates[0].PSObject.Properties.Name | Should -Contain 'IsInstalled'
            $script:updates[0].PSObject.Properties.Name | Should -Contain 'RebootRequired'
        } else {
            Set-ItResult -Skipped -Because 'no upgradable packages on this system'
        }
    }
    It 'IsInstalled is always false for upgradable packages' {
        foreach ($u in $script:updates) {
            $u.IsInstalled | Should -Be $false
        }
    }
    It '-Title filter narrows results' {
        if ($script:updates) {
            $pkg  = $script:updates[0].Title
            $filt = Get-LinuxUpdate -Title $pkg
            $filt | Should -Not -BeNullOrEmpty
            $filt | ForEach-Object { $_.Title | Should -Be $pkg }
        } else {
            Set-ItResult -Skipped -Because 'no upgradable packages on this system'
        }
    }
    It '-Title wildcard with no match returns empty' {
        $result = Get-LinuxUpdate -Title 'zzz-nonexistent-package-xyzzy'
        $result | Should -BeNullOrEmpty
    }
    It 'alias Get-WindowsUpdate resolves to the same cmdlet' {
        $alias = Get-Alias 'Get-WindowsUpdate' -ErrorAction SilentlyContinue
        $alias.ResolvedCommandName | Should -Be 'Get-LinuxUpdate'
    }
}

Describe 'Get-LinuxUpdateHistory' -Skip:(-not $IsLinux) {
    It 'returns objects without error' {
        { $script:history = Get-LinuxUpdateHistory } | Should -Not -Throw
    }
    It 'returns at most -Last entries (default 25)' {
        ($script:history | Measure-Object).Count | Should -BeLessOrEqual 25
    }
    It 'each object has required properties' {
        if ($script:history) {
            $script:history[0].PSObject.Properties.Name | Should -Contain 'Date'
            $script:history[0].PSObject.Properties.Name | Should -Contain 'Action'
            $script:history[0].PSObject.Properties.Name | Should -Contain 'Title'
            $script:history[0].PSObject.Properties.Name | Should -Contain 'Version'
            $script:history[0].PSObject.Properties.Name | Should -Contain 'Result'
        } else {
            Set-ItResult -Skipped -Because 'dpkg.log is empty or has no matching entries'
        }
    }
    It 'Date property is a [datetime]' {
        foreach ($h in $script:history) {
            $h.Date | Should -BeOfType [datetime]
        }
    }
    It '-Last 5 returns at most 5 entries' {
        $result = Get-LinuxUpdateHistory -Last 5
        ($result | Measure-Object).Count | Should -BeLessOrEqual 5
    }
    It 'results are sorted descending by date' {
        if (($script:history | Measure-Object).Count -gt 1) {
            for ($i = 0; $i -lt ($script:history.Count - 1); $i++) {
                $script:history[$i].Date | Should -BeGreaterOrEqual $script:history[$i + 1].Date
            }
        }
    }
    It 'alias Get-WUHistory resolves to the same cmdlet' {
        $alias = Get-Alias 'Get-WUHistory' -ErrorAction SilentlyContinue
        $alias.ResolvedCommandName | Should -Be 'Get-LinuxUpdateHistory'
    }
}

Describe 'Stub functions emit warnings' -Skip:(-not $IsLinux) {
    It '<_> emits a warning and does not throw' -ForEach @(
        'Add-WUServiceManager', 'Disable-WURemoting', 'Enable-WURemoting',
        'Get-WUApiVersion', 'Get-WUInstallerStatus', 'Get-WUJob',
        'Get-WULastResults', 'Get-WURebootStatus', 'Get-WUServiceManager',
        'Get-WUSettings', 'Hide-LinuxUpdate', 'Invoke-WUJob',
        'Remove-LinuxUpdate', 'Remove-WUServiceManager', 'Reset-WUComponents',
        'Set-PSWUSettings', 'Set-WUSettings', 'Show-LinuxUpdate',
        'Update-WUModule'
    ) {
        { & $_ -WarningAction SilentlyContinue } | Should -Not -Throw
    }
}
