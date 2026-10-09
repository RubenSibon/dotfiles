#!/usr/bin/env zsh

# git submodule only works from inside the work tree, which is the home directory
script=${0:A}
cd ~ || exit 1

# Repository settings; clones made by an older install script lack them
GIT_DOTFILES=(git --git-dir=$HOME/.dotfiles/.gitrepo)
# Fetch over HTTPS, so update checks need no SSH key; push over SSH
$GIT_DOTFILES remote set-url --push origin git@github.com:RubenSibon/dotfiles.git
# The work tree is the whole home directory: keep git's file watcher off it
$GIT_DOTFILES config core.fsmonitor false
# Refuse commits that would publish secrets or personal details
$GIT_DOTFILES config core.hooksPath ~/.dotfiles/hooks

# Pulling repository and submodule updates
# (--ff-only: when histories diverge, stop instead of merging conflict markers into live dotfiles)
before=$($GIT_DOTFILES rev-parse HEAD)
$GIT_DOTFILES --work-tree=$HOME pull --ff-only || exit 1

# zsh keeps running the version of this script it started with: when the pull
# changed it, start the new version, once
if [[ -z $DOTFILES_UPDATE_RESTARTED ]] &&
    ! $GIT_DOTFILES diff --quiet $before HEAD -- .dotfiles/scripts/update.zsh; then
    DOTFILES_UPDATE_RESTARTED=1 exec zsh $script
fi

$GIT_DOTFILES --work-tree=$HOME submodule update --init --recursive

# Missing system packages first: the steps below can use them
[[ $OSTYPE == darwin* ]] && ~/.dotfiles/scripts/update-macos.zsh

# Point the agents on this machine at the shared agent instructions,
# unless a machine already has its own instruction file
[[ -d ~/.claude && ! -e ~/.claude/CLAUDE.md ]] && print '@~/.dotfiles/agents/AGENTS.md' > ~/.claude/CLAUDE.md
for file in ~/.copilot/copilot-instructions.md ~/.config/zed/AGENTS.md; do
    [[ -d ${file:h} && ! -e $file ]] && ln -s ~/.dotfiles/agents/AGENTS.md $file
done

# Claude Code plugins from ~/.dotfiles/claude-plugins, where each is pinned to a
# reviewed commit (see the README before changing a pin)
if command -v claude > /dev/null; then
    echo "🤖 Installing/updating Claude Code plugins..."
    # Earlier versions of this script installed them from their own, unpinned
    # marketplaces; removing those also uninstalls the plugins that came from them
    grep -Eq '"(caveman|ponytail)"' ~/.claude/plugins/known_marketplaces.json 2> /dev/null &&
        for marketplace in caveman ponytail; do
            claude plugin marketplace remove $marketplace > /dev/null 2>&1
        done
    claude plugin marketplace add ~/.dotfiles/claude-plugins > /dev/null
    for plugin in caveman figma frontend-design ponytail typescript-lsp; do
        # install does nothing when the plugin is there; update follows a changed pin
        claude plugin install $plugin@dotfiles > /dev/null &&
            claude plugin update $plugin@dotfiles > /dev/null ||
            echo "Could not install or update the Claude Code plugin $plugin."
    done
    echo "✔ done installing/updating Claude Code plugins.\n"
fi

# Settings, keybindings and extensions for VSCodium and VS Code
zsh ~/.dotfiles/scripts/vscodium.zsh

# Install fzf (fuzzy finder)
if [ -x ~/.fzf/install ]; then
    echo "\n🤖 Installing/updating fuzzy finder (fzf)..."
    ~/.fzf/install --key-bindings --completion --no-update-rc
    echo "✔ done installing/updating fzf.\n"
else
    echo "fzf is not checked out. Not installing fzf."
fi

# Install Vim plugins
if command -v vim > /dev/null; then
    echo "🤖 Installing/updating Vundle plugins for Vim..."
    vim +PluginInstall +qall
    echo "✔ done installing/updating Vundle plugins.\n"
else
    echo "Vim is not installed. Not installing Vundle plugins."
fi

# Make zsh the login shell, unless it already is. On macOS the system's /bin/zsh:
# it is always listed in /etc/shells and keeps working when Homebrew breaks.
if [[ $SHELL != */zsh ]]; then
    if [[ $OSTYPE == darwin* ]]; then
        chsh -s /bin/zsh
    else
        chsh -s $(command -v zsh)
    fi
fi

echo "🤖 Dotfiles install/update is done!\n\nOpen a new terminal or run 'exec zsh' to load the changes."
