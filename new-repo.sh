#!/bin/sh
# 
# add in args when ready. Hardcoded for now
echo "# utils-shell" >> README.md
git init
git add README.md
git commit -m "first commit"
git branch -M main
git remote add origin https://github.com/moooooooo/utils-shell.git
git push -u origin main
