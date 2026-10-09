#!/usr/bin/env zsh
# macOS part of update.zsh: lists the formulae from ~/.dotfiles/Brewfile that are
# missing (see "Required packages" in the README), and installs them only after asking.

# Put Homebrew on PATH, as a new terminal does
source ~/.dotfiles/zsh/macos.zsh

if ! command -v brew > /dev/null; then
    echo "Homebrew is missing. Install it from https://brew.sh, then run dotfiles-update again.\n"
    exit 0
fi

if ! brew bundle check --verbose --file ~/.dotfiles/Brewfile; then
    echo "To install them:\n    brew bundle --file ~/.dotfiles/Brewfile"
    if read -q "?Run this command now? [y/N] "; then
        echo
        brew bundle --file ~/.dotfiles/Brewfile
    else
        echo "\nNot installing them. Run the command yourself when you are ready."
    fi
fi
