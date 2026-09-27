#!/usr/bin/env zsh

# Pulling repository and submodule updates
git --git-dir=$HOME/.dotfiles/.gitrepo --work-tree=$HOME pull
git --git-dir=$HOME/.dotfiles/.gitrepo --work-tree=$HOME submodule update --init --recursive

# Point the agents on this machine at the shared agent instructions,
# unless a machine already has its own instruction file
[[ -d ~/.claude && ! -e ~/.claude/CLAUDE.md ]] && print '@~/.dotfiles/agents/AGENTS.md' > ~/.claude/CLAUDE.md
for file in ~/.copilot/copilot-instructions.md ~/.config/zed/AGENTS.md; do
    [[ -d ${file:h} && ! -e $file ]] && ln -s ~/.dotfiles/agents/AGENTS.md $file
done

# Claude Code plugins; installing one that is already there changes nothing
if command -v claude > /dev/null; then
    claude plugin marketplace add JuliusBrussee/caveman > /dev/null 2>&1
    claude plugin marketplace add DietrichGebert/ponytail > /dev/null 2>&1
    claude plugin install caveman@caveman > /dev/null 2>&1
    claude plugin install ponytail@ponytail > /dev/null 2>&1
fi

# Install fzf (fuzzy finder)
if [ -x ~/.fzf/install ]; then
    echo "\n🤖 Installing/updating fuzzy finder (fzf)..."
    ~/.fzf/install --key-bindings --completion --no-update-rc
    echo "✔ done installing/updating fzf.\n"
else
    echo "fzf is not checked out. Not installing fzf."
fi

# Install Vim plugins
if command -v vim > /dev/null; then
    echo "🤖 Installing/updating Vundle plugins for Vim..."
    vim +PluginInstall +qall
    echo "✔ done installing/updating Vundle plugins.\n"
else
    echo "Vim is not installed. Not installing Vundle plugins."
fi

# Update Homebrew on macOS
if [[ $OSTYPE == 'darwin'* ]]; then
    if ! command -v brew > /dev/null && [ ! -x /opt/homebrew/bin/brew ]; then
        echo "🤖 Installing Homebrew..."
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
        echo "✔ done installing Homebrew.\n"
    fi

    # On Apple Silicon, Homebrew lives in /opt/homebrew, which is not on the default PATH
    [ -x /opt/homebrew/bin/brew ] && eval "$(/opt/homebrew/bin/brew shellenv)"

    echo "🤖 Updating Homebrew..."
    brew update && brew upgrade
    echo "✔ done updating Homebrew.\n"
fi

echo "🤖 Dotfiles install/update is done!\n\nOpen a new terminal or run 'exec zsh' to load the changes."

# Make zsh the login shell, unless it already is
[[ $SHELL == */zsh ]] || chsh -s $(command -v zsh)
