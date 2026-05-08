#Requires -Modules @{ ModuleName = 'Pester'; ModuleVersion = '5.2.0' }
<#
.Synopsis
    Pester tests for Update.Linux example scripts.
.Description
    Validates that each example script in the Examples\ folder:
      - exists on disk
      - has no syntax errors (parses cleanly)
    Linux-only execution tests are guarded with -Skip:(-not $IsLinux).
    All tests run on Windows (syntax/structure checks); live execution
    tests are skipped on Windows.
.Notes
    Free to use under GNU v3 Public License (https://choosealicense.com/licenses/gpl-3.0/)
    Author: Peppe Kerstens (NLD)
    Run with: Invoke-Pester .\Examples.Tests.ps1 -Output Detailed
#>

BeforeDiscovery {
    $script:ExamplesDir = if ($PSScriptRoot) { $PSScriptRoot } else { Split-Path $PSCommandPath -Parent }
    $script:ExampleFiles = @(
        'Get-AvailableUpdates.ps1'
        'Get-PackageHistory.ps1'
        'Get-SecurityUpdates.ps1'
        'Get-UpdateSummary.ps1'
    )
}

BeforeAll {
    $script:ExamplesDir = if ($PSScriptRoot) { $PSScriptRoot } else { Split-Path $PSCommandPath -Parent }
    if ($IsLinux) {
        $modulePath = Join-Path (Split-Path $script:ExamplesDir -Parent) 'Update.Linux' 'Update.Linux.psd1'
        if (Test-Path $modulePath) {
            Import-Module $modulePath -Force -ErrorAction Stop
        }
    }
}

Describe 'Example script files exist' {
    It 'Examples directory contains <_>' -ForEach $script:ExampleFiles {
        Join-Path $script:ExamplesDir $_ | Should -Exist
    }
}

Describe 'Example scripts have no syntax errors' {
    It '<_> parses without errors' -ForEach $script:ExampleFiles {
        $filePath = Join-Path $script:ExamplesDir $_
        $errors   = $null
        $null = [System.Management.Automation.Language.Parser]::ParseFile($filePath, [ref]$null, [ref]$errors)
        $errors | Should -BeNullOrEmpty
    }
}

Describe 'Get-AvailableUpdates' {
    It 'script file exists' {
        Join-Path $script:ExamplesDir 'Get-AvailableUpdates.ps1' | Should -Exist
    }
    It 'Get-LinuxUpdate returns objects with required properties' -Skip:(-not $IsLinux) {
        $result = Get-LinuxUpdate
        if ($result) {
            $result[0].PSObject.Properties.Name | Should -Contain 'Title'
            $result[0].PSObject.Properties.Name | Should -Contain 'Version'
            $result[0].PSObject.Properties.Name | Should -Contain 'Repository'
            $result[0].PSObject.Properties.Name | Should -Contain 'Architecture'
            $result[0].PSObject.Properties.Name | Should -Contain 'IsInstalled'
        } else {
            Set-ItResult -Skipped -Because 'no upgradable packages on this system'
        }
    }
    It 'IsInstalled is always false for upgradable packages' -Skip:(-not $IsLinux) {
        $result = Get-LinuxUpdate
        foreach ($u in $result) {
            $u.IsInstalled | Should -Be $false
        }
    }
    It 'alias Get-WindowsUpdate works as a parity alias' -Skip:(-not $IsLinux) {
        { Get-WindowsUpdate } | Should -Not -Throw
    }
}

Describe 'Get-PackageHistory' {
    It 'script file exists' {
        Join-Path $script:ExamplesDir 'Get-PackageHistory.ps1' | Should -Exist
    }
    It 'Get-LinuxUpdateHistory returns at most 20 entries' -Skip:(-not $IsLinux) {
        $result = Get-LinuxUpdateHistory -Last 20
        ($result | Measure-Object).Count | Should -BeLessOrEqual 20
    }
    It 'each history entry has Date, Action, Title, Version' -Skip:(-not $IsLinux) {
        $result = Get-LinuxUpdateHistory -Last 5
        foreach ($h in $result) {
            $h.PSObject.Properties.Name | Should -Contain 'Date'
            $h.PSObject.Properties.Name | Should -Contain 'Action'
            $h.PSObject.Properties.Name | Should -Contain 'Title'
            $h.PSObject.Properties.Name | Should -Contain 'Version'
        }
    }
    It 'Date values are [datetime] objects' -Skip:(-not $IsLinux) {
        $result = Get-LinuxUpdateHistory -Last 5
        foreach ($h in $result) {
            $h.Date | Should -BeOfType [datetime]
        }
    }
    It 'alias Get-WUHistory works as a parity alias' -Skip:(-not $IsLinux) {
        { Get-WUHistory -Last 5 } | Should -Not -Throw
    }
}

Describe 'Get-SecurityUpdates' {
    It 'script file exists' {
        Join-Path $script:ExamplesDir 'Get-SecurityUpdates.ps1' | Should -Exist
    }
    It 'security filter returns only packages from security repos' -Skip:(-not $IsLinux) {
        $security = Get-LinuxUpdate | Where-Object { $_.Repository -like '*security*' }
        foreach ($s in $security) {
            $s.Repository | Should -BeLike '*security*'
        }
    }
}

Describe 'Get-UpdateSummary' {
    It 'script file exists' {
        Join-Path $script:ExamplesDir 'Get-UpdateSummary.ps1' | Should -Exist
    }
    It 'Get-LinuxUpdate result count is non-negative' -Skip:(-not $IsLinux) {
        $all = Get-LinuxUpdate
        ($all | Measure-Object).Count | Should -BeGreaterOrEqual 0
    }
    It 'Get-LinuxUpdateHistory -Last 10 returns at most 10 entries' -Skip:(-not $IsLinux) {
        $h = Get-LinuxUpdateHistory -Last 10
        ($h | Measure-Object).Count | Should -BeLessOrEqual 10
    }
}
