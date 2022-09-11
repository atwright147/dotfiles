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
