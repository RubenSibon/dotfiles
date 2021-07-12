cd

if [ ! -d ".dotfiles" ] && [ ! -d ".dotfiles/.gitrepo" ]; then
  git clone --bare --recursive git@github.com:RubenSibon/dotfiles.git $HOME/.dotfiles/.gitrepo
else
  echo "'~/.dotfiles/.gitrepo/' already exists."
  echo "Continuing to update the configuration..."
fi

alias dotfiles="/usr/bin/git --git-dir=${HOME}/.dotfiles/.gitrepo --work-tree=${HOME}"

cd

dotfiles checkout HEAD --force

dotfiles pull

zsh ~/.dotfiles/scripts/update.zsh
