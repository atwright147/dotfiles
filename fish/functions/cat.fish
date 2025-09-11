function cat -d "Use bat if available, otherwise fallback to cat"
  if command -v bat >/dev/null 2>&1
    # Use bat with useful options:
    # --color=always: Force color output even when piped
    # --style=numbers,changes,header,snip: Show line numbers, git changes, file header, and whitespace
    # --paging=never: Don't use a pager for small files (you can pipe to less if needed)
    # --tabs=2: Set tab width to 2 spaces
    bat --color=always --style=numbers,changes,header,snip --paging=never --tabs=2 $argv
  else
    # Fallback to regular cat
    command cat $argv
  end
end
