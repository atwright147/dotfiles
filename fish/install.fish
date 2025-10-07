#!/usr/bin/env fish

rm -rf ~/.config/fish
ln -s (pwd) ~/.config/fish
rm -f ~/.gitconfig
ln -s (realpath (pwd)/../gitconfig) ~/.gitconfig

# install Oh My Posh (same command can be used to update too)
# curl -s https://ohmyposh.dev/install.sh | bash -s &
# wait
# echo "oh-my-posh installed successfully!"
# echo "Close this terminal, open a new one, then run the following command to install a nerd font:"
set_color yellow && echo "oh-my-posh font install firacode"
