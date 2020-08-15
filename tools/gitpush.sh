#!/bin/bash
git status
git commit -a -m "$(LANG=C date)"
git push
