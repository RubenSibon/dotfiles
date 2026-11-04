# WSL-specific zsh configuration, sourced by ~/.zshrc

# Open links with the Windows browser (package wslu)
command -v wslview > /dev/null && export BROWSER=wslview

# Kitty's Nix build doesn’t know about WSLg’s d3d12 Mesa backend; nixGLIntel
# patches in the host’s real Mesa/EGL libraries without clobbering glibc
command -v nixGLIntel > /dev/null && alias kitty='nixGLIntel kitty'

