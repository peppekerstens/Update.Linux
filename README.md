# Update.Linux

PowerShell module providing Linux-native cmdlet parity with **PSWindowsUpdate**.  
Scripts written for Windows using `Get-WindowsUpdate` / `Install-WindowsUpdate` work on Linux without modification.

---

## What it does

`Update.Linux` wraps `apt` and `dpkg` to give PowerShell cmdlets that mirror the PSWindowsUpdate module:

| Cmdlet | Status | Linux tool |
|---|---|---|
| `Get-WindowsUpdate` | ✅ Implemented | `apt list --upgradable` |
| `Install-WindowsUpdate` | ✅ Implemented | `apt-get upgrade` / `apt-get install` |
| `Get-WUHistory` | ✅ Implemented | `/var/log/dpkg.log` |
| All other 19 PSWindowsUpdate cmdlets | 🔧 Stub | — |

The module is **Linux-only**. On Linux, `Get-WindowsUpdate`, `Install-WindowsUpdate`, and `Get-WUHistory` delegate to Windows implementations if PSWindowsUpdate is installed; on Linux they use native apt/dpkg.

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
# List all available updates
Get-WindowsUpdate

# Filter by package name
Get-WindowsUpdate -Title 'bash'
Get-WindowsUpdate -Title 'lib*'

# Show package history
Get-WUHistory
Get-WUHistory -Last 50

# Install all updates (requires sudo/root)
Install-WindowsUpdate -AcceptAll

# Install specific packages
Install-WindowsUpdate -Title 'bash' -AcceptAll

# Check for reboot requirement after upgrade
Install-WindowsUpdate -AcceptAll -AutoReboot
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

| Cmdlet | Parameters |
|---|---|
| `Get-WindowsUpdate` | `-Title`, `-NotTitle`, `-Category` |
| `Install-WindowsUpdate` | `-Title`, `-AcceptAll`, `-AutoReboot`, `-IgnoreReboot`, `-RecursiveInclude` |
| `Get-WUHistory` | `-Last` |

### Stubs (not yet implemented — PRs welcome)

`Add-WUServiceManager`, `Disable-WURemoting`, `Enable-WURemoting`, `Get-WUApiVersion`,
`Get-WUInstallerStatus`, `Get-WUJob`, `Get-WULastResults`, `Get-WURebootStatus`,
`Get-WUServiceManager`, `Get-WUSettings`, `Hide-WindowsUpdate`, `Invoke-WUJob`,
`Remove-WindowsUpdate`, `Remove-WUServiceManager`, `Reset-WUComponents`, `Set-PSWUSettings`,
`Set-WUSettings`, `Show-WindowsUpdate`, `Update-WUModule`

---

## Implementation Notes

- `Get-WindowsUpdate` skips the `Listing...` header line emitted by `apt list --upgradable 2>/dev/null`
- `Get-WUHistory` parses `/var/log/dpkg.log` and returns entries sorted newest-first
- `Install-WindowsUpdate -RecursiveInclude` uses `apt-get dist-upgrade` for full dependency resolution
- The module throws a descriptive error if loaded on Windows (Linux-only guard in `.psm1`)
- Output objects use `[PSCustomObject]` to match PSWindowsUpdate property shapes

---

## Version History

| Version | Date | Notes |
|---|---|---|
| 0.1.0 | 2026-05-08 | Initial release: Get-WindowsUpdate, Install-WindowsUpdate, Get-WUHistory + 19 stubs |

---

## License

[GNU General Public License v3.0](LICENSE)
