# Read by every zsh, before /etc/zshrc and ~/.zshrc. Keep it small.

# macOS Terminal: don't keep a separate history per window (/etc/zshrc_Apple_Terminal).
# ~/.zshrc sets one shared history file.
[[ $OSTYPE == darwin* ]] && export SHELL_SESSIONS_DISABLE=1
