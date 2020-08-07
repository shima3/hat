#!/bin/bash
if [ $# == 0 ]
then
    echo Usage: "$0" SRC OUT TYPE SCHEME
    echo SRC: schsi.scm sch-script.scm
    echo OUT: out diff
    echo TYPE: interpret compile
    echo SCHEME: chez chicken gambit gauche guile
    echo Example: "$0" schsi.scm diff interpret gauche
    exit 0
fi
SRC="$1"
OUT="$2"
TYPE="$3"
SCHEME="$4"
for TEST in test/[0-9]*-*/[0-9]*.sh
do
    # BASE="${TEST%.*}"
    # /bin/bash "test/${TYPE}.sh" "$SCHEME" "$SRC" "$TEST" > "${BASE}.out"
    # test/out.sh "$BASE" "test/${TYPE}.sh" "$SCHEME" "$SRC" "$TEST"
    # test/diff.sh "$BASE" "test/${TYPE}.sh" "$SCHEME" "$SRC" "$TEST"
    # test/${OUT}.sh "$BASE" "test/${TYPE}.sh" "$SCHEME" "$SRC" "$TEST"
    "test/${TYPE}.sh" "$SRC" "$OUT" "$SCHEME" "$TEST"
    # echo "Exit code = $?"
done
