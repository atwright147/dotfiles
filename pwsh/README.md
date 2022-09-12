# PowerShell

## Install Windows Terminal

```powershell
winget install Microsoft.WindowsTerminal
```

## Install **PowerShell v7.***

```powershell
winget install Microsoft.PowerShell
```

## Set PowerShell 7 as Default Profile

In Microsoft Terminal open `Settings > Startup` and, under Default profile, select `PowerShell`

## Install Modules

Install the following Modules with `Install-Module -name <module>`

- `npm-completion`
- `z`

## Install PSReadline

Needs to be forced as PSReadline is also bundled in PowerShell but we want a newer version

```powershell
Install-Module -Name PSReadLine -AllowClobber -Force
```

## Install **oh-my-posh**

```powershell
winget install JanDeDobbeleer.OhMyPosh
```
