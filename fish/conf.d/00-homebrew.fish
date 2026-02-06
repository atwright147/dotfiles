# Add Homebrew to PATH if it exists
if test -f /opt/homebrew/bin/brew
  set -gx PATH /opt/homebrew/bin $PATH
end
