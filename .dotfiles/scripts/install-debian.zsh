#!/usr/bin/env zsh
# Debian part of install.zsh: lists what the dotfiles need from apt (see "Required
# packages" in the README), and installs it only after asking.

steps=()

missing=()
for package in build-essential git locales; do
    dpkg -s $package > /dev/null 2>&1 || missing+=($package)
done
(( $#missing )) && steps+=("sudo apt update && sudo apt install $missing")

# ~/.zshrc uses Dutch formats for dates, paper and addresses (Ubuntu's locale-gen
# takes the name; Debian's reads the uncommented lines of /etc/locale.gen)
if ! locale -a 2> /dev/null | grep -qix 'nl_NL\.utf-\?8'; then
    steps+=(
        "sudo sed -i 's/^# *\(nl_NL.UTF-8 UTF-8\)/\1/' /etc/locale.gen"
        "sudo locale-gen nl_NL.UTF-8"
    )
fi

(( $#steps )) || exit 0

echo "The dotfiles need packages or a locale that this machine lacks. To add them:"
print -rl -- "    "$^steps
if read -q "?Run these commands now? [y/N] "; then
    echo
    for step in $steps; do
        eval $step || exit 1
    done
else
    echo "\nNot running them. Run them yourself when you are ready."
fi
