#!/usr/bin/env zsh
# macOS part of update.zsh: Homebrew, and the formulae in ~/.dotfiles/Brewfile

# Put Homebrew on PATH, as a new terminal does
source ~/.dotfiles/zsh/macos.zsh

if ! command -v brew > /dev/null; then
    echo "🤖 Installing Homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)" || exit 1
    source ~/.dotfiles/zsh/macos.zsh
    echo "✔ done installing Homebrew.\n"
fi

echo "🤖 Updating Homebrew..."
brew update && brew bundle --file ~/.dotfiles/Brewfile && brew upgrade
echo "✔ done updating Homebrew.\n"
