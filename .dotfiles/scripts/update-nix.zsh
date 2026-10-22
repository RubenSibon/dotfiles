#!/usr/bin/env zsh
# Linux part of update.zsh, outside NixOS: installs the packages of the flake in
# ~/.dotfiles/nix into the user's Nix profile (see "Required packages" in the README).
# The first install asks first. Later runs follow ~/.dotfiles/nix/flake.lock, which
# came in with the signed pull.

if ! command -v nix > /dev/null; then
    echo "Nix is missing, so the packages in ~/.dotfiles/nix are not installed."
    echo "Install Nix from https://nixos.org/download, then run dotfiles-update again.\n"
    exit 0
fi

# Flakes and the nix command are still experimental: ~/.config/nix/nix.conf enables them,
# but enable them here too, for a machine that does not have that file yet
nix=(nix --extra-experimental-features 'nix-command flakes')
flake=path:$HOME/.dotfiles/nix#dotfiles

profile=$($nix profile list --json)
if grep -q '"dotfiles":{' <<< $profile; then
    # Also the optional entry of an untracked ~/.config/nix-local, for one machine only
    entries=(dotfiles)
    grep -q '"local":{' <<< $profile && entries+=(local)
    echo "🤖 Updating the Nix packages..."
    $nix profile upgrade $entries && echo "✔ done updating the Nix packages.\n"
else
    echo "The Nix packages of the dotfiles are not installed. To install them:"
    echo "    nix profile add $flake"
    if read -q "?Run this command now? [y/N] "; then
        echo
        $nix profile add $flake && echo "✔ done installing the Nix packages.\n"
    else
        echo "\nNot installing them. Run the command yourself when you are ready.\n"
    fi
fi
