# macOS-specific zsh configuration, sourced by ~/.zshrc

# Homebrew: on Apple Silicon it lives in /opt/homebrew, which is not on the default PATH
# (on Intel, /usr/local/bin already is)
[[ -x /opt/homebrew/bin/brew ]] && eval "$(/opt/homebrew/bin/brew shellenv)"

# Docker Desktop CLI tools, when installed
[[ -r ~/.docker/init-zsh.sh ]] && source ~/.docker/init-zsh.sh
