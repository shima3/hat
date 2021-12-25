#!/bin/bash
file_ext=${1##*/}
base=${file_ext%.*}
csc -O4 -R chicken.io -R srfi-13 -R srfi-18 -R srfi-69 -prologue chicken/wrapper.scm -epilogue chicken/epilogue.scm -o chicken/$base $*
# csc -O4 -R srfi-13 -R srfi-18 -R srfi-69 -prologue chicken/wrapper.scm -postlude '(apply main-proc (cons (program-name)(command-line-arguments)))' -o chicken/$base $*
# csc -O4 -R srfi-18 -R srfi-69 -epilogue chicken/wrapper.scm -o chicken/$base $*
# csc -O4 -R srfi-18 -R srfi-69 -prologue chicken/wrapper.scm -epilogue chicken/epilogue.scm -o chicken/$base $*
# csc -O5 -s chicken/wrapper.scm
# csc -O5 -R srfi-18 -R srfi-69 -o chicken/$base.so -s $*
# chmod -x chicken/wrapper.so chicken/$base.so
# csc -O5 -o chicken/$base chicken/bootstrap.scm
