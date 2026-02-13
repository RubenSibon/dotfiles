#!/usr/bin/env zsh

# Pulling and checking out repository and submodule updates
/usr/bin/git --git-dir=$HOME/.dotfiles/.gitrepo --work-tree=$HOME checkout HEAD
/usr/bin/git --git-dir=$HOME/.dotfiles/.gitrepo --work-tree=$HOME pull
/usr/bin/git --git-dir=$HOME/.dotfiles/.gitrepo --work-tree=$HOME submodule update --init --recursive

# Install fzf (fuzzy finder)
echo "\n🤖 Installing/updating fuzzy finder (fzf)..."
~/.fzf/install
echo "✔ done installing/updating fzf.\n"

# Install Vim plugins
if command -v vim > /dev/null; then
    echo "🤖 Installing/updating Vundle plugins for Vim..."
    vim +PluginInstall +qall
    echo "✔ done installing/updating Vundle plugins.\n"
else
    echo "Vim is not installed. Not installing Vundle plugins."
fi

# Install PNPM and Node.js LTS version using PNPM
echo "🤖 Installing/updating PNPM (Performant Node Package Manager)..."
curl -fsSL https://get.pnpm.io/install.sh | sh -
echo "🤖 Setting PNPM to use the latest LTS version of Node.js..."
pnpm env use --global lts
echo "✔ done installing/updating PNPM.\n"

# Update Homebrew on macOS
if [[ $OSTYPE == 'darwin'* ]]; then
    if ! [ -f "`which brew`" ]; then
        echo "🤖 Installing Homebrew..."
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
        echo "✔ done installing Homebrew.\n"
    fi

    echo "🤖 Updating Homebrew..."
    brew update && brew upgrade
    echo "✔ done updating Homebrew.\n"
fi

if ! command -v "git hist" > /dev/null; then
    echo "'git hist' command does not exist. Installing..."
    git config --global alias.hist "log --pretty=format:'%C(yellow)[%ad]%C(reset) %C(green)[%h]%C(reset) | %C(red)%s %C(bold red){{%an}}%C(reset) %C(blue)%d%C(reset)' --graph --date=short"
else
    echo "'git hist' command already exists."
fi

source ~/.zshrc

echo "🤖 Dotfiles install/update is done!\n\nYou might have to restart your terminal emulator."

chsh -s $(which zsh)
