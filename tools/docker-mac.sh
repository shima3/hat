#!/bin/bash
dir=$(cd ${0%/*}; pwd)
if tty -s
then option=-t
else option=
fi
docker run --rm -i $option -v $dir/..:/home/hat -w /home/hat kshima/scheme $*
