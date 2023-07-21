#!/usr/bin/env zsh

# Pulling and checking out repository and submodule updates
/usr/bin/git --git-dir=$HOME/.dotfiles/.gitrepo --work-tree=$HOME checkout HEAD
/usr/bin/git --git-dir=$HOME/.dotfiles/.gitrepo --work-tree=$HOME pull
/usr/bin/git --git-dir=$HOME/.dotfiles/.gitrepo --work-tree=$HOME submodule update --init --recursive

# Install fzf (fuzzy finder)
~/.fzf/install

# Install Vim plugins
if [ command -v vim > /dev/null ]; then
    vim +PluginInstall +qall
else
    echo "Vim is not installed. Not installing Vundle plugins."
fi

# Install Volta, the hassle-free JavaScript Tool Manager
curl https://get.volta.sh | bash

# Update Homebrew on macOS
if [ $OSTYPE == 'darwin'* ]; then
    brew update && brew upgrade
fi

source ~/.zshrc

echo "\nDotfiles install/update is done!\n\nYou might have to restart your terminal emulator."

chsh -s $(which zsh)
