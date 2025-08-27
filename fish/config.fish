if status is-interactive
  # Commands to run in interactive sessions can go here
end

# Added by LM Studio CLI (lms)
set -gx PATH $PATH /Users/andy/.lmstudio/bin
set -gx PATH $PATH "$HOME/.local/bin" $PATH
set -gx PATH $PATH "$HOME/.cargo/bin" $PATH

if command -v oh-my-posh > /dev/null
  oh-my-posh init fish --config ~/dotfiles/prompt.omp.json | source
end

if command -v zoxide > /dev/null
  zoxide init fish | source
end
