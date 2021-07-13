cd $HOME

# Pulling and checking out repository and submodule updates
/usr/bin/git --git-dir=${HOME}/.dotfiles/.gitrepo --work-tree=${HOME} checkout HEAD
/usr/bin/git --git-dir=${HOME}/.dotfiles/.gitrepo --work-tree=${HOME} pull
/usr/bin/git --git-dir=${HOME}/.dotfiles/.gitrepo --work-tree=${HOME} submodule update --init --recursive

# Install Vim plugins
if command -v vim > /dev/null; then
    vim +PluginInstall +qall
else
    echo "Vim is not installed. Not installing Vundle plugins."
fi

source $HOME/.zshrc

# Install latest Node, latest Node LTS and yarn
if command -v nvm > /dev/null; then
    # Install and use Node LTS
    nvm install --lts

    # Install and use Node (latest)
    nvm install node

    zsh

    # Install Yarn
    npm install --global yarn

    if command -v yarn > /dev/null; then
	echo "Installed yarn:"
	yarn -v
    fi
fi
