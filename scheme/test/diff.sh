#!/bin/bash
OUT="$1.out"
shift
echo "$ $* | diff - $OUT"
/bin/bash $* | diff - $OUT
# /bin/bash $* | diff --strip-trailing-cr - $OUT
