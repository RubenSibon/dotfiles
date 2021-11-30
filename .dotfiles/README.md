# Dotfiles

## About these dotfiles

This repository contains [configuration (dotfiles)](https://en.wikipedia.org/wiki/Hidden_file_and_hidden_directory) for the following tools:

- zsh (shell)
- antigen (zsh plugin manager)
- vim (text editor)
- Vundle (vim plugin manager)
- hyper.js (terminal emulator)

This project's install and update scripts also install:

- Node Version Manager (nvm)

This project is to be used on [Unix-like](https://en.wikipedia.org/wiki/Unix-like) systems such as Linux or macOS.

## Author's note

These configurations represent my personal preferences. I sync them between the various machines I use. MacOS, Arch Linux (Yes, I use Arch, btw) and the occasional Debian-based distro tend to be the main operating systems on those machines. If this setup is to your liking, feel free to use it as a starting point for your own config. I've tried to keep everything as generic and environment-agnostic as possible.

## Requirements

- Linux, macOS or any other Unix-like environment that can run Shell/Bash/Zsh
- Git (see: https://git-scm.com/book/en/v2/Getting-Started-Installing-Git)
- Zsh (see: https://wiki.archlinux.org/title/zsh)
- cURL (see: https://curl.se/)

## Setup

The git configration and setup methods are based on the following tutorial: [Simplest Way to Sync Dotfiles and Config Using Git by Victor Augusteo](https://medium.com/@augusteo/simplest-way-to-sync-dotfiles-and-config-using-git-14051af8703a)

Choose **one (A or B)** of the following setup options:

### A) Automatic setup with script

Run the install script:

`curl -o- https://raw.githubusercontent.com/RubenSibon/dotfiles/master/.dotfiles/scripts/install.zsh | zsh`

You're done!

### B) Manual setup

1. Clone the repository:

    `git clone --bare --recursive git@github.com:RubenSibon/dotfiles.git $HOME/.dotfiles/.gitrepo`

2. Check out the cloned bare branch:

    `/usr/bin/git --git-dir=$HOME/.dotfiles/.gitrepo --work-tree=$HOME checkout HEAD --force`

3. Pull the submodules:

    `/usr/bin/git --git-dir=$HOME/.dotfiles/.gitrepo --work-tree=$HOME submodule update --init --recursive`

4. (optional) Install the vim plugins with Vundle:

    `vim +PluginInstall +qall`

5. Source the zsh config (or start a new terminal emulator):

    `source ~/.zshrc`

## Post-setup (optional)

### Install Node, NPM and Yarn

Use [NVM](https://github.com/nvm-sh/nvm) that came with Antigen to install [Node.js](https://nodejs.org/) and then use [NPM](https://www.npmjs.com/) to install [Yarn](https://yarnpkg.com/).

```sh
nvm install node
npm install --global yarn
```

## Update

The update script can be run with a handy alias:

`cd ~ && dotfiles-update`

Or directly:

`zsh ~/.dotfiles/scripts/update.zsh`

Everything should be up-to-date.
