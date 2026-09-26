# Check for updates if a certain number of hours have passed
source $HOME/.dotfiles/scripts/check-for-update.zsh

#
# ZSH configuration with Antigen plugin manager.
#

# Antigen plugin manager (a git submodule; skipped when it is not checked out)
if [[ -r $HOME/.antigen/antigen.zsh ]]; then
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

  # Apply Antigen configuration (this also runs compinit, at the first prompt)
  antigen apply
fi

# General zsh configuration
HISTFILE=~/.histfile

# oh-my-zsh sets the history size and shares history between terminals (SHARE_HISTORY)
setopt HIST_IGNORE_ALL_DUPS
setopt HIST_SAVE_NO_DUPS
setopt HIST_REDUCE_BLANKS
setopt EXTENDED_HISTORY

bindkey -v

#
# Custom configurations
#

# Source fzf configuration if it exists
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

#
# Aliases
#

# Allow git operations on select dotfiles in user's home
alias dotfiles='git --git-dir=$HOME/.dotfiles/.gitrepo --work-tree=$HOME'

# Update dotfiles
alias dotfiles-update='~/.dotfiles/scripts/update.zsh'

# Git
alias git-checkout-develop='git checkout develop'
alias git-checkout-prev='git checkout -'
alias git-clean-ignored='git clean -d -X -f'
alias git-gc-prune-now='git gc --prune=now'
alias git-log-3='git log -3'
alias git-log-oneline-decorate-10='git log --oneline --decorate -n 10'
alias git-prune-merged-branches='git branch --merged | grep -Ev "^[*+]|^  (main|master|develop)$" | xargs -n 1 git branch -d'
alias git-pull-and-merge-develop='git pull && git pull origin develop'
alias git-pull-develop-and-push='git pull origin develop && git push'
alias git-pull-rebase='git pull --rebase'
alias git-push-force-with-lease='git push origin --force-with-lease'
alias git-rebase-abort='git rebase --abort'
alias git-rebase-continue='git rebase --continue'
alias git-rebase-develop='git rebase develop'
alias git-remote-prune-origin='git remote prune origin'
alias git-sync='git fetch --prune; git pull'

#
# Export constants and add to PATH
#

# pnpm
export PNPM_HOME="$HOME/.local/share/pnpm"
case ":$PATH:" in
  *":$PNPM_HOME/bin:"*) ;;
  *) export PATH="$PNPM_HOME/bin:$PATH" ;;
esac
# pnpm end

# OS-specific configuration
[[ $OSTYPE == darwin* ]] && source ~/.dotfiles/zsh/macos.zsh
[[ -f /etc/debian_version ]] && source ~/.dotfiles/zsh/debian.zsh

export PATH="$HOME/.local/bin:$PATH"

if command -v nvim >/dev/null 2>&1; then
  export EDITOR=nvim
  export VISUAL=nvim
elif command -v vim >/dev/null 2>&1; then
  export EDITOR=vim
  export VISUAL=vim
elif command -v nano >/dev/null 2>&1; then
  export EDITOR=nano
  export VISUAL=nano
fi

# Machine-specific configuration, not tracked in the dotfiles repo
if [[ -r ~/.zshrc.local ]]; then
  source ~/.zshrc.local
fi
