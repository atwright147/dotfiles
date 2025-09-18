function git -d "Use hub if available, otherwise fallback to git"
  if type -q hub
    hub $argv
  else
    git $argv
  end
end
