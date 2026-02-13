#!/usr/bin/env zsh

if [ -f "/etc/debian_version" ]; then
   $HOME/.dotfiles/scripts/dev-env-debian.zsh
fi

if [ ! -d ".dotfiles/.gitrepo" ]; then
    git clone --bare --recursive https://github.com/RubenSibon/dotfiles.git $HOME/.dotfiles/.gitrepo
else
    echo "'~/.dotfiles/.gitrepo/' already exists."
    echo "Continuing to update the configuration..."
fi

/usr/bin/git --git-dir=$HOME/.dotfiles/.gitrepo --work-tree=$HOME checkout HEAD --force

$HOME/.dotfiles/scripts/update.zsh
