function clear --description "alias clear=clear && printf '\\e[3J'"
  command clear && printf '\e[3J' $argv
end
