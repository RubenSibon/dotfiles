if ! command -v git > /dev/null; then
  echo "Git is not found. Please install it."
  echo "See: https://git-scm.com/book/en/v2/Getting-Started-Installing-Git"
  exit 0
fi

cd

if ! [[ -d ".dotfiles/.gitrepo" ]]; then
  git clone --bare --recursive git@github.com:RubenSibon/.dotfiles.git $HOME/.dotfiles/.gitrepo
else
  echo "'~/.dotfiles/.gitrepo/' already exists. Not cloning the repository again."
  echo "Continuing to update the configuration..."
fi

zsh ~/.dotfiles/scripts/update.zsh
