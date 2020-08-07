#!/bin/bash
if [ "$*" == "" ]
then tests=test/[0-9]*.sh
else tests=$*
fi
infos=( )
for test in $tests
do
    /bin/bash $test guile/coverage.sh
    fname_ext=${test##*/}
    info=coverage/${fname_ext%.*}.info
    lcov -e guile/lcov.info "$PWD/*" -o $info
    infos+=($info)
done
#echo "infos=" "${infos[*]}"
genhtml -o coverage ${infos[*]}
