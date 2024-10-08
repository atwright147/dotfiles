# PowerShell

## Install Windows Terminal

```powershell
winget install Microsoft.WindowsTerminal
```

## Install **PowerShell v7.***

```powershell
winget install Microsoft.PowerShell
```

## Install `fnm` (Fast Node Manager)

Follow the instructions in the [Fnm readme](https://conradtheprogrammer.medium.com/save-your-powershell-profile-in-your-dotfiles-repo-8ec723532934)

## Set PowerShell 7 as Default Profile

In Microsoft Terminal open `Settings > Startup` and, under Default profile, select `PowerShell`

## Automatic Setup

Automaticall install all modules

```pwsh
sudo .\Setup.ps1
```

## Upgrade PSReadline (cannot be done automatically)

1. Open Windows Terminal
1. Open an Admin **cmd** session (not PowerShell)
1. Run the following

```pwsh
pwsh -noprofile -command "Install-Module PSReadLine -Force -SkipPublisherCheck -scope allusers"
```

## Manual Setup

### Install Modules

Install the following Modules with `Install-Module -name <module>`

- `Terminal-Icons`
- `Npm-Completion`
- `Z`

### Install PSReadline

Needs to be forced as PSReadline is also bundled in PowerShell but we want a newer version

```powershell
Install-Module -Name PSReadLine -AllowClobber -Force
```

## Install Profile file

Run the following to find out where your profile should be copied to:

```powershell
$profile
```

Copy `Microsoft.PowerShell_profile.ps1` to that location

Reload your profile

```powershell
. $profile
```

## Install **oh-my-posh**

```powershell
winget install JanDeDobbeleer.OhMyPosh
```

## Microsoft Terminal

### Settings

Add the following to the terminal actions settings to allow using `Ctrl+K` 

```json
"actions": [
    ...
    { 
        "command": 
        { 
            "action": "sendInput", "input": "cls\r" 
        }, 
        "keys": "ctrl+k"
    },
    ...
]
```
