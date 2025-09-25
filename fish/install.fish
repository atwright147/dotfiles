#!/usr/bin/env fish

rm -rf ~/.config/fish
ln -s (pwd) ~/.config/fish

# install Oh My Posh (same command can be used to update too)
curl -s https://ohmyposh.dev/install.sh | bash -s &&\
oh-my-posh install font firacode
