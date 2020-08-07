#!/bin/bash
case $# in
    [0-2])
	echo Usage: "$0" SRC OUT SCHEME [TEST ...]
	echo SRC: schsi.scm sch-script.scm
	echo OUT: out write diff
	echo SCHEME: chez chicken gambit gauche guile
	echo Example: "$0" schsi.scm diff gambit
	echo Example: "$0" schsi.scm out gauche test/2.sh
	echo Example: "$0" schsi.scm diff guile test/[2-4].sh
	exit 0
	;;
    3)
	TESTS="${0%/*}/[0-9]*.sh"
	;;
    *)
	TESTS="${@:4}"
	;;
esac
SRC="$1"
OUT="$2"
SCHEME="$3"
for TEST in $TESTS
do
    BASE="${TEST%.*}"
    test/${OUT}.sh "$BASE" "$TEST" "$SCHEME/interpret.sh" "$SRC"
    echo "Exit code = $?"
done
exit 0
