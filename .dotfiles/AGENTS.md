# Instructions for agents working on these dotfiles

This repository is public: anyone can read what is committed here.
Keep secrets and personal details out of it.

## How the repository works

- It is a bare repository at `~/.dotfiles/.gitrepo` with the home directory as its work tree.
  Run git as `git --git-dir=$HOME/.dotfiles/.gitrepo --work-tree=$HOME`; the `dotfiles` alias does that in zsh.
- Changes are made in the clone `~/.dotfiles-src`, opened in a sandbox with `dotfiles-dev` (see "Developing the dotfiles" in the README).
  In the sandbox the clone is the home directory, plain `git` works instead of the `dotfiles` alias, and `.git` is read-only: Ruben commits outside it.
  If you find yourself in the real home directory instead, say so before reading or changing anything outside `~/.dotfiles`.
- `~/.gitignore` ignores the top level of the home directory, allows what the repository tracks, and ignores the private files inside those allowed directories, so `status` shows new files only where they belong.
  Add files by path, never with `-A` or `-f`.
  A file that belongs elsewhere gets an allow pattern in `~/.gitignore` first; a private file in an allowed directory gets an ignore pattern that names no person, employer or host.
- Settings for one operating system go in `~/.dotfiles/zsh/<os>.zsh`.
  Settings for one machine go in untracked files, such as `~/.zshrc.local` and `~/.gitconfig.local`.
- Shared instructions for coding agents live in `~/.dotfiles/agents/AGENTS.md`.
  Keep them tool-neutral; anything specific to one employer or client belongs in an untracked local file.
- The pre-commit hook `~/.dotfiles/hooks/pre-commit` refuses staged changes that look like secrets, or that match the patterns in the untracked `~/.config/dotfiles/private-patterns`.
  Never bypass it with `--no-verify`.
- Claude Code plugins come from `~/.dotfiles/claude-plugins`, each pinned to a reviewed commit.
  Change a pin only after Ruben has reviewed the new release, and never replace a pin with an unpinned source or a branch.

## Never commit

- Secrets: API keys, tokens, passwords, private keys, `.env` files, SSH or GPG material, and editor, agent or MCP settings that contain credentials.
- Personal or identifying details: e-mail addresses, employer, client or project names, user names (write `$HOME` or `~` in paths), host names, internal URLs.
  Exceptions, because they appear in public commits anyway: Ruben’s full name, and his e-mail addresses `mail@rubensibon.nl`, `mail+git@rubensibon.nl`, `mail+github@rubensibon.nl`, `mail@webricolage.nl` and `r.sibon@amsterdam.nl` (City of Amsterdam).
- Anything specific to one employer or client.

## Before committing

Review the staged diff for the above, and check the identity the commit will carry: `dotfiles config user.email`.
