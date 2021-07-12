cd

if ! [[ -d ".dotfiles/.gitrepo" ]]; then
  git clone --bare --recursive git@github.com:RubenSibon/dotfiles.git $HOME/.dotfiles/.gitrepo
else
  echo "'~/.dotfiles/.gitrepo/' already exists. Not cloning the repository again."
  echo "Continuing to update the configuration..."
fi

zsh ~/.dotfiles/scripts/update.zsh
