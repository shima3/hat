#!/bin/bash
dir=${0%/*}
gosh $dir/aid-interpret.scm "$@"
