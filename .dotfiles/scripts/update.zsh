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
# Sign the commits made here, so that the pull below can verify them on the next
# machine. The key itself is machine-specific: it belongs in ~/.gitconfig.local.
$GIT_DOTFILES config commit.gpgsign true

# Pulling repository and submodule updates
# (--ff-only: when histories diverge, stop instead of merging conflict markers into live dotfiles)
# (--verify-signatures: everything past this line runs what the pull brought in. This
#  script re-execs itself below, and then runs vscodium.zsh, the plugin installers and
#  the submodules' own install scripts. So a commit that no key in this machine's
#  keyring vouches for must not get that far: whoever can write to the remote would
#  otherwise have a shell on every machine at its next update.)
before=$($GIT_DOTFILES rev-parse HEAD)
pull=(pull --ff-only)
# For a machine that does not have the public key yet: DOTFILES_SKIP_VERIFY=1 dotfiles-update
[[ -n $DOTFILES_SKIP_VERIFY ]] || pull+=(--verify-signatures)
if ! $GIT_DOTFILES --work-tree=$HOME $pull; then
    echo "\nupdate: the pull was refused, so nothing below it ran."
    echo "If a missing or unverifiable signature is the reason, import the public key"
    echo "(gpg --recv-keys <id>) and mark it trusted, or run the update once with"
    echo "DOTFILES_SKIP_VERIFY=1 after reading the incoming commits yourself."
    exit 1
fi

# zsh keeps running the version of this script it started with: when the pull
# changed it, start the new version, once
if [[ -z $DOTFILES_UPDATE_RESTARTED ]] &&
    ! $GIT_DOTFILES diff --quiet $before HEAD -- .dotfiles/scripts/update.zsh; then
    DOTFILES_UPDATE_RESTARTED=1 exec zsh $script
fi

$GIT_DOTFILES --work-tree=$HOME submodule update --init --recursive

# Nix outside NixOS: an interactive shell puts it and its profile on PATH, but
# this script is not one. The profile goes on PATH even before its first install.
nix_env=/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh
[[ -r $nix_env ]] && ! command -v nix > /dev/null && source $nix_env

# Missing system packages first: the steps below can use them
[[ $OSTYPE == darwin* ]] && ~/.dotfiles/scripts/update-macos.zsh
[[ $OSTYPE == linux* && ! -e /etc/NIXOS ]] && ~/.dotfiles/scripts/update-nix.zsh

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
