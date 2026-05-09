# Update.Linux

[![Pester Tests](https://github.com/peppekerstens/Update.Linux/actions/workflows/pester.yml/badge.svg)](https://github.com/peppekerstens/Update.Linux/actions/workflows/pester.yml)

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

## CI / Testing

Tested across 5 Linux distributions in containers:

| Distro | Image |
|---|---|
| Ubuntu 24.04 | `ghcr.io/peppekerstens/testinfra:ubuntu-24.04` |
| Debian 12 | `ghcr.io/peppekerstens/testinfra:debian-12` |
| Fedora 40 | `ghcr.io/peppekerstens/testinfra:fedora-40` |
| openSUSE Tumbleweed | `ghcr.io/peppekerstens/testinfra:opensuse-tumbleweed` |
| Arch Linux | `ghcr.io/peppekerstens/testinfra:arch-latest` |

Run locally with:

```powershell
# From the repo root
docker compose -f docker-compose.test.yml up --abort-on-container-exit
```

GitHub Actions runs the same matrix on every push — see `.github/workflows/pester.yml`.
---

## Version history

| Version | Date | Notes |
|---|---|---|
| 0.2.0 | 2026-05-08 | Renamed core functions to Linux-native names; added PSWindowsUpdate aliases for parity |
| 0.1.0 | 2026-05-08 | Initial release |

---

## How we built this

### Why this module exists

PSWindowsUpdate is the de-facto standard for Windows update management in PowerShell automation. It's widely used in scripts, runbooks, and DSC configurations. None of it works on Linux because `apt` is a completely different beast. The goal of `Update.Linux` is to let those same scripts run unmodified on Linux — `Get-WindowsUpdate` becomes an alias, `Install-WindowsUpdate` triggers `apt-get upgrade`. No platform branching required.

### Tool choices

**`apt list --upgradable`** lists available updates in a parseable format. The output is consistent enough to extract package name, version, and repository source from each line. We use `2>/dev/null` to suppress the "Listing..." progress noise that `apt` emits to stderr.

**`apt-get upgrade`** (not `apt upgrade`) is used for installs because `apt-get` has a stable, scriptable interface and reliable exit codes. `apt` is designed for interactive use and its output format can change between releases. `apt-get dist-upgrade` is used when `-RecursiveInclude` is passed — this matches the PSWindowsUpdate behavior of pulling in new dependencies.

**`/var/log/dpkg.log`** is the most reliable source for package history. It logs every install, upgrade, and remove with timestamps in a consistent format. `Get-LinuxUpdateHistory` parses this file, filters for `install` and `upgrade` actions, and sorts newest-first.

### Key gotchas

**The "Listing..." header line.** `apt list --upgradable 2>/dev/null` always emits a `Listing...` line before the package list. If you pipe straight into a parser without filtering it out, you get a broken first object. The fix is a `Where-Object { $_ -notmatch '^Listing' }` before parsing. Easy fix, annoying to discover.

**PSWindowsUpdate alias naming.** The Windows cmdlets are called `Get-WindowsUpdate`, `Install-WindowsUpdate`, `Get-WUHistory`. The aliases need to match exactly — including the `WU` prefix variations. Some PSWindowsUpdate cmdlets use `Get-WU*` rather than `Get-Windows*` (e.g. `Get-WUHistory`, `Get-WUApiVersion`). The alias table has to cover both patterns.

**dpkg.log action verbs.** dpkg.log uses `install`, `upgrade`, `remove`, `purge`, and `configure` as action words. `Get-LinuxUpdateHistory` filters for `install` and `upgrade` only — `configure` is a post-install step that would otherwise double-count every install.

**Reboot detection.** `Install-LinuxUpdate -AutoReboot` checks `/var/run/reboot-required` after the upgrade. This file is created by `apt-get` when a reboot is needed (kernel updates, etc.). If present and `-AutoReboot` was passed, the module calls `shutdown -r now`.

### Naming strategy

Linux-native function names (`Get-LinuxUpdate`, `Install-LinuxUpdate`, `Get-LinuxUpdateHistory`) are the actual implementations. PSWindowsUpdate names are aliases pointing at them. This means `Get-Command Get-WindowsUpdate` shows the alias, and the underlying code lives in a sensibly named function. It also means you can use the Linux-native names in new scripts and be explicit about platform intent.

### Test approach

Tests use Pester 5.2+ with `BeforeDiscovery` for platform detection. On Windows, all test blocks are skipped. On WSL2/Linux, the full suite runs. The tests mock `apt list --upgradable` and `dpkg.log` parsing rather than running actual apt commands — keeping tests deterministic and not requiring sudo. Examples are tested via `Examples\Examples.Tests.ps1` which runs each example script and verifies it doesn't throw.

---

## License

[GNU General Public License v3.0](LICENSE)
