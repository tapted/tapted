#!/bin/bash
FL=file_list2
sed -r "s/'/''/g;s/([^ ]*) (.*)$/('\2', \1, NULL, NULL),/" < $FL > $FL.rawinserts

echo "INSERT OR IGNORE INTO file VALUES" > $FL.inserts
grep '^(' $FL.rawinserts >> $FL.inserts
echo "('', 0, NULL, NULL);" >> $FL.inserts
