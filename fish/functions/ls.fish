function ls
  if type -q eza
    eza $argv
  else
    command ls $argv
  end
end
