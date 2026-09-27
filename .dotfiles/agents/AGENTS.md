# Personal instructions for coding agents

These instructions apply to every project, whichever agent runs them.
A project's own instructions win where the two conflict.

## How I want to work with an agent

1. Research and plan first.
   Say which edits you would make, and which open questions should be answered before making them.
2. Make the edits once I approve them, and stop there.
   - Never commit before I have had the chance to review and approve the changes.
   - Never push, deploy, or send anything to a server or a third party without my explicit approval.
   - Do propose well-scoped commits and their messages, unprompted, and then wait.
3. I do the committing myself, or ask you to do it for me.
4. I do the pushing myself, almost always.

## Git identity

Use the name and e-mail that `git config user.name` and `user.email` resolve to inside the repository's own directory.
My git configuration sets them per context, so a plain `git commit` is already correct: never pass `--author`.

Never use an operating-system user name as a person's name, in a commit, a pull request description, a ticket, documentation, or anywhere else.
If the resolved identity looks wrong for the project at hand, say so instead of overriding it.

## Commit messages and pull request titles

Conventional Commits, in English:

```text
<type>(<scope>)<!>: <Subject>
```

- Write the subject in the imperative mood, starting with a capital letter, with no full stop, on one line, under about 80 characters.
- Describe the goal or the outcome of the change, not its mechanics, and not what the diff already shows.
- Do not repeat the scope in the subject.
- The scope is optional; when the repository uses scopes, follow the grouping its history already uses.
- Add context, reasoning or rejected alternatives in a body after a blank line, but only when the "why" is not obvious.
- Append `!` after the scope for a breaking change.

Within a working branch, any Conventional Commit type is fine: `docs`, `refactor`, `test`, `ci`, and so on.
Commits should reflect the conceptual steps of the work so that a reviewer can read them one by one; tidy them with an interactive rebase before asking for review.

A pull request title follows the same format, but release tooling constrains it.
Where squash merging turns the title into the commit message and a tool such as Release Please reads its type, restrict the type to what that tool accepts, and write the title for someone reading the changelog months later rather than for the reviewer who knows the branch.

The repository's own convention — its `AGENTS.md`, contributing guide, or skills — wins over this preference; read it before writing either, and say so when the two differ.

## Secrets and personal data

Never copy secrets (API keys, tokens, passwords, private keys) or personal data into a prompt, a commit, a pull request or code.
If you come across any, tell me.

## My dotfiles

My dotfiles are a bare git repository at `~/.dotfiles/.gitrepo` with my home directory as its work tree; the `dotfiles` alias runs git on it.
When you work on them, also follow `~/.dotfiles/AGENTS.md`.
