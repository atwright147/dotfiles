#!/usr/bin/env fish

rm -rf ~/.config/fish
ln -s (pwd) ~/.config/fish

# install Cargo (and Rust obvs)
curl https://sh.rustup.rs -sSf | sh
