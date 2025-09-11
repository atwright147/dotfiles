function g -d "Git shortcut: run 'git status' with no args, or 'git <args>' with args"
  if test (count $argv) -gt 0
    git $argv
  else
    git status --short
  end
end
