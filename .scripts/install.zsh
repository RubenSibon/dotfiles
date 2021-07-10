source $(dirname "$0")/_checks.zsh

check_for_git

cd

if ! [[ -d ".dotfiles" ]]; then
  git clone --bare --recursive https://github.com/RubenSibon/.dotfiles.git $HOME/.dotfiles
else
  echo ".dotfiles directory already exists. Not cloning repository."
  exit 0
fi

zsh ~/.scripts/update.zsh
