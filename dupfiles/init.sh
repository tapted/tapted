#!/bin/bash -x

WHEREAMI=`which "$0" || readlink -f "$(pwd)/$0"`
HERE=`echo "$WHEREAMI" | sed -e 's/[^/]*$//'`
DB=contents2.sqlite

if sqlite3 <<<.schema $DB  | diff -w - $HERE/contents.sql ; then
  echo "Database schema looks good"
else
  sqlite3 $DB < $HERE/contents.sql
fi
$HERE/find.sh || exit 1
$HERE/orphaned.sh || exit 1
sqlite3 $DB < orphaned_list2
$HERE/make_inserts.sh || exit 1
sqlite3 $DB < file_list2.inserts
$HERE/unique.sh || exit 1

gcc -Wall -W -O2 -o commonlink $HERE/commonlink.c

$HERE/duplicates.sh || exit 1
