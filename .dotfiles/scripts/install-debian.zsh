#!/usr/bin/env zsh

sudo apt update && sudo apt upgrade
sudo apt install build-essential git locales

# ~/.zshrc uses Dutch formats for dates, paper and addresses (Ubuntu's locale-gen
# takes the name; Debian's reads the uncommented lines of /etc/locale.gen)
sudo sed -i 's/^# *\(nl_NL.UTF-8 UTF-8\)/\1/' /etc/locale.gen
sudo locale-gen nl_NL.UTF-8
