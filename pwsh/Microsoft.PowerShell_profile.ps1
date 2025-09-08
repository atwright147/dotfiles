oh-my-posh init pwsh --config ~/dotfiles/prompt.omp.json | Invoke-Expression
fnm env --use-on-cd | Out-String | Invoke-Expression

Import-Module -Name Terminal-Icons
Import-Module -Name PSReadline
Import-Module -Name Npm-Completion

Set-PSReadLineKeyHandler -Key UpArrow -Function HistorySearchBackward
Set-PSReadLineKeyHandler -Key DownArrow -Function HistorySearchForward
Set-PSReadLineKeyHandler -Key Tab -Function MenuComplete
Set-PSReadLineOption -HistorySearchCursorMovesToEnd

# Set-PSReadLineOption -PredictionSource History
# Set-PSReadLineOption -PredictionViewStyle ListView

# open Fork https://git-fork.com/
if ($env:OS -match 'Windows_NT') {
    Function Invoke-Fork {
        param($Path)
        $forkExe = "$env:LOCALAPPDATA\Fork\Fork.exe"
        if (-not $Path) {
            & $forkExe
        }
        else {
            $absolutePath = Resolve-Path $Path
            & $forkExe $absolutePath
        }
    }
    Set-Alias fork Invoke-Fork
}

# https://stackoverflow.com/a/62936536/633056
Set-PSReadLineOption -AddToHistoryHandler {
    param($command)
    if ($command -eq 'cls') {
        return $false
    }
    # Add any other checks you want
    return $true
}

Function Invoke-Ls {
    param(
        [Parameter(ValueFromRemainingArguments=$true)]
        [string[]]$Arguments
    )

    if (Get-Command eza -ErrorAction SilentlyContinue) {
        & eza @Arguments
    } else {
        # Convert common ls flags to Get-ChildItem parameters
        $gciParams = @{}
        $paths = @()

        foreach ($arg in $Arguments) {
            switch ($arg) {
                '-l' {
                    # -l flag: show detailed list (handled by Format-Table later)
                    $gciParams['Force'] = $false  # placeholder
                }
                '-a' {
                    # -a flag: show hidden files
                    $gciParams['Force'] = $true
                }
                '-la' {
                    # -la flag: show detailed list with hidden files
                    $gciParams['Force'] = $true
                }
                default {
                    # Treat as path if it doesn't start with -
                    if (-not $arg.StartsWith('-')) {
                        $paths += $arg
                    }
                }
            }
        }

        # If no paths specified, use current directory
        if ($paths.Count -eq 0) {
            $paths = @('.')
        }

        # Get the items
        $items = Get-ChildItem @gciParams -Path $paths

        # Check if we need detailed output (like ls -l)
        if ($Arguments -contains '-l' -or $Arguments -contains '-la') {
            $items | Format-Table Mode, LastWriteTime, Length, Name -AutoSize
        } else {
            $items
        }
    }
}
Set-Alias ls Invoke-Ls

# Create functions for the different ls variants
Function Invoke-LsList {
    Invoke-Ls -l
}

Function Invoke-LsListAll {
    Invoke-Ls -la
}

# Set aliases to these functions
Set-Alias l Invoke-LsList
Set-Alias la Invoke-LsListAll

# Create directory and change into it
Function Invoke-TakeDirectory {
    param(
        [Parameter(Mandatory=$true)]
        [string]$Path
    )

    if (-not $Path) {
        Write-Host "Usage: tkdir <directory>"
        return
    }

    New-Item -ItemType Directory -Path $Path -Force
    Set-Location $Path
}
Set-Alias tkdir Invoke-TakeDirectory

Invoke-Expression (& { (zoxide init powershell | Out-String) })
