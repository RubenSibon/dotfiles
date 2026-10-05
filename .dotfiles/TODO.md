# To do

Follow-up work for these dotfiles, most important first. Like everything else in this repository, this file must stay free of secrets and personal details.

## 1. Editors: Zed and VS Code

### Git integration with the bare repository

Neither editor understands a bare repository with a separate work tree:

- VS Code's Source Control does not detect bare repositories ([microsoft/vscode#80946](https://github.com/microsoft/vscode/issues/80946), closed as a duplicate without a fix).
- Zed finds repositories by looking for `.git` inside the project ([Zed docs](https://zed.dev/docs/git)); bare repositories and `GIT_DIR` are not mentioned.

Options, from least to most effort:

- [ ] Use the `dotfiles` alias in the editor's terminal, or a Git TUI that accepts both paths, such as lazygit: `lazygit --git-dir=$HOME/.dotfiles/.gitrepo --work-tree=$HOME`. Add an alias for it.
- [ ] VS Code running locally (not over Remote-WSL or SSH): open a separate window with `GIT_DIR=$HOME/.dotfiles/.gitrepo GIT_WORK_TREE=$HOME code --new-window ~`. Everything in that window, its terminals included, then works on the dotfiles repository. Untested.
- [ ] Switch to a regular repository, for example `~/.dotfiles` plus GNU Stow (symlinks) or chezmoi. Both editors then work natively. chezmoi also covers per-OS files (templates, `.chezmoiignore`) and can read secrets from a password manager, which overlaps with item 4.

Do not put a `.git` file in `~` that points at the bare repository. Every folder in the home directory would then belong to the dotfiles repository, and `git clean -dfx` in any of them would delete everything the `*` in `~/.gitignore` ignores: nearly the whole home directory.

### Settings

What a WSL machine showed in September 2026:

- VS Code and VSCodium share the settings, keybindings and extensions in `~/.dotfiles/vscode` (see the README). Keep the built-in Settings Sync off for those three: two sync mechanisms fight.
- Zed has no settings sync. Its files live in `~/.config/zed/` on Linux and macOS, and in `%APPDATA%\Zed` on Windows.
- Zed's `settings.json` can hold API tokens (MCP servers) and machine-specific entries (WSL connections, projects), and it has no include mechanism. A tracked copy must be secret-free; machine-specific parts belong in project `.zed/settings.json` files, or in environment variables that MCP servers read.
- `.vscode/settings.json` in this repository is a workspace file: it only applies when `~` itself is opened as a folder, and it contradicts the user settings (minimap, whitespace, word wrap).

Differences between the VS Code and Zed user settings:

| Setting             | VS Code                  | Zed                                        |
| ------------------- | ------------------------ | ------------------------------------------ |
| Editor font         | Fira Code, 16, ligatures | Zed's default, 15                          |
| Theme               | default                  | Ayu Dark (Windows), One Light (WSL copy)   |
| Tab size            | 4 (default)              | 2                                          |
| Rendered whitespace | all                      | selection (default)                        |
| Minimap             | on                       | off (default)                              |
| Telemetry           | off                      | diagnostics and metrics on                 |

Already aligned: the VS Code keymap in Zed, Vim mode in Zed and vscode-neovim in VS Code, unified diffs, format on save, Copilot edit predictions, and a modifier key to send chat messages.

- [ ] Set up the shared VS Code settings on the work laptop (Windows with WSL):
    1. Turn off Settings Sync for settings, keybindings and extensions.
    2. Create `~/.config/dotfiles/vscode/settings.local.json` with what only that machine needs: `firefox.executable` (the Windows path of the browser) and `"vscode-neovim.useWSL": true`.
    3. Create `~/.config/dotfiles/vscode/extensions.local.txt` with `ms-vscode-remote.remote-wsl`, `github.copilot-chat` and `github.vscode-pull-request-github`.
    4. Run `dotfiles-update`. The first run shows how the Windows copy differs and leaves it alone: move what is worth keeping to the shared or the local file, then run `zsh ~/.dotfiles/scripts/vscode.zsh --force`.
    5. Install the extensions that run on the Windows side, such as the theme and vscode-neovim, by hand: from a WSL shell the script only installs on the WSL side.
- [ ] Decide which differences to align, and in which direction.
- [ ] Track a secret-free `.config/zed/settings.json` and `.config/zed/keymap.json` for Linux and macOS.
- [ ] Remove `.vscode/settings.json`, or move what helps when editing the dotfiles into `.dotfiles.code-workspace` (for example `files.exclude` for caches).
- [ ] Consider a `~/.editorconfig` for what every editor reads (line endings, final newline, indentation). It also applies to projects under `~` that have no `.editorconfig` of their own.

## 2. Migrate from Vim to Neovim

Now: `.config/nvim/init.vim` sources `~/.vimrc`, whose plugins come from Vundle (a submodule). `$EDITOR` prefers `nvim`, and git follows it.

- [ ] Install a current Neovim everywhere: Homebrew on macOS; on Debian and Ubuntu not the distribution package (Ubuntu 24.04 ships 0.9) but snap, the upstream release or a PPA; on NixOS `programs.neovim` with `defaultEditor = true`.
- [ ] Write `.config/nvim/init.lua` with lazy.nvim, and track `lazy-lock.json` so every machine gets the same plugin versions.
- [ ] Replace old plugins: Syntastic with the built-in LSP client, vim-airline with lualine, NERDTree with neo-tree or oil.nvim, fzf.vim with fzf-lua or Telescope. Keep fugitive and vim-wakatime; its API key stays in the untracked `~/.wakatime.cfg`.
- [ ] On NixOS, install language servers with Nix: binaries that mason.nvim downloads don't run there without nix-ld.
- [ ] vscode-neovim uses the same config; skip UI plugins with `if vim.g.vscode then … end`.
- [ ] Remove Vundle (submodule, `update.zsh` step, README), and reduce `~/.vimrc` to a plugin-free fallback for machines without Neovim, or remove it.

## 3. Maintained plugin managers

Antigen has been unmaintained since 2019 and the submodule pins a debug build; its cache has broken the prompt before. fzf is a submodule pinned to 0.28 (2021), and `submodule update` never moves it.

- [ ] Replace antigen with antidote (bundles listed in `.zsh_plugins.txt`, similar syntax). Map `antigen use oh-my-zsh` to `ohmyzsh/ohmyzsh path:lib`, plugins such as `git` to `ohmyzsh/ohmyzsh path:plugins/git`, and the theme to `ohmyzsh/ohmyzsh path:themes/ys.zsh-theme`. Load zsh-syntax-highlighting last.
- [ ] antidote does not run `compinit`: call it once in `.zshrc`. On Ubuntu, also set `skip_global_compinit=1` in `~/.zshenv`, or `/etc/zsh/zshrc` runs it a second time; on NixOS, set `programs.zsh.enableGlobalCompInit = false`.
- [ ] Install fzf with the system package manager (Homebrew, apt, nixpkgs), and replace `~/.fzf.zsh` with `source <(fzf --zsh)`. That needs fzf 0.48 or newer; older Debian and Ubuntu packages ship the scripts in `/usr/share/doc/fzf/examples/`. On NixOS, `programs.fzf.keybindings` and `programs.fzf.fuzzyCompletion` set it up system-wide.
- [ ] Remove the `.antigen` and `.fzf` submodules and their steps in `update.zsh`, and update the README.

## 4. OS-specific files: NixOS, WSL and macOS

OS-specific settings go in `~/.dotfiles/zsh/<os>.zsh`, loaded under "OS-specific configuration" in `.zshrc`. Machine-specific settings go in the untracked `~/.zshrc.local`.

- [x] NixOS: the system configuration is a flake in `~/.dotfiles/nixos`: `base.nix` for every machine, `desktop.nix` for graphical sessions and `gnome.nix` for GNOME. `base.nix` makes zsh the login shell (`chsh` does not stick on NixOS), turns off the global `compinit`, and installs what the dotfiles expect, such as Neovim and gitleaks. Each machine has an untracked directory in `nixos/hosts/`.
- [x] NixOS: the bare repository stays, without Home Manager: its files would be read-only links that need a rebuild after every edit, and its zsh and git modules would mean a second version of `.zshrc` and `.gitconfig` next to the one for Debian and macOS. Reconsider when a per-user dconf profile or user services are needed.
- [ ] NixOS: when something NixOS-specific comes up in zsh, add `nixos.zsh` and `[[ -e /etc/NIXOS ]] && source ~/.dotfiles/zsh/nixos.zsh`.
- [ ] NixOS: move to the current release. `flake.lock` pins `nixos-25.11`, which no longer gets updates: change the branch in `flake.nix`, run `nix flake update`, and read the release notes before rebuilding. `system.stateVersion` stays as it is.
- [ ] NixOS: keep the `hosts/` directories somewhere, such as a private repository; they are small but not synced.
- [ ] NixOS: check whether the oh-my-zsh `ssh-agent` plugin gets in the way of the agent that GNOME starts (`SSH_AUTH_SOCK` points at `gcr`), and skip it there as on macOS.
- [ ] NixOS: fzf moves to nixpkgs together with item 3 (`programs.fzf.keybindings` and `programs.fzf.fuzzyCompletion` in `base.nix`); until then the submodule's binary and key bindings stay a matching pair.
- [ ] WSL: add `wsl.zsh` with `[[ -n $WSL_DISTRO_NAME ]] && source ~/.dotfiles/zsh/wsl.zsh` when needed. Candidates: `BROWSER=wslview` (package `wslu`) as a default, and `appendWindowsPath = false` in `/etc/wsl.conf` with only the Windows tools you use (such as `code`) added back, because every Windows folder in `PATH` slows down command lookups. Windows paths that contain a user name stay in `~/.zshrc.local`.
- [x] macOS: `macos.zsh` loads Homebrew on Apple Silicon and Intel, including its zsh completions, and is sourced before the plugins; the oh-my-zsh `ssh-agent` plugin is skipped in favour of the macOS agent and Keychain; `.zshenv` turns off the Terminal's per-window history; `update.zsh` applies the repository settings to clones made by older install scripts; `install.zsh` starts the Command Line Tools installer when git is missing, backs up the files a fresh checkout replaces, and gives the update script the terminal so Homebrew's installer can ask for a password; `update-macos.zsh` holds the Homebrew steps.
- [x] macOS: a `Brewfile` for the formulae every Mac should have (git, gitleaks, Neovim), installed by `update-macos.zsh` with `brew bundle`. Add fzf with item 3; until then the submodule's older key bindings would run against a newer binary.
- [ ] macOS: `defaults write` settings (Finder, Dock, key repeat) in `scripts/macos-defaults.zsh`, run on request, not on every update, because some need a logout. Pick the settings first.
- [x] macOS: the login shell stays the system's `/bin/zsh`, not Homebrew's: it is always listed in `/etc/shells` and keeps working when Homebrew breaks. `update.zsh` sets it with `chsh`.
