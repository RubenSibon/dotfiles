# Dotfiles

## About these dotfiles

This repository contains the [user configuration (i.e. "dotfiles")](https://en.wikipedia.org/wiki/Hidden_file_and_hidden_directory) for the following tools:

- [zsh](https://wiki.archlinux.org/title/zsh) (shell)
- [antigen](https://github.com/zsh-users/antigen) (zsh plugin manager)
- [fzf](https://github.com/junegunn/fzf) (fuzzy finder)
- [Neovim](https://neovim.io/) and [Vim](https://www.vim.org/) (text editors)*
- [Vundle](https://github.com/VundleVim/Vundle.vim) (vim plugin manager)
- [Git](https://git-scm.com/) (version control)

For Vim/Vundle it installs the following plugins:

- bling/vim-airline
- godlygeek/tabular
- junegunn/fzf
- L9
- mattn/emmet-vim
- plasticboy/vim-markdown
- rstacruz/sparkup
- Syntastic
- scrooloose/nerdtree
- tpope/vim-fugitive
- wakatime/vim-wakatime - [WakaTime](https://wakatime.com/) (track time spent programming, you'll need an API-key for this)

(*) Neovim is the default editor; when it isn't installed, `$EDITOR` falls back to Vim, then nano. For now Neovim reads the Vim configuration (`.config/nvim/init.vim` sources `.vimrc`). A Neovim-native configuration is planned: see the [to-do list](../.dotfiles/TODO.md).

On macOS, the install and update scripts also install:

- [Homebrew](https://brew.sh/) (package manager for macOS)
- the formulae in `~/.dotfiles/Brewfile`, such as Neovim and gitleaks; `update-macos.zsh` installs them with `brew bundle`, then upgrades everything Homebrew installed

On a Mac without the Xcode Command Line Tools, which include git, the install script starts their installer and stops; run it again once they are installed.

This project is to be used on [Unix-like](https://en.wikipedia.org/wiki/Unix-like) systems such as Linux or macOS, including Linux on Windows through [WSL](https://learn.microsoft.com/windows/wsl/).

## Author's note

These configurations represent my personal preferences. I sync them between the various machines I use. macOS, Arch Linux (Yes, I use Arch, btw), NixOS and Debian-based distros such as Ubuntu on WSL, tend to be the main operating systems on those devices. If this setup is to your liking, feel free to use it as a starting point for your own config. Because these dotfiles have to work on both macOS and various Linux distros they are quite generic and environment-agnostic.

## Requirements

- Linux, macOS or any other [POSIX-compliant operating system](https://en.wikipedia.org/wiki/POSIX) that can run Shell/Bash/Zsh
- Git (see: <https://git-scm.com/book/en/v2/Getting-Started-Installing-Git>)
- Zsh (see: <https://wiki.archlinux.org/title/zsh>)
- cURL (see: <https://curl.se/>)
- On Debian-based distros: `sudo`, because the install script installs git, build tools and the `nl_NL.UTF-8` locale with apt

## Setup

> **Protip**: Try these scripts out in a [virtual machine](https://en.wikipedia.org/wiki/Virtual_machine) or [suitable Docker image](https://hub.docker.com/_/ubuntu) first.

> **Protip**: First fork this repo if you want to use it as the basis for your own dotfiles and replace the username in all commands and the `.dotfiles/scripts/install.zsh` script with your own.

The git configuration and setup methods are based on the following tutorial: [Simplest Way to Sync Dotfiles and Config Using Git by Victor Augusteo](https://medium.com/@augusteo/simplest-way-to-sync-dotfiles-and-config-using-git-14051af8703a)

> **Note**: Make sure that zsh is installed. The update script makes it your login shell with `chsh` if it isn't yet. On NixOS, set it in your system configuration instead: `users.users.<name>.shell = pkgs.zsh;`.

Choose **one (A or B)** of the following setup options:

### A) Automatic setup with script

Run the install script:

`curl -fsSL https://raw.githubusercontent.com/RubenSibon/dotfiles/master/.dotfiles/scripts/install.zsh | zsh`

> **Note**: On a fresh install, the script replaces files in your home directory that this repository also contains, such as `.zshrc` and `.gitconfig`. It copies them to `~/.dotfiles/backup-<date>/` first.

You're done!

### B) Manual setup

1. Clone the repository:

    `git clone --bare --recursive https://github.com/RubenSibon/dotfiles.git $HOME/.dotfiles/.gitrepo`

2. Push over SSH, while fetching stays on HTTPS so update checks need no SSH key, keep git's file watcher off your home directory, and enable the pre-commit hook that refuses secrets and personal details:

    `git --git-dir=$HOME/.dotfiles/.gitrepo remote set-url --push origin git@github.com:RubenSibon/dotfiles.git`

    `git --git-dir=$HOME/.dotfiles/.gitrepo config core.fsmonitor false`

    `git --git-dir=$HOME/.dotfiles/.gitrepo config core.hooksPath $HOME/.dotfiles/hooks`

3. Check out the cloned bare branch:

    `git --git-dir=$HOME/.dotfiles/.gitrepo --work-tree=$HOME checkout HEAD`

    This fails when files such as `.zshrc` already exist. Back those up, then add `--force` to overwrite them.

4. Pull the submodules:

    `git --git-dir=$HOME/.dotfiles/.gitrepo --work-tree=$HOME submodule update --init --recursive`

5. (optional) Install the vim plugins with Vundle:

    `vim +PluginInstall +qall`

6. Start a new terminal emulator with Zsh:

    `zsh`

7. (optional) Try an update to see if you get more changes

   `dotfiles-update`

## Update

The update script can be run with a handy alias:

`dotfiles-update`

**_Or_** directly:

`zsh ~/.dotfiles/scripts/update.zsh`

Everything should be up-to-date.

When you open a terminal and the dotfiles haven't been checked for updates in the last 72 hours, zsh offers to check for updates, and then to install them.

## Undo & uninstall

To undo and remove these dotfiles, first check `~/.dotfiles` for files of your own, because the repository ignores everything it doesn't track. Then:

`rm -rf ~/.dotfiles`

You may want to remove the git files pulled by this repo, but be sure to check the contents before you do:

`rm -rf ~/.gitmodules ~/.gitignore ~/.zshenv`

And edit your `.gitconfig` file: be sure to remove references to the `.dotfiles` directory and this repo.

Then remove what you no longer want to use like Antigen/Vundle for Vim and more. Look online for instructions on how to do that.

After that you may want to reset the `.zshrc` and `.vimrc` files to their defaults or at least remove references to the things that have been removed. Keep or delete your machine-specific `~/.zshrc.local` as you see fit.

To uninstall Homebrew follow the [instructions in their frequently asked questions](https://github.com/homebrew/install?tab=readme-ov-file#uninstall-homebrew).

## Usage

`dotfiles` is an alias for `git` in the user's home directory (`~`). It should be used instead of the `git` command to make changes to the dotfiles' git repository.

The alias is needed because this repository's `.git/` directory does not exist in the working directory (`~`), but in `~/.dotfiles/` as `.gitrepo/` instead.

Check your `.zshrc` for the alias.

The `.gitignore` in your home directory ignores everything (`*`), so `dotfiles status` only shows files that the repository already tracks. Add a new file explicitly, one at a time: `dotfiles add -f <path>`.

### Per-OS and per-machine settings

- Settings for one operating system go in `~/.dotfiles/zsh/<os>.zsh`, such as `macos.zsh` and `debian.zsh`. `.zshrc` loads the ones that apply, under "OS-specific configuration".
- `~/.zshenv` is read by every zsh, before the system's `/etc/zshrc`. It only holds what has to be set that early, such as turning off the per-window history of the macOS Terminal.
- Settings for one machine go in `~/.zshrc.local`, which `.zshrc` loads last. The repository doesn't track it, so it can hold paths and names that shouldn't be published.
- Your git identity and other machine-specific git settings, such as `includeIf` blocks, go in `~/.gitconfig.local`, which `.gitconfig` includes last. The repository doesn't track it either. Create it on every machine:

    ```gitconfig
    [user]
        name = Your Name
        email = you@example.com
    ```

### NixOS

`~/.dotfiles/nixos` is a flake with the system configuration for my NixOS machines. The dotfiles hold the configuration of the tools; the flake installs them.

- `base.nix`: every machine, including servers without a desktop.
- `desktop.nix`: every machine with a graphical session, whichever desktop environment it runs.
- `gnome.nix`: GNOME, next to `desktop.nix`.
- `hosts/<host name>/`: one machine. The repository doesn't track these directories, because they hold host names, user names and disk IDs.

On a new machine, create `hosts/<host name>/default.nix`, copy `/etc/nixos/hardware-configuration.nix` next to it, and import the modules the machine needs:

```nix
{ ... }:

{
  imports = [
    ./hardware-configuration.nix
    ../../base.nix
  ];

  boot.loader.systemd-boot.enable = true;
  networking.hostName = "<host name>";
  users.users.<name> = {
    isNormalUser = true;
    extraGroups = [ "wheel" ];
  };
  system.stateVersion = "<release of the first install>";
}
```

Then build and activate it; the configuration is picked by the machine's current host name, or name it with `#<host name>`:

`sudo nixos-rebuild switch --flake ~/.dotfiles/nixos`

`flake.lock` pins nixpkgs, so every machine builds the same versions. Move it along with `nix flake update --flake ~/.dotfiles/nixos`, rebuild, and commit the lock file.

### Agent instructions

`~/.dotfiles/agents/AGENTS.md` holds my instructions for coding agents, whichever tool runs them, and `~/.dotfiles/AGENTS.md` adds the rules for working on this repository. `dotfiles-update` points the agents it finds at the shared instructions, unless a machine already has its own instruction file:

- Claude Code: `~/.claude/CLAUDE.md` imports them with `@~/.dotfiles/agents/AGENTS.md`. Add machine-specific instructions below that line.
- GitHub Copilot CLI: `~/.copilot/copilot-instructions.md` links to them.
- Zed: `~/.config/zed/AGENTS.md` links to them. On Windows, Zed reads `%APPDATA%\Zed\AGENTS.md`; copy the file there.

### Claude Code plugins

`dotfiles-update` installs the Claude Code plugins [caveman](https://github.com/JuliusBrussee/caveman) and [ponytail](https://github.com/DietrichGebert/ponytail) from `~/.dotfiles/claude-plugins`, a marketplace that pins each plugin to a release tag and its commit (`ref` and `sha`). Their hooks run with your permissions at every session start and prompt, so nothing reaches your machines until you have reviewed it and changed the pin here. Claude Code doesn't update this marketplace in the background; leave its auto-update off.

To move a plugin to a newer release:

1. Clone the plugin's repository and compare the release with the pinned one, at least the parts that run code: `git diff <old-tag> <new-tag> -- .claude-plugin hooks src/hooks bin agents .mcp.json settings.json`. Look for network access, child processes, and writes outside `~/.claude`.
2. Set `ref` to the new tag and `sha` to its full commit: `git rev-parse <new-tag>^{commit}`.
3. Check the file with `claude plugin validate ~/.dotfiles/claude-plugins`, run `dotfiles-update`, commit and push. Other machines follow at their next update.

### Pre-commit hook

`~/.dotfiles/hooks/pre-commit` refuses a commit when its changes look like a secret, or match a pattern in `~/.config/dotfiles/private-patterns`: one extended regular expression per line, for the names and paths that must stay private. Lines starting with `!` allow text that the other patterns would block, such as e-mail addresses that are public anyway. When gitleaks is installed, the hook runs it as well.

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
    dotfiles add -u    # Stage the changes to tracked files.
    dotfiles commit    # Commit the changes.
    dotfiles push      # Push the changes to the git server.
    ```

That's how you can use these dotfiles.

Enjoy!
