# https://conradtheprogrammer.medium.com/save-your-powershell-profile-in-your-dotfiles-repo-8ec723532934

New-Item -Path $profile -ItemType SymbolicLink -Value (Get-Item ".\Microsoft.PowerShell_profile.ps1").FullName -Force
