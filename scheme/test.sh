#!/bin/bash
dir=${0%/*}
cd $dir
log=test/last.log
(echo -n ---------- ; LANG=C date; time test/all.sh src/hat.scm diff interpret gauche) 2>&1 | tee -a $log
