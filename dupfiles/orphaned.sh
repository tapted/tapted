#!/bin/bash
DB=contents2.sqlite
ORPH=orphaned_list2
echo -e ".timeout 1000\nSELECT path FROM file;" | sqlite3 "$DB" > oldfiles
cut -f2- '-d ' file_list2 > newfiles
echo "BEGIN TRANSACTION;" > $ORPH
cat oldfiles newfiles newfiles | sort | uniq -u | sed -e "s/'/''/g ; s/.*/DELETE FROM file WHERE path = '&';/" >> $ORPH
echo "COMMIT;" >> $ORPH
