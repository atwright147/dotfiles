#!/usr/bin/env fish

# Get the absolute path to the dotfiles directory
set dotfiles_dir (dirname (realpath (status --current-filename)))
set fish_dir (realpath (status --current-filename | xargs dirname))

rm -rf ~/.config/fish
ln -s "$fish_dir" ~/.config/fish
rm -f ~/.gitconfig
ln -s "$dotfiles_dir/gitconfig" ~/.gitconfig

# install Oh My Posh (same command can be used to update too)
# curl -s https://ohmyposh.dev/install.sh | bash -s &
# wait
# echo "oh-my-posh installed successfully!"
# echo "Close this terminal, open a new one, then run the following command to install a nerd font:"
# set_color yellow && echo "oh-my-posh font install firacode"
