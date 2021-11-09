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

### Add spacers into Dock

```sh
defaults write com.apple.dock persistent-apps -array-add '{"tile-type"="small-spacer-tile";}';
killall Dock
```

## Notes

### Locales

As these dotfiles are intended for a UK user, you might get errors about missing locales.

```
perl: warning: Please check that your locale settings are supported and installed on your system
```

To fix this (http://askubuntu.com/a/227513):

```sh
# Generate a locale
sudo locale-gen "en_GB.UTF-8"

# Set the system up to use the new locale
sudo dpkg-reconfigure locales
```

### Stylish

- [StackOverflow full screen](https://userstyles.org/styles/172637/stackoverflow-simply-wide)
- [Github Wide](https://userstyles.org/styles/108591/github-wide)
