if [[ -f "/boot/dietpi" ]]; then
    export PATH=/usr/bin:/boot/dietpi:/bin:/usr/sbin:/sbin:$PATH

    if [[ -f "/etc/bashrc.d/dietpi.bash" ]]; then
        source /etc/bashrc.d/dietpi.bash
    fi
fi

source $HOME/.antigen/antigen.zsh

# Use oh-my-zsh
antigen use oh-my-zsh

# Bundles
antigen bundle git
antigen bundle ssh-agent
antigen bundle command-not-found
antigen bundle zsh-users/zsh-syntax-highlighting
antigen bundle zsh-users/zsh-completions
antigen bundle zsh-users/zsh-autosuggestions

# Theme
antigen theme ys

HISTFILE=~/.histfile
HISTSIZE=1000
SAVEHIST=1000

bindkey -v

zstyle :compinstall filename '/home/ruben/.zshrc'

autoload -Uz compinit
compinit

if command -v git > /dev/null; then
    alias config="/usr/bin/git --git-dir=${HOME}/.dotfiles/ --work-tree=${HOME}"
fi

antigen apply
