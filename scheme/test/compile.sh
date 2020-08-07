#!/bin/bash
case $# in
    [0-2])
	echo Usage: "$0" SRC OUT SCHEME [TEST ...]
	echo SRC: schsi.scm sch-script.scm
	echo OUT: out write diff
	echo SCHEME: chez chicken gambit
	echo Example: "$0" schsi.scm diff chez
	echo Example: "$0" schsi.scm out chicken test/2.sh
	echo Example: "$0" schsi.scm diff gambit test/[2-4].sh
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
FILE="${SRC##*/}"
EXE="${SCHEME}/${FILE%.*}"
"${SCHEME}/compile.sh" "$SRC"
STATUS="$?"
if [ ! "$STATUS" -eq 0 ]
then
    echo "Compile error"
    exit "$STATUS"
fi
for TEST in $TESTS
do
    BASE="${TEST%.*}"
    test/${OUT}.sh "$BASE" "$TEST" "$EXE"
    echo "Exit code = $?"
done
exit 0

if [ $# == 0 ]
then
    echo Usage: "$0" 処理系 SRC テストケース
    echo Example: "$0" chicken schsi.scm test/2.sh
    echo Internal Usage: "$0" 処理系 - スクリプト 引数・・・
    exit 0
fi
self="$0"
SCHEME="$1"
SRC="$2"
TEST="$3"
if [ ! "$EXE" -nt "$SRC" ]
then
fi
echo "$ $TEST $EXE"
/bin/bash "$TEST" "$EXE"
exit 0

if [ "$test" == "-" ]
 then
    source="${3##*/}"
     executable="$scheme/${source%.*}"
    if [ ! "$executable" -nt "$3" ]
    then
	"$scheme/compile.sh" "$3"
    fi
    shift 3
    "$executable" $*
else
    /bin/bash "$test" "$self" "$scheme" - 
fi
