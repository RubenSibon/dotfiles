# Dotfiles

## About these dotfiles

This repository contains the [user configuration (i.e. "dotfiles")](https://en.wikipedia.org/wiki/Hidden_file_and_hidden_directory) for the following tools:

- [zsh](https://wiki.archlinux.org/title/zsh) (shell)
- [antigen](https://github.com/zsh-users/antigen) (zsh plugin manager)
- [fzf](https://github.com/junegunn/fzf) (fuzzy finder)
- [vim](https://www.vim.org/) (text editor)
- [Vundle](https://github.com/VundleVim/Vundle.vim) (vim plugin manager)
- [hyper.js](https://hyper.is/) (terminal emulator)
- [WakaTime](https://wakatime.com/) (track time spent programming)

The install and update scripts also install:

- [Volta](https://volta.sh/) (JavaScript tool manager)

This project is to be used on [Unix-like](https://en.wikipedia.org/wiki/Unix-like) systems such as Linux or macOS.

## Author's note

These configurations represent my personal preferences. I sync them between the various machines I use. MacOS, Arch Linux (Yes, I use Arch, btw) and the occasional Debian-based distro tend to be the main operating systems on those devices. If this setup is to your liking, feel free to use it as a starting point for your own config. Because these dotfiles have to work on both macOS and various Linux distros they are quite generic and environment-agnostic.

## Requirements

- Linux, macOS or any other [POSIX-compliant operating system](https://en.wikipedia.org/wiki/POSIX) that can run Shell/Bash/Zsh
- Git (see: <https://git-scm.com/book/en/v2/Getting-Started-Installing-Git>)
- Zsh (see: <https://wiki.archlinux.org/title/zsh>)
- cURL (see: <https://curl.se/>)

## Setup

> **Protip**: Try these scripts out in a [virtual machine](https://en.wikipedia.org/wiki/Virtual_machine) or [suitable Docker image](https://hub.docker.com/_/ubuntu) first.

The git configration and setup methods are based on the following tutorial: [Simplest Way to Sync Dotfiles and Config Using Git by Victor Augusteo](https://medium.com/@augusteo/simplest-way-to-sync-dotfiles-and-config-using-git-14051af8703a)

> **Note**: Make sure that zsh is installed and [set as your default shell](https://wiki.archlinux.org/title/Command-line_shell#Changing_your_default_shell).

Choose **one (A or B)** of the following setup options:

### A) Automatic setup with script

Run the install script:

`curl -o- https://raw.githubusercontent.com/RubenSibon/dotfiles/master/.dotfiles/scripts/install.zsh | zsh`

You're done!

### B) Manual setup

1. Clone the repository:

    `git clone --bare --recursive https://github.com/RubenSibon/dotfiles.git $HOME/.dotfiles/.gitrepo`

2. Check out the cloned bare branch:

    `/usr/bin/git --git-dir=$HOME/.dotfiles/.gitrepo --work-tree=$HOME checkout HEAD --force`

3. Pull the submodules:

    `/usr/bin/git --git-dir=$HOME/.dotfiles/.gitrepo --work-tree=$HOME submodule update --init --recursive`

4. (optional) Install the vim plugins with Vundle:

    `vim +PluginInstall +qall`

5. Start a new terminal emulator with Zsh:

    `zsh`

6. (optional) Try an update to see if you get more changes

   `cd ~ && dotfiles-update`

## Post-setup (optional)

### Install Node, NPM and Yarn

Use [Volta]([https://github.com/nvm-sh/nvm](https://volta.sh/)) that came installed with the scripts to install [Node.js](https://nodejs.org/) and [Yarn](https://yarnpkg.com/) globally:

```sh
volta install node
volta install yarn
```

## Update

The update script can be run with a handy alias:

`cd ~ && dotfiles-update`

**_Or_** directly:

`zsh ~/.dotfiles/scripts/update.zsh`

Everything should be up-to-date.

## Usage

`dotfiles` is an alias for `git` in the user's home directory (`~`). It should be used instead of the `git` command to make changes to the dotfiles' git repository.

The alias is needed because this repository's `.git/` directory does not exist in the working directory (`~`), but in `~/.dotfiles/` as `.gitrepo/` instead.

Check your `.zshrc` for the alias.

### Example

1. Go to your home folder:

    ```zsh
    cd ~
    ```

2. Update the repo to make sure that you have the latest changes.
This also pulls in the latest changes from the git server (i.e. GitHub):

    ```zsh
    dotfiles-update
    ```

3. Edit a dotfile, such as this README for example.

4. Save your changes and commit them:

    ```zsh
    dotfiles status    # Make sure that everything is correct.
    dotfiles add .     # Add the changes to git's staging area.
    dotfiles commit    # Commit the changes.
    dotfiles push      # Push the changes to the git server.
    ```

That's how you can use these dotfiles.

Enjoy!
