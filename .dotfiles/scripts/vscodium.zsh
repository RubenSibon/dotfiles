#!/usr/bin/env zsh

# Settings, keybindings and extensions for VSCodium and VS Code (see the
# README). VSCodium leads: it works on the tracked files themselves. VS Code
# gets a copy, without what is for VSCodium only (Claude Code).
# --force overwrites a VS Code copy that was changed by hand.

src=~/.dotfiles/vscodium
# Untracked, for what only this machine needs: settings.local.json (Windows
# copy only) and extensions.local.txt
local_dir=~/.config/dotfiles/vscodium
# The directory's name until October 2026
[[ -d ${local_dir:h}/vscode && ! -e $local_dir ]] && mv ${local_dir:h}/vscode $local_dir
files=(settings.json keybindings.json)
# Settings that VS Code does not get
codium_only='^claudeCode\.'

# VSCodium on Linux and macOS: symlinks, so changes made in the editor land in the tracked files
for dir in ~/.config/VSCodium/User(N) ~/Library/Application\ Support/VSCodium/User(N); do
    for file in $files; do
        # Keep what a machine had before its first run
        [[ -f $dir/$file && ! -L $dir/$file ]] && mv $dir/$file $dir/$file.before-dotfiles
        ln -sf $src/$file $dir/$file
    done
done

# Copies the files to VS Code's directory $1. $2 is an optional file with
# settings to merge in.
copy_files() {
    local dir=$1 file new
    for file in $files; do
        if [[ $file == settings.json ]]; then
            if ! command -v jq > /dev/null; then
                echo "jq is missing: skipped $dir/$file."
                continue
            fi
            new=$(jq -s --arg drop $codium_only \
                '(.[0] | with_entries(select(.key | test($drop) | not))) * (.[1] // {})' \
                $src/$file $2) || continue
        else
            new=$(< $src/$file)
        fi
        # A symlink from when both editors shared the tracked files: writing
        # through it would change the tracked file
        [[ -L $dir/$file ]] && rm $dir/$file
        # <file>.dotfiles is the copy as this script last wrote it: a difference
        # means the file was changed in VS Code, and overwriting would lose that
        if [[ -e $dir/$file && $force != --force ]] && ! diff -q $dir/$file $dir/$file.dotfiles > /dev/null 2>&1; then
            echo "$dir/$file was changed outside the dotfiles (<: dotfiles, >: VS Code):"
            diff <(print -r -- $new) $dir/$file
            echo "Move what to keep to $src/$file${2:+ or $2}, then run: zsh $script --force\n"
            continue
        fi
        print -r -- $new > $dir/$file
        cp $dir/$file $dir/$file.dotfiles
    done
}
force=$1
script=${0:A}

for dir in ~/.config/Code/User(N) ~/Library/Application\ Support/Code/User(N); do
    copy_files $dir
done

# WSL: the editor runs on Windows and reads %APPDATA%. This machine's settings
# are merged in.
if [[ -n $WSL_DISTRO_NAME ]]; then
    dir=$(wslpath "$(cd /mnt/c && cmd.exe /c 'echo %APPDATA%' 2> /dev/null | tr -d '\r')")/Code/User
    [[ -d $dir ]] && copy_files $dir $local_dir/settings.local.json(N)
fi

# Extensions that are not installed yet. One that the editor's marketplace or
# an organisation's policy does not offer is reported and skipped.
shared=(${(f)"$(cat $src/extensions.txt $local_dir/extensions.local.txt(N))"})
for bin in codium code; do
    command -v $bin > /dev/null || continue
    echo "🤖 Installing missing extensions for $bin..."
    wanted=($shared)
    [[ $bin == codium ]] && wanted+=(${(f)"$(< $src/extensions.vscodium-only.txt)"})
    have=(${(fL)"$($bin --list-extensions 2> /dev/null)"})
    for extension in ${wanted:|have}; do
        $bin --install-extension $extension > /dev/null 2>&1 ||
            echo "Could not install $extension for $bin."
    done
    echo "✔ done installing extensions for $bin.\n"
done
