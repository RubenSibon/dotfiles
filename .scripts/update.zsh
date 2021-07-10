source $(dirname "$0")/_checks.zsh

check_for_git

alias config="/usr/bin/git --git-dir=${HOME}/.dotfiles/ --work-tree=${HOME}"

cd

config checkout HEAD

config pull

config submodule update --init --recursive

if command -v vim > /dev/null; then
    vim +PluginInstall +qall
else
    echo "Vim is not installed. Not installing Vundle plugins."
fi

source $HOME/.zshrc
