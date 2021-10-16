#!/bin/sh
echo "Setting up git globals"
git config --global user.name "David Hirsch"
git config --global user.email "dhirsch1138@gmail.com"
git config --list | cat
