# Check for updates if a certain number of hours have passed
source $HOME/.dotfiles/scripts/check-for-update.zsh

# Specific sources for DietPi (a Linux OS for RaspberryPi)
source $HOME/.dotfiles/scripts/_dietPi.zsh

# Antigen plugin manager
source $HOME/.antigen/antigen.zsh

# Use oh-my-zsh
antigen use oh-my-zsh

# Bundles
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

# Aliases
alias rm="echo 'Use \"gio trash\" instead of \"rm\" to be able to restore files.'; rm -iv"

# Allow git operations on select dotfiles in user's home
alias dotfiles="/usr/bin/git --git-dir=${HOME}/.dotfiles/.gitrepo --work-tree=${HOME}"

# Update dotfiles
alias dotfiles-update='~/.dotfiles/scripts/update.zsh'

[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

if [[ $OSTYPE == 'darwin'* ]]; then
    source ~/.docker/init-zsh.sh || true
fi

if [ -e /home/rubenjs/.nix-profile/etc/profile.d/nix.sh ]; then
    . /home/rubenjs/.nix-profile/etc/profile.d/nix.sh
fi

export DOCKER_BUILDKIT=1
export COMPOSE_DOCKER_CLI_BUILD=1

export POSTGRES_HOME="/usr/local/opt/postgresql@15/bin"
export PATH="$POSTGRES_HOME:$PATH"

export PNPM_HOME="/home/rubenjs/.local/share/pnpm"
case ":$PATH:" in
  *":$PNPM_HOME:"*) ;;
  *) export PATH="$PNPM_HOME:$PATH" ;;
esac

