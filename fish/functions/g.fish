
function g -d "Git shortcut: run 'git status' with no args, or 'git <args>' with args. Uses hub if available."
  if test (count $argv) -gt 0
    if type -q hub
      hub $argv
    else
      git $argv
    end
  else
    git status --short
  end
end
