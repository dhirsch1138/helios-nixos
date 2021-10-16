#!/bin/sh
echo "Gathering configs" | lolcat
cp /etc/nixos/configuration.nix nixos/configuration.nix | cat
echo "Committing files" | lolcat
git commit --message "scripted commit" | cat
