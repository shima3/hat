#!/bin/bash
OUT="$1.out"
shift
echo "$ $* | diff - $OUT"
exec /bin/bash $* | diff - $OUT
