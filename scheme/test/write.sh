#!/bin/bash
OUT="$1.out"
shift
echo "$ $* > $OUT"
exec /bin/bash $* > $OUT
