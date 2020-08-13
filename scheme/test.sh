#!/bin/bash
dir=${0%/*}
cd $dir
log=test/last.log
stty -ocrnl
(echo -n ---------- ; LANG=C date; time test/all.sh src/hat.scm diff interpret guile) 2>&1 | tee $log
# (echo -n ---------- ; LANG=C date; time test/all.sh src/hat.scm diff interpret gauche) 2>&1 | tee $log
