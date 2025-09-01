if status is-interactive
  # Commands to run in interactive sessions can go here
end

# Added by LM Studio CLI (lms)
set -gx PATH $PATH "$HOME/.lmstudio/bin"
set -gx PATH $PATH "$HOME/.local/bin" $PATH
set -gx PATH $PATH "$HOME/.cargo/bin" $PATH

if command -v oh-my-posh > /dev/null
  oh-my-posh init fish --config ~/dotfiles/prompt.omp.json | source
else
  echo "oh-my-posh not found, please install it from https://ohmyposh.dev/docs/installation/linux"
end

if command -v zoxide > /dev/null
  zoxide init fish | source
else
  echo "zoxide not found, please install it from https://github.com/ajeetdsouza/zoxide"
end
