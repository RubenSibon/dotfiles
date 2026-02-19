# Check for updates if a certain number of hours have passed
source $HOME/.dotfiles/scripts/check-for-update.zsh

#
# ZSH configuration with Antigen plugin manager.
#

# Antigen plugin manager
source $HOME/.antigen/antigen.zsh

# Use oh-my-zsh
antigen use oh-my-zsh

# ZSH Bundles
# -- essential
antigen bundle ssh-agent
antigen bundle command-not-found
antigen bundle zsh-users/zsh-syntax-highlighting
antigen bundle clarketm/zsh-completions
antigen bundle zsh-users/zsh-autosuggestions
# -- development
antigen bundle git
antigen bundle greymd/docker-zsh-completion
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

#
# Custom configurations
#

# Source fzf configuration if it exists
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

# Source Docker configuration if it exists (only on macOS)
if [[ $OSTYPE == 'darwin'* ]]; then
    source ~/.docker/init-zsh.sh || true
fi

#
# Aliases
#

# Warn users to use "gio trash" instead of "rm" to be able to restore files.
alias rm="echo 'Use \"gio trash\" instead of \"rm\" to be able to restore files.'; rm -iv"

# Allow git operations on select dotfiles in user's home
alias dotfiles="$(which git) --git-dir=${HOME}/.dotfiles/.gitrepo --work-tree=${HOME}"

# Update dotfiles
alias dotfiles-update='~/.dotfiles/scripts/update.zsh'

#
# Export constants and add to PATH
#

export DOCKER_BUILDKIT=1
export COMPOSE_DOCKER_CLI_BUILD=1
