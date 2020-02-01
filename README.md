# Andy's Dotfiles

A set of custom dotfiles created to help me understand ZSH and stop relying on Oh-My-ZSH / Prezto.

It is designed around zplug. When you first start up your terminal with the custom .zshrc file it *should* install zplug, then install all of it's own dependencies.

I am trying to create a system similar to the way npm handles dependencies.

## Installation

<ol>
<li>Get the repo

```sh
git clone <url_for_this_repo>
```
</li>

<li>Switch to zsh shell:

```sh
chsh -s /bin/zsh
```
</li>

<li>Install the dot files

```sh
cd path/to/dotfiles
./install.sh
```
</li>
</ol>

## Mac Setup

### Add spacers into Doc

```sh
defaults write com.apple.dock persistent-apps -array-add '{"tile-type"="small-spacer-tile";}';
killall Dock
```
