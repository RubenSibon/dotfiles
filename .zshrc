# Make DietPi distro play nice with zsh as it relies on bash
# Comment out or remove below two lines if you do not use DietPi
source $HOME/.dotfiles/scripts/_misc.zsh
enable_on_dietpi

# Antigen plugin manager
# source $HOME/.antigen/antigen.zsh
source $HOME/.antigen/bin/antigen.zsh

# Use oh-my-zsh
antigen use oh-my-zsh

# Bundles
antigen bundle git
antigen bundle ssh-agent
antigen bundle command-not-found
antigen bundle zsh-users/zsh-syntax-highlighting
antigen bundle zsh-users/zsh-completions
antigen bundle zsh-users/zsh-autosuggestions
antigen bundle lukechilds/zsh-nvm
antigen bundle chrisands/zsh-yarn-completions
antigen bundle pip

# Theme
antigen theme ys

# Apply Antigen configuration
antigen apply

# General zsh configuration
HISTFILE=~/.histfile
HISTSIZE=2000
SAVEHIST=1000

setopt HIST_IGNORE_ALL_DUPS
setopt HIST_SAVE_NO_DUPS
setopt HIST_REDUCE_BLANKS
setopt INC_APPEND_HISTORY_TIME
setopt EXTENDED_HISTORY

bindkey -v

zstyle :compinstall filename "${HOME}/.zshrc"

autoload -Uz compinit
compinit

# Allow git operations on select dotfiles in user's home
alias dotfiles="/usr/bin/git --git-dir=${HOME}/.dotfiles/.gitrepo --work-tree=${HOME}"

# Update dotfiles
alias dotfiles-update='~/.dotfiles/scripts/update.zsh'

[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh
