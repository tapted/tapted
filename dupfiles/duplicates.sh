#!/bin/bash
DB=contents2.sqlite
DUP=duplicates_list2
SYM=symlinks2.sh

PREFERDEEP=0
MINSENTINEL="9999"
REVERSE="-r"
if [ "$PREFERDEEP" -eq 0 ] ; then
  REVERSE=""
  MINSENTINEL="0"
fi

ANDTHEN='\\\n\t&&'
TM=".timeout 1000
"

echo '#!/bin/sh' > $SYM
echo "$TM SELECT tally, size, hash FROM (SELECT count (*) as tally , size, hash FROM file GROUP BY size, hash) WHERE hash != 0 AND size > 1 and tally > 1 ORDER BY size DESC;" | sqlite3 $DB > $DUP
while read i ; do
  tally=`echo "$i" | cut -f1 '-d|'`
  sz=`echo "$i" | cut -f2 '-d|'`
  hash=`echo "$i" | cut -f3 '-d|'`
  echo "# $tally files of size $sz and hash $hash" >> $SYM
  tmpa="$sz_$hash.tmp"
  tmpb="$sz_$hash.tmq"
  cat /dev/null > $tmpa
  cat /dev/null > $tmpb
  echo "$TM SELECT path FROM file WHERE size = $sz AND hash = '$hash';" | sqlite3 $DB | while read j ; do
    if [ -w "$j" ] ; then
      echo `echo "$j" | wc -c` "$j" >> "$tmpa"
    else
      echo "$j is not writeable - len = '0'"
      echo "$MINSENTINEL $j" >> "$tmpa"
    fi
  done
  sort -n $REVERSE "$tmpa" > "$tmpb"
  src=""
  while read j ; do
    f=`echo "$j" | cut -f2- '-d '`
    if [ -z "$src" ] ; then
      src="$f"
    else
      if [ -w "$f" ] ; then
        #echo -e "Same: $src $f      \t($i)"
        echo -ne "stat '$src' $ANDTHEN rm -v '$f'  $ANDTHEN " >> $SYM
        ./commonlink "$f" "$src" "-sv" >> $SYM || exit 1
      else
        echo "$f is not writeable either - skip"
      fi
    fi
  done < "$tmpb"
  rm "$tmpa" "$tmpb"
done < $DUP

echo "Potential symlinks left in $SYM"
