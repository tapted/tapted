#!/bin/bash
DB=contents2.sqlite
UP=unique.updates
TMP=unique.dupsizes
IFS="|"
ATLEASTONENULL=" SUM(CASE WHEN nbyte IS NULL THEN 1 END) > 0 "
echo "select size, count(*) AS num from file WHERE size > 14096 GROUP BY size HAVING $ATLEASTONENULL AND count(*) > 1 ORDER BY size*num DESC" | sqlite3 $DB > $TMP
echo "BEGIN TRANSACTION;" > $UP
while read sz num ; do
  echo "$num files have size $sz. Seeking.."
  echo "SELECT path from file WHERE size = $sz and nbyte IS NULL" | sqlite3 $DB | while read path ; do
      nbyte=`od -j 14090 -N 4 -t d4 "$path" | cut -c8- | head -n 1`
      if [ -z "$nbyte" ] ; then
        continue
      fi
      #echo "Updating $path (size=$sz, nbyte=$nbyte)"
      epath=`echo "$path" | sed -e "s/'/''/g"`
      echo "UPDATE file SET nbyte = $nbyte WHERE path = '$epath';" >> $UP
  done
done < $TMP
echo "COMMIT;" >> $UP

sqlite3 $DB < $UP

ATLEASTONENULL=" SUM(CASE WHEN hash IS NULL THEN 1 END) > 0 "
echo "select size, nbyte, count(*) AS num from file WHERE size > 14096 AND nbyte IS NOT NULL GROUP BY size, nbyte HAVING $ATLEASTONENULL AND count(*) > 1 ORDER BY size*num DESC" | sqlite3 $DB > $TMP
while read sz nbyte num ; do
  echo "$num files have size $sz and matching bytes ($nbyte). Hashing.."
  echo "SELECT path from file WHERE size = $sz and nbyte = $nbyte and hash IS NULL" | sqlite3 $DB | while read path ; do
      hash=`md5sum "$path" | cut -f1 '-d '`
      echo "Updating $path (size=$sz, hash=$hash)"
      epath=`echo "$path" | sed -e "s/'/''/g"`
      echo "UPDATE file SET hash='$hash' WHERE path = '$epath'" | sqlite3 $DB
  done
done < $TMP
