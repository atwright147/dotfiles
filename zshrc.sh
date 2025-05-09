export LANGUAGE="en_GB.UTF8"
export LANG="en_GB.UTF8"
export LC_CTYPE="en_GB.UTF-8"
export LC_ALL="en_GB.UTF-8"
export TERM="xterm-256color"

# Check if zplug is installed
if [[ ! -d ~/.zplug ]]; then
	git clone https://github.com/zplug/zplug ~/.zplug
	source ~/.zplug/init.zsh && zplug update --self
fi

if [ -f ~/.env ]; then
	source ~/.env
	echo "Environment file loaded."
fi

# Essential
source ~/.zplug/init.zsh

# Sources
if [ -f ~/.iterm2_shell_integration.`basename $SHELL` ]; then
	source ~/.iterm2_shell_integration.`basename $SHELL`
fi
# if [ -f /usr/local/bin/virtualenvwrapper.sh ]; then
# 	source /usr/local/bin/virtualenvwrapper.sh
# fi

# FROM: https://dustri.org/b/my-zsh-configuration.html
##
# Completion
##
autoload -Uz compinit
compinit
zmodload -i zsh/complist        
setopt hash_list_all            # hash everything before completion
setopt completealiases          # complete alisases
setopt always_to_end            # when completing from the middle of a word, move the cursor to the end of the word    
setopt complete_in_word         # allow completion from within a word/phrase
setopt correct                  # spelling correction for commands
setopt list_ambiguous           # complete as much of a completion until it gets ambiguous.

zstyle ':completion::complete:*' use-cache on               # completion caching, use rehash to clear
zstyle ':completion:*' cache-path ~/.zsh/cache              # cache path
zstyle ':completion:*' matcher-list '' 'm:{a-z}={A-Z}' 'm:{a-zA-Z}={A-Za-z}' 'r:|[._-]=* r:|=* l:|=*'
zstyle ':completion:*' menu select                          # menu if nb items > 2
zstyle ':completion:*' list-colors ${(s.:.)LS_COLORS}       # colorz !
zstyle ':completion:*::::' completer _expand _complete _ignored _approximate # list of completers to use

# sections completion !
zstyle ':completion:*' verbose yes
zstyle ':completion:*:descriptions' format $'\e[00;34m%d'
zstyle ':completion:*:messages' format $'\e[00;31m%d'
zstyle ':completion:*' group-name ''
zstyle ':completion:*:manuals' separate-sections true

zstyle ':completion:*:processes' command 'ps -au$USER'
zstyle ':completion:*:*:kill:*' menu yes select
zstyle ':completion:*:kill:*' force-list always
zstyle ':completion:*:*:kill:*:processes' list-colors "=(#b) #([0-9]#)*=29=34"
zstyle ':completion:*:*:killall:*' menu yes select
zstyle ':completion:*:killall:*' force-list always
users=(`whoami` root)           # because I don't care about others
zstyle ':completion:*:*:kill:*:processes' list-colors '=(#b) #([0-9]#)*=0=01;31'
zstyle ':completion:*:kill:*' command 'ps -u $users -o pid,%cpu,tty,cputime,cmd'

compdef g=git

if [ -f /usr/local/share/zsh/site-functions/_aws ]; then
	source /usr/local/share/zsh/site-functions/_aws
fi



DISABLE_AUTO_TITLE="true"

setopt menu_complete

# History
HISTFILE=~/.zsh_history         # where to store zsh config
HISTSIZE=1024                   # big history
SAVEHIST=1024                   # big history
setopt append_history           # append
setopt hist_ignore_all_dups     # no duplicate
unsetopt hist_ignore_space      # ignore space prefixed commands
setopt hist_reduce_blanks       # trim blanks
setopt hist_verify              # show before executing history commands
setopt inc_append_history       # add commands as they are typed, don't wait until shell exit 
setopt share_history            # share hist between sessions
setopt bang_hist                # !keyword

# Settings
setopt auto_cd                  # if command is a path, cd into it
setopt auto_remove_slash        # self explicit
setopt chase_links              # resolve symlinks
setopt correct                  # try to correct spelling of commands
setopt extended_glob            # activate complex pattern globbing
setopt glob_dots                # include dotfiles in globbing
setopt print_exit_value         # print return value if non-zero
unsetopt beep                   # no bell on error
unsetopt bg_nice                # no lower prio for background jobs
unsetopt clobber                # must use >| to truncate existing files
unsetopt hist_beep              # no bell on error in history
unsetopt hup                    # no hup signal at shell exit
unsetopt ignore_eof             # do not exit on end-of-file
unsetopt list_beep              # no bell on ambiguous completion
unsetopt rm_star_silent         # ask for confirmation for `rm *' or `rm path/*'

# Set terminal title
#print -Pn "\e]0; %n@%M: %~\a"
#print -Pn "\e]0;\a"

set-window-title() {
	window_title="\e]0;${${PWD/#"$HOME"/~}/projects/p}\a"
	#window_title="\e]0;\a"
	echo -ne "$window_title"
}

PR_TITLEBAR=''
set-window-title
precmd() {
	set-window-title
}


# Includes
source ~/dotfiles/aliases.sh
source ~/dotfiles/functions.sh

# Node
export NPM_PACKAGES="${HOME}/.npm-packages"
export NODE_PATH="${NPM_PACKAGES}/lib/node_modules:${NODE_PATH}"  
export PATH="${NPM_PACKAGES}/bin:${PATH}"

# Paths
# export PATH="/usr/local/sbin:$PATH"
# export PATH="$MAVEN_HOME/bin:$PATH"
# export PATH=$HOME"/bin:$PATH"
export PATH="/usr/local/bin:$PATH"
export PATH="/opt/local/bin:$PATH"  # to enable macports
export PATH="/usr/local/sbin:$PATH"
export PATH="/Applications/Parallels Desktop.app/Contents/MacOS:$PATH"

# Misc
export EDITOR="nano"
export VISUAL="code"
export ACKRC=".ackrc"  # allow .ackrc files in any folder (https://edoceo.com/cli/ack)

# Make sure to use double quotes to prevent shell expansion
zplug "supercrabtree/k"
zplug "djui/alias-tips"
zplug "zsh-users/zsh-syntax-highlighting"
zplug "zsh-users/zsh-completions"
zplug "rupa/z", use:"*.sh"
zplug "felixr/docker-zsh-completion"
zplug "tj/burl", \
    from:github, \
    as:command, \
    rename-to:burl, \
    use:"*bin/burl"
zplug "plugins/ng", from:oh-my-zsh
zplug "favware/zsh-lerna"
zplug 'zplug/zplug', hook-build:'zplug --self-manage'


# History Substring Search
zplug "zsh-users/zsh-history-substring-search"
# OPTION 1: for most systems
zmodload zsh/terminfo
bindkey "$terminfo[kcuu1]" history-substring-search-up
bindkey "$terminfo[kcud1]" history-substring-search-down
# OPTION 2: for iTerm2 running on Apple MacBook laptops
zmodload zsh/terminfo
bindkey "$terminfo[cuu1]" history-substring-search-up
bindkey "$terminfo[cud1]" history-substring-search-down
# OPTION 3: for Ubuntu 12.04, Fedora 21, and MacOSX 10.9
bindkey '^[[A' history-substring-search-up
bindkey '^[[B' history-substring-search-down


# Theme
if [[ "$SYSTEM_USAGE" == home ]]; then
	# export TOOL_VERSION='node_version'
elif [[ "$SYSTEM_USAGE" == work ]]; then
	# export TOOL_VERSION='node_version'
	if [[ -f ~/.proxy ]]; then
		source ~/.proxy
	fi
	if [[ -f ~/proxy.env ]]; then
		source ~/proxy.env
	fi
fi

# Hidden macOS utilities
# The `stroke` utility
if [[ -d "/System/Library/CoreServices/Applications/Network Utility.app/Contents/Resources" ]]; then
	PATH="${PATH}:/System/Library/CoreServices/Applications/Network Utility.app/Contents/Resources"
fi
# The `airport` utility
if [[ -d "/System/Library/PrivateFrameworks/Apple80211.framework/Versions/Current/Resources" ]]; then
	PATH="${PATH}:/System/Library/PrivateFrameworks/Apple80211.framework/Versions/Current/Resources"
fi

if [[ -f ~/extras.sh ]]; then
	source ~/extras.sh
fi

PATH=${PATH}:$HOME/dotfiles/bin

if [ -d "$HOME/go/bin" ]; then
	PATH=${PATH}:$HOME/go/bin
fi

if [ -d "$HOME/sdks/flutter/bin" ]; then
	PATH=${PATH}:$HOME/sdks/flutter/bin
fi

# Ruby from Homebrew
if [ -d "/opt/homebrew/opt/ruby/bin" ]; then
	export PATH="/opt/homebrew/opt/ruby/bin:$PATH"
	export PATH="$(gem env gemdir)/bin:$PATH"
fi

# fix garish, unreadable green and yellow node segment colours
POWERLEVEL9K_NODE_VERSION_FOREGROUND="black"

# zplug "bhilburn/powerlevel9k", use:powerlevel9k.zsh-theme
zplug "romkatv/powerlevel10k", use:powerlevel10k.zsh-theme
POWERLEVEL9K_LEFT_PROMPT_ELEMENTS=(dir vcs)
POWERLEVEL9K_RIGHT_PROMPT_ELEMENTS=(status history time node_version virtualenv)
POWERLEVEL9K_SHORTEN_DIR_LENGTH=1
POWERLEVEL9K_SHORTEN_DELIMITER=""
POWERLEVEL9K_SHORTEN_STRATEGY="truncate_from_right"

export ZSH_PLUGINS_ALIAS_TIPS_TEXT='💡 '


# Add a bunch more of your favorite plugins!

# Install plugins that have not been installed yet
if ! zplug check --verbose; then
	printf "Install? [y/N]: "
	if read -q; then
		echo; zplug install
	else
		echo
	fi
fi

zplug load

eval "$(fnm env --use-on-cd)"


# Deno Version Manager
export DVM_DIR="$HOME/.dvm"
[ -f "$DVM_DIR/dvm.sh" ] && . "$DVM_DIR/dvm.sh"
[ -f "$DVM_DIR/bash_completion" ] && . "$DVM_DIR/bash_completion"


# pnpm
export PNPM_HOME="/Users/andy/Library/pnpm"
case ":$PATH:" in
  *":$PNPM_HOME:"*) ;;
  *) export PATH="$PNPM_HOME:$PATH" ;;
esac
# pnpm end

# Added by LM Studio CLI (lms)
export PATH="$PATH:/Users/andy/.lmstudio/bin"
