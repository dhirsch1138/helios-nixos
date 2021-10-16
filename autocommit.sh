#!/bin/sh
echo "Gathering files" | lolcat
cp /etc/nixos/configuration.nix nixos/configuration.nix | cat
cp ~/Documents/postinstallsteps.txt postinstallsteps.txt | cat
git add * | cat
echo "Committing files" | lolcat
git commit --message "scripted commit" | cat
echo "Pushing to github" | lolcat
git push origin main | cat
