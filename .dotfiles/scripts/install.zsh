#!/usr/bin/env zsh

cd $HOME

if [ ! -d ".dotfiles" ] && [ ! -d ".dotfiles/.gitrepo" ]; then
  git clone --bare --recursive git@github.com:RubenSibon/dotfiles.git $HOME/.dotfiles/.gitrepo
else
  echo "'~/.dotfiles/.gitrepo/' already exists."
  echo "Continuing to update the configuration..."
fi

/usr/bin/git --git-dir=${HOME}/.dotfiles/.gitrepo --work-tree=${HOME} checkout HEAD --force

$HOME/.dotfiles/scripts/update.zsh
