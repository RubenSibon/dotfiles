#!/usr/bin/env zsh

if [ ! -d "$HOME/.dotfiles/.gitrepo" ]; then
    git clone --bare --recursive https://github.com/RubenSibon/dotfiles.git $HOME/.dotfiles/.gitrepo
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

$HOME/.dotfiles/scripts/update.zsh
