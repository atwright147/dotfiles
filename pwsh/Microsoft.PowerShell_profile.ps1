oh-my-posh init pwsh | Invoke-Expression
fnm env --use-on-cd | Out-String | Invoke-Expression

Import-Module -Name Terminal-Icons
Import-Module -Name PSReadline
Import-Module -Name Z
Import-Module -Name npm-completion

Set-PSReadLineKeyHandler -Key UpArrow -Function HistorySearchBackward
Set-PSReadLineKeyHandler -Key DownArrow -Function HistorySearchForward
Set-PSReadLineKeyHandler -Key Tab -Function MenuComplete

# Set-PSReadLineOption -PredictionSource History
# Set-PSReadLineOption -PredictionViewStyle ListView

# open Fork https://git-fork.com/
if ($env:OS -match 'Windows_NT') {
    function Invoke-Fork {
        param($Path)
        $forkExe = $env:LOCALAPPDATA + '\Fork\Fork.exe'
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
