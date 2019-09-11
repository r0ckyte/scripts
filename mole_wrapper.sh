#!/bin/bash

#cluster name can only be prod or dev
cluster="$1"
output=./"$cluster"/group_vars/app/all

#extract only variables from inventory to group_vars/molecule_var and expose to molecule
#grep outputs complete word around '=','="' and '='' and awk removes the duplicate assignments. sed converts to dict by replacing "=" with ': ', tailing space after ":" to interpret as yaml
grep -Eo '\w+=(\w+|"[^"]*"'"|'[^']+')" ./"$cluster"/inventory | awk -F "=" '!a[$1]++' | sed 's/\=/\: /g' > $output

#Issue2  - variables declared inside other files within group_vars dir are not visible
find ./"$cluster"/group_vars/*.yml -maxdepth 1 -type f -exec cat {} \; -exec echo " " \; >> $output
 
#strip all document start symbols like '---' which included while concatenating multiple yaml files
sed -i '/^\-\-\-/d' $output
