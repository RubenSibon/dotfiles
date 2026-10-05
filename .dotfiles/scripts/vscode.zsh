#!/usr/bin/env zsh

# One set of settings, keybindings and extensions for VS Code and VSCodium
# (see the README). --force overwrites a Windows copy that was changed by hand.

src=~/.dotfiles/vscode
# Untracked, for what only this machine needs: settings.local.json (Windows
# copy only) and extensions.local.txt
local_dir=~/.config/dotfiles/vscode
files=(settings.json keybindings.json)

# Linux and macOS: symlinks, so changes made in the editor land in the tracked files
for dir in ~/.config/{Code,VSCodium}/User(N) ~/Library/Application\ Support/{Code,VSCodium}/User(N); do
    for file in $files; do
        # Keep what a machine had before its first run
        [[ -f $dir/$file && ! -L $dir/$file ]] && mv $dir/$file $dir/$file.before-dotfiles
        ln -sf $src/$file $dir/$file
    done
done

# WSL: the editor runs on Windows and reads %APPDATA%, where a symlink into WSL
# is not reliable. Copy instead, with this machine's settings merged in.
if [[ -n $WSL_DISTRO_NAME ]]; then
    dir=$(wslpath "$(cd /mnt/c && cmd.exe /c 'echo %APPDATA%' 2> /dev/null | tr -d '\r')")/Code/User
    for file in $files; do
        [[ -d $dir ]] || break
        if [[ $file == settings.json && -f $local_dir/settings.local.json ]]; then
            new=$(jq -s '.[0] * .[1]' $src/$file $local_dir/settings.local.json) || continue
        else
            new=$(< $src/$file)
        fi
        # <file>.dotfiles is the copy as this script last wrote it: a difference
        # means the file was changed on Windows, and overwriting would lose that
        if [[ -e $dir/$file && $1 != --force ]] && ! diff -q $dir/$file $dir/$file.dotfiles > /dev/null 2>&1; then
            echo "$dir/$file was changed outside the dotfiles (<: dotfiles, >: Windows):"
            diff <(print -r -- $new) $dir/$file
            echo "Move what to keep to $src/$file or $local_dir/settings.local.json, then run: zsh ${0:A} --force\n"
            continue
        fi
        print -r -- $new > $dir/$file
        cp $dir/$file $dir/$file.dotfiles
    done
fi

# Extensions that are not installed yet. One that the editor's marketplace or
# an organisation's policy does not offer is reported and skipped.
wanted=(${(f)"$(cat $src/extensions.txt $local_dir/extensions.local.txt(N))"})
for bin in code codium; do
    command -v $bin > /dev/null || continue
    echo "🤖 Installing missing extensions for $bin..."
    have=(${(fL)"$($bin --list-extensions 2> /dev/null)"})
    for extension in ${wanted:|have}; do
        $bin --install-extension $extension > /dev/null 2>&1 ||
            echo "Could not install $extension for $bin."
    done
    echo "✔ done installing extensions for $bin.\n"
done
