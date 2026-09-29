#!/usr/bin/env zsh

# Git is needed for the clone below
if ! command -v git > /dev/null; then
    if [ -f "/etc/debian_version" ]; then
        # Read answers from the terminal: with `curl … | zsh`, stdin is this script
        sudo apt update </dev/tty && sudo apt install git </dev/tty || exit 1
    elif [[ $OSTYPE != darwin* ]]; then
        echo "Install git, then run this script again."
        exit 1
    fi
fi

# macOS: git comes with the Xcode Command Line Tools. Until they are installed,
# /usr/bin/git only offers to install them, so start that and stop here.
if [[ $OSTYPE == darwin* ]] && ! xcode-select -p > /dev/null 2>&1; then
    xcode-select --install
    echo "Run this script again once the Command Line Tools are installed."
    exit 1
fi

if [ ! -d "$HOME/.dotfiles/.gitrepo" ]; then
    # update.zsh checks out the submodules
    git clone --bare https://github.com/RubenSibon/dotfiles.git $HOME/.dotfiles/.gitrepo || exit 1
    # The work tree is the whole home directory: keep git's file watcher off it
    # before the checkout below (update.zsh applies the other repository settings)
    git --git-dir=$HOME/.dotfiles/.gitrepo config core.fsmonitor false

    # Back up the files that the checkout below overwrites, such as a default ~/.zshrc
    backup=$HOME/.dotfiles/backup-$(date +%Y%m%d-%H%M%S)
    git --git-dir=$HOME/.dotfiles/.gitrepo ls-tree -r --name-only HEAD | while read -r file; do
        [[ -f $HOME/$file ]] && mkdir -p $backup/${file:h} && cp -p $HOME/$file $backup/$file
    done
    [[ -d $backup ]] && echo "Backed up the files that the dotfiles replace to $backup"

    # Only on a fresh clone: overwrite the files a new system ships with
    git --git-dir=$HOME/.dotfiles/.gitrepo --work-tree=$HOME checkout HEAD --force || exit 1
else
    echo "'~/.dotfiles/.gitrepo/' already exists."
    echo "Continuing to update the configuration..."
fi

if [ -f "/etc/debian_version" ]; then
    # Read answers from the terminal: with `curl … | zsh`, stdin is this script
    $HOME/.dotfiles/scripts/dev-env-debian.zsh </dev/tty
fi

# Also from the terminal: installers such as Homebrew's can't ask for a password otherwise
$HOME/.dotfiles/scripts/update.zsh </dev/tty
