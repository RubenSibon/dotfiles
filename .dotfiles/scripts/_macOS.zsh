if [[ $OSTYPE == 'darwin'* ]]; then
  # Install Homebrew (https://brew.sh/)
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

  # Install Hyper terminal
  brew install hyper
fi
