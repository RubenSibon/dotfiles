# Instructions for agents working on these dotfiles

This repository is public: anyone can read what is committed here.
Keep secrets and personal details out of it.

## How the repository works

- It is a bare repository at `~/.dotfiles/.gitrepo` with the home directory as its work tree.
  Run git as `git --git-dir=$HOME/.dotfiles/.gitrepo --work-tree=$HOME`; the `dotfiles` alias does that in zsh.
- `~/.gitignore` ignores everything (`*`), so `status` only shows changes to tracked files.
  Add a new file deliberately, one path at a time: `dotfiles add -f <path>`.
  Never add a directory with `-f`: directories such as `~/.dotfiles`, `~/.claude` and `~/.config` also hold private, untracked files.
- Settings for one operating system go in `~/.dotfiles/zsh/<os>.zsh`.
  Settings for one machine go in untracked files, such as `~/.zshrc.local` and `~/.gitconfig.local`.
- Shared instructions for coding agents live in `~/.dotfiles/agents/AGENTS.md`.
  Keep them tool-neutral; anything specific to one employer or client belongs in an untracked local file.
- The pre-commit hook `~/.dotfiles/hooks/pre-commit` refuses staged changes that look like secrets, or that match the patterns in the untracked `~/.config/dotfiles/private-patterns`.
  Never bypass it with `--no-verify`.

## Never commit

- Secrets: API keys, tokens, passwords, private keys, `.env` files, SSH or GPG material, and editor, agent or MCP settings that contain credentials.
- Personal or identifying details: e-mail addresses, employer, client or project names, user names (write `$HOME` or `~` in paths), host names, internal URLs.
  Exceptions, because they appear in public commits anyway: Ruben’s full name, and his e-mail addresses `mail@rubensibon.nl`, `mail+git@rubensibon.nl`, `mail+github@rubensibon.nl`, `mail@webricolage.nl` and `r.sibon@amsterdam.nl` (City of Amsterdam).
- Anything specific to one employer or client.

## Before committing

Review the staged diff for the above, and check the identity the commit will carry: `dotfiles config user.email`.
