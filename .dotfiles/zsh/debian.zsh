# Debian/Ubuntu-specific zsh configuration, sourced by ~/.zshrc

# Snap packages: Ubuntu adds /snap/bin in /etc/profile, which zsh does not read
[[ -d /snap/bin ]] && export PATH="/snap/bin:$PATH"
