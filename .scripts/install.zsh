source $(dirname "$0")/_checks.zsh

check_for_git

cd

if ! [[ -d ".dotfiles" ]]; then
  git clone --bare --recursive git@github.com:RubenSibon/.dotfiles.git $HOME/.dotfiles
else
  echo ".dotfiles directory already exists. Not cloning the repository again."
  echo "Continuing to update the configuration..."
fi

zsh ~/.scripts/update.zsh
