# macOS-specific zsh configuration, sourced by ~/.zshrc

# Homebrew: /opt/homebrew on Apple Silicon, /usr/local on Intel. shellenv puts its
# commands on PATH (Apple Silicon only needs that) and its completions on fpath.
for brew in /opt/homebrew/bin/brew /usr/local/bin/brew; do
  [[ -x $brew ]] && eval "$($brew shellenv)" && break
done
unset brew

# Docker Desktop CLI tools, when installed
[[ -r ~/.docker/init-zsh.sh ]] && source ~/.docker/init-zsh.sh

# SSH keys: the oh-my-zsh ssh-agent plugin is skipped on macOS (see ~/.zshrc). To load
# keys into the macOS agent with their passphrases from the Keychain, add this to the
# untracked ~/.ssh/config:
#
#   Host *
#     AddKeysToAgent yes
#     UseKeychain yes
