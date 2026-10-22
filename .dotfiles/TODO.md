# To do

Follow-up work for these dotfiles, most important first. Like everything else in this repository, this file must stay free of secrets and personal details.

## 1. Commit signing and hardening

What is left here is hardening with the pressure off: every machine signs what it commits, and `dotfiles-update` verifies every commit it is about to run.

### GPG

- [x] Every machine has its own signing subkey under the one primary key, instead of a copy of the primary key or a key per machine. To add the next machine, on the NixOS laptop, which holds the primary key:
    1. `gpg --quick-add-key <primary fingerprint> ed25519 sign 2y`
    2. `gpg --armor --export-secret-subkeys '<subkey id>!' > subkey.asc`: the `!` exports only that subkey's secret part, not the primary key.
    3. Move `subkey.asc` to the other machine over a private channel, `gpg --import` it there, give the primary key ultimate trust, and delete the file with `shred -u`.
    4. Set `signingkey = <subkey id>!` under `[user]` in that machine's `~/.gitconfig.local`.
    5. Export the public key again, import it on every machine that runs `dotfiles-update`, and upload it to GitHub, so the new subkey shows as verified.
- [x] The commits that the work laptop made unsigned carry signatures: `git rebase --force-rebase --gpg-sign origin/master` on the branch they sat on, checked with `git log --show-signature`, then folded into `master` and the branch deleted on both sides. The commits pushed unsigned before that stay as they are; rewriting them would mean a force-push to every machine.
- [x] `~/.gnupg` is in an encrypted backup on two separate media (`tar -C ~ -cf - .gnupg | gpg --symmetric --cipher-algo AES256`), which includes the revocation certificate in `~/.gnupg/openpgp-revocs.d/`. The passphrase is in the password manager: a passphrase remembered now and forgotten in two years makes the backup worth nothing. A calendar reminder sits before the subkeys expire.
- [ ] Keep the primary key off the laptops, now that the backup exists: `gpg --export-secret-subkeys`, `gpg --delete-secret-keys`, re-import, and check that `gpg --list-secret-keys` shows `sec#`. The primary is then needed only to add, extend or revoke a subkey, and a compromised laptop costs one subkey instead of the identity. Lower priority than the rest of this section: it makes recovery cheaper, it does not stop anything.

### Update and commit checks

- [x] `update.zsh` fetches, reads one `%G?` per commit over `HEAD..FETCH_HEAD`, and merges `--ff-only` only when every one of them is `G`. `U` (good signature, untrusted key), `E` (no key to check it with) and `N` (no signature) each stop the update before the merge, so before anything it brought in runs, and the refusal names the commits. `git pull --verify-signatures` checked only the commit the pull ended at, so one signed commit on top vouched for every unsigned commit below it.
- [x] gitleaks: the pre-commit hook asks the version on the machine which subcommand it has, newest name first, instead of picking one for every machine. gitleaks 8.19 renamed `protect --staged` to `git --staged`; 8.30 still accepts the old name as a deprecated alias, but Ubuntu 24.04's apt package is 8.16, which predates the rename, and a gitleaks 9 without the alias would block every commit.
- [x] Machine-specific git settings live in `~/.config/dotfiles/gitconfig-<identity>`, where the `includeIf` blocks in `~/.gitconfig.local` point at them, and the whole directory is ignored with the rest of `~/.config`. In `~/.dotfiles` they showed up as untracked, because `.gitignore` allows everything inside that directory, and only an ignore pattern kept them out of a commit.

## 2. Editors: Zed and VS Code

### Git integration with the bare repository

Neither editor understands a bare repository with a separate work tree:

- VS Code's Source Control does not detect bare repositories ([microsoft/vscode#80946](https://github.com/microsoft/vscode/issues/80946), closed as a duplicate without a fix).
- Zed finds repositories by looking for `.git` inside the project ([Zed docs](https://zed.dev/docs/git)); bare repositories and `GIT_DIR` are not mentioned.

- [x] Edit in the ordinary clone `~/.dotfiles-src`, opened in a sandbox with `dotfiles-dev` (see "Developing the dotfiles" in the README). The clone has a `.git`, so both editors show the status and the diff; it is read-only in the sandbox, so commit from a terminal outside it. Do not open `~` itself in an editor or agent any more.
- [ ] Switch to a regular repository, for example `~/.dotfiles` plus GNU Stow (symlinks) or chezmoi. The deployed copy and the clone would then have the same layout. chezmoi also covers per-OS files (templates, `.chezmoiignore`) and can read secrets from a password manager, which overlaps with item 5.

Do not put a `.git` file in `~` that points at the bare repository. Every folder in the home directory would then belong to the dotfiles repository, and `git clean -dfx` in any of them would delete everything the `*` in `~/.gitignore` ignores: nearly the whole home directory.

### Sandbox for developing the dotfiles

`dotfiles-dev` uses bubblewrap, which only exists on Linux.

- [ ] macOS without bubblewrap: fall back to a rootless Podman container with the clone mounted as its home directory, for example `podman run --rm -it --userns=keep-id -v ~/.dotfiles-src:$HOME -v ~/.dotfiles-src/.git:$HOME/.git:ro -w $HOME <image>`. It needs an image with zsh, git and Neovim, and covers terminal programs only: graphical editors need a remote connection into the container. Not Docker: membership of its group equals root.
- [ ] The same container on NixOS, with a Debian image, to test `debian.zsh` and `install-debian.zsh`.
- [ ] Try each program once in the sandbox: VSCodium and Zed (windows, GPU), Neovim.
- [x] Claude Code runs in the sandbox on the subscription login, without a keyring: the token is plain JSON in the clone's ignored `.claude/.credentials.json`. It needs no `ANTHROPIC_API_KEY`; passing one in would move billing off the subscription and leave a long-lived secret in the sandbox.
- [ ] Decide whether agents in the sandbox get the shared instructions and plugins: `update.zsh` sets those up, and does not run in the clone.

### Settings

What a WSL machine showed in September 2026:

- VSCodium and VS Code take their settings, keybindings and extensions from `~/.dotfiles/vscodium`; VSCodium leads, and only VSCodium gets Claude Code (see the README). Keep the built-in Settings Sync off for those three: two sync mechanisms fight.
- Zed has no settings sync. Its files live in `~/.config/zed/` on Linux and macOS, and in `%APPDATA%\Zed` on Windows.
- Zed's `settings.json` can hold API tokens (MCP servers) and machine-specific entries (WSL connections, projects), and it has no include mechanism. A tracked copy must be secret-free; machine-specific parts belong in project `.zed/settings.json` files, or in environment variables that MCP servers read.

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
    2. Create `~/.config/dotfiles/vscodium/settings.local.json` with what only that machine needs: `firefox.executable` (the Windows path of the browser), `"vscode-neovim.useWSL": true` and `vscode-neovim.neovimExecutablePaths.linux` (where Neovim lives in WSL).
    3. Create `~/.config/dotfiles/vscodium/extensions.local.txt` with `ms-vscode-remote.remote-wsl`, `github.copilot-chat` and `github.vscode-pull-request-github`.
    4. Run `dotfiles-update`. The first run shows how the Windows copy differs and leaves it alone: move what is worth keeping to the shared or the local file, then run `zsh ~/.dotfiles/scripts/vscodium.zsh --force`.
    5. Install the extensions that run on the Windows side, such as the theme and vscode-neovim, by hand: from a WSL shell the script only installs on the WSL side.
- [ ] Decide which differences to align, and in which direction.
- [ ] Track a secret-free `.config/zed/settings.json` and `.config/zed/keymap.json` for Linux and macOS.
- [ ] Consider a `~/.editorconfig` for what every editor reads (line endings, final newline, indentation). It also applies to projects under `~` that have no `.editorconfig` of their own.

## 3. Migrate from Vim to Neovim

Now: `.config/nvim/init.vim` sources `~/.vimrc`, whose plugins come from Vundle (a submodule). `$EDITOR` prefers `nvim`, and git follows it.

- [ ] Install a current Neovim everywhere: Homebrew on macOS; on Debian and Ubuntu not the distribution package (Ubuntu 24.04 ships 0.9) but snap, the upstream release or a PPA; on NixOS `programs.neovim` with `defaultEditor = true`.
- [ ] Write `.config/nvim/init.lua` with lazy.nvim, and track `lazy-lock.json` so every machine gets the same plugin versions.
- [ ] Replace old plugins: Syntastic with the built-in LSP client, vim-airline with lualine, NERDTree with neo-tree or oil.nvim, fzf.vim with fzf-lua or Telescope. Keep fugitive and vim-wakatime; its API key stays in the untracked `~/.wakatime.cfg`.
- [ ] On NixOS, install language servers with Nix: binaries that mason.nvim downloads don't run there without nix-ld.
- [ ] vscode-neovim uses the same config; skip UI plugins with `if vim.g.vscode then … end`.
- [ ] Remove Vundle (submodule, `update.zsh` step, README), and reduce `~/.vimrc` to a plugin-free fallback for machines without Neovim, or remove it.

## 4. Maintained plugin managers

Antigen has been unmaintained since 2019 and the submodule pins a debug build; its cache has broken the prompt before. fzf is a submodule pinned to 0.28 (2021), and `submodule update` never moves it.

- [ ] Replace antigen with antidote (bundles listed in `.zsh_plugins.txt`, similar syntax). Map `antigen use oh-my-zsh` to `ohmyzsh/ohmyzsh path:lib`, plugins such as `git` to `ohmyzsh/ohmyzsh path:plugins/git`, and the theme to `ohmyzsh/ohmyzsh path:themes/ys.zsh-theme`. Load zsh-syntax-highlighting last.
- [ ] antidote does not run `compinit`: call it once in `.zshrc`. On Ubuntu, also set `skip_global_compinit=1` in `~/.zshenv`, or `/etc/zsh/zshrc` runs it a second time; on NixOS, set `programs.zsh.enableGlobalCompInit = false`.
- [ ] Install fzf with the system package manager (Homebrew, apt, nixpkgs), and replace `~/.fzf.zsh` with `source <(fzf --zsh)`. That needs fzf 0.48 or newer; older Debian and Ubuntu packages ship the scripts in `/usr/share/doc/fzf/examples/`. On NixOS, `programs.fzf.keybindings` and `programs.fzf.fuzzyCompletion` set it up system-wide.
- [ ] Remove the `.antigen` and `.fzf` submodules and their steps in `update.zsh`, and update the README.

## 5. OS-specific files: NixOS, WSL and macOS

OS-specific settings go in `~/.dotfiles/zsh/<os>.zsh`, loaded under "OS-specific configuration" in `.zshrc`. Machine-specific settings go in the untracked `~/.zshrc.local`.

- [x] NixOS: the system configuration is a flake in `~/.dotfiles/nixos`: `base.nix` for every machine, `desktop.nix` for graphical sessions and `gnome.nix` for GNOME. `base.nix` makes zsh the login shell (`chsh` does not stick on NixOS), turns off the global `compinit`, and installs what the dotfiles expect, such as Neovim and gitleaks. Each machine has an untracked directory in `nixos/hosts/`.
- [x] NixOS: the bare repository stays, without Home Manager: its files would be read-only links that need a rebuild after every edit, and its zsh and git modules would mean a second version of `.zshrc` and `.gitconfig` next to the one for Debian and macOS. Reconsider when a per-user dconf profile or user services are needed.
- [ ] NixOS: when something NixOS-specific comes up in zsh, add `nixos.zsh` and `[[ -e /etc/NIXOS ]] && source ~/.dotfiles/zsh/nixos.zsh`.
- [ ] NixOS: move to the current release. `flake.lock` pins `nixos-25.11`, which no longer gets updates: change the branch in `flake.nix`, run `nix flake update`, and read the release notes before rebuilding. `system.stateVersion` stays as it is.
- [ ] NixOS: keep the `hosts/` directories somewhere, such as a private repository; they are small but not synced.
- [ ] NixOS: check whether the oh-my-zsh `ssh-agent` plugin gets in the way of the agent that GNOME starts (`SSH_AUTH_SOCK` points at `gcr`), and skip it there as on macOS.
- [ ] NixOS: fzf moves to nixpkgs together with item 4 (`programs.fzf.keybindings` and `programs.fzf.fuzzyCompletion` in `base.nix`); until then the submodule's binary and key bindings stay a matching pair.
- [ ] WSL: add `wsl.zsh` with `[[ -n $WSL_DISTRO_NAME ]] && source ~/.dotfiles/zsh/wsl.zsh` when needed. Candidates: `BROWSER=wslview` (package `wslu`) as a default, and `appendWindowsPath = false` in `/etc/wsl.conf` with only the Windows tools you use (such as `code`) added back, because every Windows folder in `PATH` slows down command lookups. Windows paths that contain a user name stay in `~/.zshrc.local`.
- [x] macOS: `macos.zsh` loads Homebrew on Apple Silicon and Intel, including its zsh completions, and is sourced before the plugins; the oh-my-zsh `ssh-agent` plugin is skipped in favour of the macOS agent and Keychain; `.zshenv` turns off the Terminal's per-window history; `update.zsh` applies the repository settings to clones made by older install scripts; `install.zsh` starts the Command Line Tools installer when git is missing, backs up the files a fresh checkout replaces, and gives the update script the terminal so Homebrew's installer can ask for a password; `update-macos.zsh` holds the Homebrew steps.
- [x] macOS: a `Brewfile` for the formulae every Mac should have (git, gitleaks, Neovim), installed by `update-macos.zsh` with `brew bundle`. Add fzf with item 4; until then the submodule's older key bindings would run against a newer binary.
- [ ] macOS: `defaults write` settings (Finder, Dock, key repeat) in `scripts/macos-defaults.zsh`, run on request, not on every update, because some need a logout. Pick the settings first.
- [x] macOS: the login shell stays the system's `/bin/zsh`, not Homebrew's: it is always listed in `/etc/shells` and keeps working when Homebrew breaks. `update.zsh` sets it with `chsh`.
