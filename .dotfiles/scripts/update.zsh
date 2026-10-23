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
# (Everything past this point runs what the fetch brought in: this script re-execs
#  itself below, and then runs vscodium.zsh, the plugin installers and the
#  submodules' own install scripts. So a commit that no trusted key in this
#  machine's keyring vouches for must not get that far: whoever can write to the
#  remote would otherwise have a shell on every machine at its next update.)
# (Fetch, check, then merge, rather than pull --verify-signatures: that checks only
#  the commit the pull ends at, so one signed commit on top vouches for every
#  unsigned commit below it.)
#
# $1 names the repository in the messages; the rest is the git invocation to use,
# so this repository and the private one with the machine-specific files go
# through the same check. Both hold commits that this script runs or sources.
pull_verified() {
    local name=$1
    shift
    local -a g=("$@")
    local branch commit
    local -a unverified

    if ! branch=$($g symbolic-ref --short HEAD 2> /dev/null); then
        echo "\nupdate: $name is not on a branch, so nothing was pulled."
        return 1
    fi
    if ! $g fetch origin $branch; then
        echo "\nupdate: the fetch for $name failed, so nothing below it ran."
        return 1
    fi

    # One %G? per incoming commit. Only G passes: a good signature from a key this
    # machine trusts. U (good signature, untrusted key), E (no key to check it with)
    # and N (no signature at all) all stop the update here, before the merge.
    # For a machine that does not have the public key yet: DOTFILES_SKIP_VERIFY=1 dotfiles-update
    if [[ -z $DOTFILES_SKIP_VERIFY ]]; then
        unverified=()
        for commit in ${(f)"$($g log --format='%G? %h %s' HEAD..FETCH_HEAD)"}; do
            [[ -z $commit || $commit == 'G '* ]] || unverified+=$commit
        done
        if (( $#unverified )); then
            echo "\nupdate: these commits coming into $name carry no signature this machine trusts:"
            print -l $unverified
            echo "\nNothing below this check ran, and the files are unchanged."
            echo "Import the public key (gpg --recv-keys <id>) and mark it trusted, or run"
            echo "the update once with DOTFILES_SKIP_VERIFY=1 after reading the commits above"
            echo "yourself."
            return 1
        fi
    fi

    # (--ff-only: when histories diverge, stop instead of merging conflict markers into live files)
    if ! $g merge --ff-only FETCH_HEAD; then
        echo "\nupdate: the merge into $name was refused, so nothing below it ran."
        echo "When the histories have diverged, the commits on each side are listed by"
        echo "$g log --oneline --left-right HEAD...FETCH_HEAD"
        return 1
    fi
}

before=$($GIT_DOTFILES rev-parse HEAD)
pull_verified "the dotfiles" $GIT_DOTFILES --work-tree=$HOME || exit 1

# zsh keeps running the version of this script it started with: when the pull
# changed it, start the new version, once
if [[ -z $DOTFILES_UPDATE_RESTARTED ]] &&
    ! $GIT_DOTFILES diff --quiet $before HEAD -- .dotfiles/scripts/update.zsh; then
    DOTFILES_UPDATE_RESTARTED=1 exec zsh $script
fi

$GIT_DOTFILES --work-tree=$HOME submodule update --init --recursive

# The private repository, if this machine has it: an ordinary repository whose work
# tree is ~/.config/dotfiles, holding what cannot be published (see "Per-OS and
# per-machine settings" in the README). Before the steps below, because vscodium.zsh
# and the pre-commit hook read what it brings. A machine without it keeps its
# untracked local files, and nothing here changes.
GIT_PRIVATE=(git -C $HOME/.config/dotfiles)
if [[ -d $HOME/.config/dotfiles/.git ]]; then
    $GIT_PRIVATE config core.hooksPath ~/.dotfiles/hooks
    $GIT_PRIVATE config commit.gpgsign true
    pull_verified "the private settings" $GIT_PRIVATE || exit 1
fi

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
