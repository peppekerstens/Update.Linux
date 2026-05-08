# Update.Linux

PowerShell module providing Linux-native cmdlet parity with **PSWindowsUpdate**.  
Scripts written for Windows using `Get-WindowsUpdate` / `Install-WindowsUpdate` work on Linux without modification.

---

## What it does

`Update.Linux` wraps `apt` and `dpkg` to give PowerShell cmdlets that mirror the PSWindowsUpdate module.  
Functions use Linux-appropriate names; **PSWindowsUpdate aliases are included** so existing Windows scripts run unmodified.

| Linux-native cmdlet | PSWindowsUpdate alias | Status | Linux tool |
|---|---|---|---|
| `Get-LinuxUpdate` | `Get-WindowsUpdate` | ✅ Implemented | `apt list --upgradable` |
| `Install-LinuxUpdate` | `Install-WindowsUpdate` | ✅ Implemented | `apt-get upgrade` / `apt-get install` |
| `Get-LinuxUpdateHistory` | `Get-WUHistory` | ✅ Implemented | `/var/log/dpkg.log` |
| `Hide-LinuxUpdate` | `Hide-WindowsUpdate` | 🔧 Stub | — |
| `Remove-LinuxUpdate` | `Remove-WindowsUpdate` | 🔧 Stub | — |
| `Show-LinuxUpdate` | `Show-WindowsUpdate` | 🔧 Stub | — |
| All other 13 `WU*` cmdlets | _(same name)_ | 🔧 Stub | — |

The module is **Linux-only**. On Windows, the implemented cmdlets delegate to PSWindowsUpdate if installed.

---

## Requirements

- PowerShell 7.2+
- Linux (Debian/Ubuntu family — requires `apt` and `apt-get`)
- `apt` and `dpkg` available in `$PATH`
- Root or `sudo` privileges for `Install-WindowsUpdate`

---

## Installation

```powershell
# Clone the repository
git clone https://github.com/peppekerstens/Update.Linux.git

# Import the module
Import-Module ./Update.Linux/Update.Linux/Update.Linux.psd1
```

---

## Usage

```powershell
# List all available updates (Linux-native name)
Get-LinuxUpdate

# Same call using the PSWindowsUpdate parity alias
Get-WindowsUpdate

# Filter by package name
Get-LinuxUpdate -Title 'bash'
Get-LinuxUpdate -Title 'lib*'

# Show package history (Linux-native name)
Get-LinuxUpdateHistory
Get-LinuxUpdateHistory -Last 50

# Same call using the PSWindowsUpdate parity alias
Get-WUHistory -Last 50

# Install all updates (requires sudo/root)
Install-LinuxUpdate -AcceptAll

# Install specific packages
Install-LinuxUpdate -Title 'bash' -AcceptAll

# Check for reboot requirement after upgrade
Install-LinuxUpdate -AcceptAll -AutoReboot
```

---

## Examples

See [`Examples\`](Examples/) for ready-to-run scripts:

| Script | Description |
|---|---|
| `Get-AvailableUpdates.ps1` | List all upgradable packages |
| `Get-PackageHistory.ps1` | Show recent package install/upgrade history |
| `Get-SecurityUpdates.ps1` | Filter updates from security repositories |
| `Get-UpdateSummary.ps1` | Summary report grouped by repository |

---

## Cmdlet Status

### Fully Implemented

| Linux-native cmdlet | PSWindowsUpdate alias | Parameters |
|---|---|---|
| `Get-LinuxUpdate` | `Get-WindowsUpdate` | `-Title`, `-NotTitle`, `-Category` |
| `Install-LinuxUpdate` | `Install-WindowsUpdate` | `-Title`, `-AcceptAll`, `-AutoReboot`, `-IgnoreReboot`, `-RecursiveInclude` |
| `Get-LinuxUpdateHistory` | `Get-WUHistory` | `-Last` |

### Stubs with aliases (not yet implemented — PRs welcome)

| Linux-native cmdlet | PSWindowsUpdate alias |
|---|---|
| `Hide-LinuxUpdate` | `Hide-WindowsUpdate` |
| `Remove-LinuxUpdate` | `Remove-WindowsUpdate` |
| `Show-LinuxUpdate` | `Show-WindowsUpdate` |

### Stubs without rename (WU-prefixed — not yet implemented)

`Add-WUServiceManager`, `Disable-WURemoting`, `Enable-WURemoting`, `Get-WUApiVersion`,
`Get-WUInstallerStatus`, `Get-WUJob`, `Get-WULastResults`, `Get-WURebootStatus`,
`Get-WUServiceManager`, `Get-WUSettings`, `Invoke-WUJob`, `Remove-WUServiceManager`,
`Reset-WUComponents`, `Set-PSWUSettings`, `Set-WUSettings`, `Update-WUModule`

---

## Implementation Notes

- Functions use Linux-appropriate names (`Get-LinuxUpdate`, etc.); PSWindowsUpdate aliases (`Get-WindowsUpdate`, etc.) are exported for drop-in compatibility
- `Get-LinuxUpdate` skips the `Listing...` header line emitted by `apt list --upgradable 2>/dev/null`
- `Get-LinuxUpdateHistory` parses `/var/log/dpkg.log` and returns entries sorted newest-first
- `Install-LinuxUpdate -RecursiveInclude` uses `apt-get dist-upgrade` for full dependency resolution
- The module throws a descriptive error if loaded on Windows (Linux-only guard in `.psm1`)
- Output objects use `[PSCustomObject]` to match PSWindowsUpdate property shapes

---

## Version History

| Version | Date | Notes |
|---|---|---|
| 0.2.0 | 2026-05-08 | Renamed core functions to Linux-native names; added PSWindowsUpdate aliases for parity |
| 0.1.0 | 2026-05-08 | Initial release |

---

## License

[GNU General Public License v3.0](LICENSE)
