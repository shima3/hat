#!/bin/bash
dir=$(cd ${0%/*}; pwd)
if tty -s
then option=-t
else option=
fi
docker run --rm -i $option -v /etc/group:/etc/group:ro -v /etc/passwd:/etc/passwd:ro -u $(id -u $USER):$(id -g $USER) -v $dir/..:/home/hat -w /home/hat kshima/scheme $*
