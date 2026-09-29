#!/usr/bin/env zsh

# macOS: git comes with the Xcode Command Line Tools. Until they are installed,
# /usr/bin/git only offers to install them, so start that and stop here.
if [[ $OSTYPE == darwin* ]] && ! xcode-select -p > /dev/null 2>&1; then
    xcode-select --install
    echo "Run this script again once the Command Line Tools are installed."
    exit 1
fi

if [ ! -d "$HOME/.dotfiles/.gitrepo" ]; then
    git clone --bare --recursive https://github.com/RubenSibon/dotfiles.git $HOME/.dotfiles/.gitrepo
    # The work tree is the whole home directory: keep git's file watcher off it
    # before the checkout below (update.zsh applies the other repository settings)
    git --git-dir=$HOME/.dotfiles/.gitrepo config core.fsmonitor false
    # Only on a fresh clone: overwrite the files a new system ships with, such as a default ~/.zshrc
    git --git-dir=$HOME/.dotfiles/.gitrepo --work-tree=$HOME checkout HEAD --force
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
