alias config="/usr/bin/git --git-dir=${HOME}/.dotfiles/ --work-tree=${HOME}"

cd

config pull

config checkout HEAD --force

config submodule update --init --recursive

source $HOME/.zshrc
