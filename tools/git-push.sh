#!/bin/bash
dir=${0%/*}
cd $dir/..
git add tools
cd scheme
git add examples gauche hat.sh include src test
git status
git commit -a -m "$(LANG=C date)"
git push
