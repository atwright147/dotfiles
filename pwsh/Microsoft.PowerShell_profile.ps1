oh-my-posh init pwsh | Invoke-Expression
fnm env --use-on-cd | Out-String | Invoke-Expression

Import-Module -Name Terminal-Icons
Import-Module -Name PSReadline
Import-Module -Name Z
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

Set-Alias ls -Value eza.exe
