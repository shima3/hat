#!/bin/bash
# Usage: ./hat.sh [-e func] source.sch
# source.sch: ソースファイル名
# func: 最初に呼び出す関数
# Example: ./hat.sh sample/hello.sch
dir=${0%/*}
# $dir/gauche/interpret.sh $dir/src/hat.scm $*
$dir/gauche/hat.sh -I $dir/include $*
